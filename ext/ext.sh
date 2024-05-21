detect_pkgmng() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		echo "brew"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		echo "apt"
	else
		echo 1>&2 "Unknown OS $OSTYPE"
		exit 1
	fi
}

foreach_ext() {
	local callback=$1
	local selector=(${@:2})

	local yaml=ext/ext.yml
	local depth1_regex='^([^[:space:]:]*):'
	local comment_regex='^[:space:]*#'

	# $(sed "1,/^$1/d;/^[^ ]/,$$d" $yaml)
	local ext_config=""
	local i=0
	local selected=false
	while IFS= read -r line; do
		if [[ "$line" =~ $comment_regex ]]; then continue; fi
		if [[ "$line" =~ $depth1_regex ]]; then
			if [ -n "$ext" ]; then
				$callback $i "$ext" "$ext_config" $selected
			fi
			local ext=${BASH_REMATCH[1]}
			ext_config=""
			selected=${selector[$i]} # array start with 0, index start with 1
			i=$((i+1))
		else
			if [ -z "$ext_config" ]; then
				ext_config="${line}"
			else
				ext_config="${ext_config}"$'\n'"${line}"
			fi
		fi
	done < $yaml
	$callback $i "$ext" "$ext_config" $selected
}

print_value() {
	local configs=$1
	local key=$2

	local kv_regex="^([[:space:]]+)${key}:[[:space:]]*([^[:space:]].*)$"
	local indent_regex="^([[:space:]]*)"
	#echo "$configs" | awk '
	#	BEGIN{indent=100}
	#	{
	#		match($0,/^ */)
	#		if(/^ *script:/) {indent=RLENGTH}
	#		if(RLENGTH>indent) {print $0}
	#	}'

	local depth=-1
	$ECHO "$configs" | while IFS= read -r line; do
		if (( depth > 0 )); then
			local leading_space="${line%%[^[:space:]]*}"
			if (( ${#leading_space} > depth )); then
				echo $line
			else
				break
			fi
		elif [[ "$line" =~ $kv_regex ]]; then
			local value=${BASH_REMATCH[2]}
			if [[ $value == "|" ]]; then
				depth=${#BASH_REMATCH[1]}
			else
				# unescape '[', ']'
				value="${value//\\[/[}"
				value="${value//\\]/]}"
				echo "$value"
				break
			fi
		fi
	done
}

# foreach_ext callback
list_ext() {
	local i=$1
	local ext=$2
	local configs=$3
	local selected=$4

	local check_cmd=$(print_value "$configs" "check")
	echo -n "$i." 1>&2
	check_cmd "$ext" "$check_cmd" $selected
}

# foreach_ext callback
print_default_ext() {
	local i=$1
	local ext=$2
	local configs=$3

	local default=$(print_value "$configs" "default")
	case $default in
		[Yy]) echo true;;
		[Nn]) echo false;;
		*) echo false;;
	esac
}

# foreach_ext callback=
install_ext() {
	local i=$1
	local ext=$2
	local configs=$3
	local selected=$4

	local check_cmd=$(print_value "$configs" "check")
	check_cmd "$ext" "$check_cmd" $selected 2>/dev/null
	case $? in
		#0) ;; # installed
		#1) ;; # not install
		2)
			local install_config=$(print_value "$configs" "install")
			case $install_config in
				pkgman)
					local install_method=$(detect_pkgmng)
					if [ -z $install_method ]; then exit 1; fi;;
				*)
					local install_method=${install_config:-script};;
			esac

			local install_dir=$HOME/install
			pushd . >/dev/null
			mkdir $install_dir >/dev/null
			cd $install_dir
			case $install_method in
				apt)
					exe sudo apt -y install $ext;;
				brew)
					exe brew install $ext;;
				*)
					local install_cmd=$(print_value "$configs" "$install_method")
					$ECHO "$install_cmd" | exe
					;;
			esac
			popd >/dev/null
			;;
	esac
}

ext_main() {
	local select=($(foreach_ext print_default_ext))
	while :; do
		foreach_ext list_ext "${select[@]}"
		$ECHO -n "$BLUE? [y/n] or numbers to toggle: $NC"
		read -e yn
		case $yn in
			[Nn]) break;;
			[Yy])
				foreach_ext install_ext "${select[@]}"
				break
				;;
			*)
				IFS=", "
				for n in $yn; do
					local index=$((n-1))
					if ${select[$index]}; then
						select[$index]=false
					else
						select[$index]=true
					fi
				done;;
		esac
	done
}
