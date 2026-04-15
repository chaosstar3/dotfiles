if [ -n "$DOT" ]; then
	return
fi

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

detect_env() {
	# check backslash escape is enabled
	if [ "$(echo '\040')" = " " ]; then
		ECHO="echo"
	else
		ECHO="echo -e"
	fi
}

detect_read() {
	if [ -n "$ZSH_VERSION" ]; then
		READ=(read -r -A)
	else
		READ="read -r -a"
	fi
}

detect_dotroot() {
	if [ -n "$ZSH_VERSION" ]; then
		local root="${(%):-%x}"
	else
		local root="${BASH_SOURCE[0]}"
	fi
	echo ${(%):-%}
	pushd . >/dev/null
	cd $(dirname "$0")
	local dotdir=$(pwd)
	local dotdir_r=$(dirs -p | sed -e 's/^~\///;q')
	popd >/dev/null
	echo $dotdir_r
}

# basic utils

# info(msg)
info() {
	$ECHO 1>&2 "${BLUE}[info] $1${NC}"
}

# print and run command
exe() {
	if [ -z $1 ]; then
		while read cmdline;do
			$ECHO 1>&2 "[${YELLOW}>${NC}] $cmdline"
			eval $cmdline
		done
	else
		$ECHO 1>&2 "[${YELLOW}>${NC}] $@"
		eval $@
	fi
}

dot() {
	detect_env
	detect_dotroot
}

detect_dotroot
