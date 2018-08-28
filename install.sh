# rc files at home
home_cfg=(tmux.conf vimrc)

pushd . > /dev/null
cd $(dirname "$0")
dotdir=$(pwd)
dotdir_r=$(dirs -p | sed -e 's/^~\///;q')

# symlink to homedir with .
for cfg in ${home_cfg[@]}; do
	ln -s -i $dotdir_r/$cfg ~/.$cfg
done

# git config
if (command -v git > /dev/null); then
	exe git config --global include.path $dotdir_r/gitconfig
	exe git config --global core.excludesFile $dotdir/gitignore.global

	if (command -v vim > /dev/null); then
		p git config --global core.editor vim
	fi
fi

# return to life
popd > /dev/null

