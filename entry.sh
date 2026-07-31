if [[ -n ${BASH_VERSION-} ]]; then
	DOT_FILE=${BASH_SOURCE[0]}
elif [[ -n ${ZSH_VERSION-} ]]; then
	DOT_FILE=${(%):-%N}
fi

DOTS=$(cd -- "$(dirname -- "$DOT_FILE")" && pwd -P)

. "$DOTS/common.sh"
