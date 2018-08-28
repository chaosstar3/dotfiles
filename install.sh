# rc files at home
home_cfg=(tmux.conf vimrc)

pushd . > /dev/null
cd $(dirname "$0")
dotdir=$(dirs -p | sed -e 's/^~\///;q')

# symlink to homedir with .
for cfg in ${home_cfg[@]}; do
	ln -s -i $dotdir/$cfg ~/.$cfg
done

# return to life
popd > /dev/null

