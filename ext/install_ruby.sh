#!/usr/bin/env bash
install_path="$HOME/.bin/install"
yaml=$(dirname $BASH_SOURCE)/ext.yml

# print and run command
exe() {
	YELLOW='\033[1;33m'
	NC='\033[0m'
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

get_install_script() {
	entry=$(sed "1,/^$1/d;/^[^ ]/,$$d" $yaml)

	a=$(echo "$entry" | sed -n '/script:/,$p')

	echo "$entry" | awk '
		BEGIN{indent=100}
		{
			match($0,/^ */)
			if(/^ *script:/) {indent=RLENGTH}
			if(RLENGTH>indent) {print $0}
		}'
}

pushd .>/dev/null
mkdir -p $install_path >/dev/null
cd $install_path

set -e
# install ruby-install
exe <<cmd
	$(get_install_script ruby-install)
cmd

# install chruby
exe <<cmd
	$(get_install_script chruby)
cmd

# install ruby
exe ruby-install ruby
. /usr/local/share/chruby/chruby.sh
exe chruby ruby

popd >/dev/null
