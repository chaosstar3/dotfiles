main() {
	exts=$(grep "^dot_" ext.sh | sed 's/^dot_\([a-zA-Z0-9_]*\)().*/\1/')
	for ext in "${exts[@]}"; do
		# manual check exists
		if [[ $(type -t "check_$ext") == "function" ]]; then
			echo check
			check_$ext
		else
			echo which
			which $ext
		fi

		if [ $? -eq 0 ]; then
			echo found
			continue
		fi

		if [[ $(type -t "install_$ext") == "function" ]]; then
			install_$ext
		else
			pkg $ext
		fi
	done
}

