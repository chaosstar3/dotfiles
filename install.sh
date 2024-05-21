#!/usr/bin/env bash
. common.sh
. ext/ext.sh

detect_env

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
ext_main

# git config
if check_cmd git; then
	exe git config --global include.path $dotdir_r/gitconfig
	exe git config --global core.excludesFile $dotdir/gitignore.global

	if check_cmd vim; then
		exe git config --global core.editor vim
	fi
fi

