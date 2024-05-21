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

# info(msg)
info() {
	$ECHO 1>&2 "${BLUE}[info] $1${NC}"
}

check_cmd() {
	local name=$1
	local cmd=${2:-command -v "$name"}
	local default=$3

	cmd=$(eval $cmd)
	if [ $? -eq 0 ]; then
		$ECHO 1>&2 [${GREEN}+${NC}] $name: $cmd
		return 0
	elif $default; then
		$ECHO 1>&2 [${YELLOW}v${NC}] $name
		return 2
	else
		$ECHO 1>&2 [${RED}-${NC}] $name
		return 1
	fi
}
