function sde() {
	lst=$HOME/.bin/local/sdk.lst
	# ex) jdk 8 java 8.0.0-dist
	cmd() { test $? -eq 0 && exe sdk use $3 $4 || exe sdk $@; }
	argm 2 cmd $@ < $lst
}

function jdk() {
	# n sdk_java_version
	lst=$HOME/.bin/local/jdk.lst
	cmd() { test $? -eq 0 && exe sdk use java $2; }
	argm 1 cmd $@ < $lst
}

