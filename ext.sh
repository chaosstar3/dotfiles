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

exist() {
	[ -e "$1" ]
}

link() {
	local src=$1
	local dst=$2
	check() {
		exist $dst
	}
	install() {
		ln -s $src $dst
	}
}

dot_wezterm() {
	link $DOT/wezterm.lua $HOME/.wezterm.lua
}

dot_tmux() {
	link $DOT/tmux.conf $HOME/.tmux.conf
}

dot_vim() {
	link $DOT/vimrc $HOME/.vimrc
	install() {
		if check_cmd vim; then
			vim +PlugInstall +qall
		fi
		if check_cmd git; then
			git config --global core.editor vim
		fi
	}
}

dot_git() {
	install() {
		exe git config --global include.path $dotdir_r/gitconfig
		exe git config --global core.excludesFile $dotdir/gitignore.global
	}
}

# https://github.com/postmodern/chruby
dot_chruby() {
	local ver=0.3.9
	check() {
		which chruby-exec
	}
	install() {
		wget -O chruby-$ver.tar.gz https://github.com/postmodern/chruby/archive/v$ver.tar.gz
		tar -xzvf chruby-$ver.tar.gz
		cd chruby-$ver/
		sudo make install
	}
}

dot_wget() {
	return
}

dot_curl() {
	return
}

dot_make() {
	return
}

dot_ruby-install() {
	return
}

