#!/usr/bin/env bash
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# print and run command
exe() {
	if [ -z $1 ]; then
		while read cmdline;do
			echo -e "[${YELLOW}>${NC}] $cmdline"
			$cmdline
		done
	else
		echo -e "[${YELLOW}>${NC}] $@"
		$@
	fi
}

# info(msg)
info() {
	echo -e 1>&2 "${BLUE}[info] $1${NC}"
}

# check_cmd(cmd)
check_cmd() {
	if (command -v "$1" >/dev/null); then
		echo -e 1>&2 [${GREEN}+${NC}] $1: $(command -v "$1")
		return 0
	else
		echo -e 1>&2 [${RED}-${NC}] $1
		return 1
	fi
}

# check_to_do(cmd_to_check, msg)
check_to_do() {
	if check_cmd $1; then
		info "$2"
		return 0
	else
		info "ignore $2"
		return 1
	fi
}

# rc files at home
home_cfg=(tmux.conf vimrc)

pushd . >/dev/null
cd $(dirname "$0")
dotdir=$(pwd)
dotdir_r=$(dirs -p | sed -e 's/^~\///;q')
popd >/dev/null
info "dotdir: $dotdir"

# symlink to homedir with .
for cfg in ${home_cfg[@]}; do
	exe ln -s -i $dotdir_r/$cfg ~/.$cfg
done

# external programs
info "install external programs"
check_cmd ruby
ruby=$?

## install ruby first
if [ $ruby -ne 0 ]; then
	read -p "$(echo -e ${YELLOW}install ruby? [y/n]${NC})" -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		. $dotdir/ext/install_ruby.sh
		check_cmd ruby
		ruby=$?
	fi
fi

if [ $ruby -eq 0 ]; then
	exe ruby $dotdir/ext/ext.rb -a
fi

# git config
if check_to_do git "config git"; then
	exe git config --global include.path $dotdir_r/gitconfig
	exe git config --global core.excludesFile $dotdir/gitignore.global

	if check_to_do vim "config git core.editor"; then
		exe git config --global core.editor vim
	fi
fi

