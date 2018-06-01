#!/bin/bash
set -e

VERSION="2018.26"  # bootstrap a new version using "alan.sh bootstrap --version <version>"

function find_up {
	UP_DIR=$(pwd)
	while [[ "$UP_DIR" != "" && ! -e "$UP_DIR/$1" ]]; do
		UP_DIR=${UP_DIR%/*}
	done
	echo "$UP_DIR"
}

BASEDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$BASEDIR"; pwd)
INSTALL_ROOT=$(find_up "versions.json")

function pass_though {
	if [[ ! -e "$SCRIPTDIR/utils" ]]; then
		echo "Run ./alan.sh fetch first"
		exit
	fi

	if [[ ! -e "$INSTALL_ROOT" ]]; then
		echo "Cannot find project"
		exit
	fi

	# look for old alan-platform ...
	if [[ -e "$INSTALL_ROOT/devenv/platform/project-cli/alan-platform" ]]; then
		"$INSTALL_ROOT/devenv/platform/project-cli/alan-platform" "$@"
	# ... or new alan-platform.sh
	elif [[ -e "$INSTALL_ROOT/devenv/platform/project-cli/alan-platform.sh" ]]; then
		"$INSTALL_ROOT/devenv/platform/project-cli/alan-platform.sh" "$@"
	# ... or new alan-platform.sh in dataenv
	elif [[ -e "$INSTALL_ROOT/dataenv/platform/project-cli/alan-platform.sh" ]]; then
		"$INSTALL_ROOT/dataenv/platform/project-cli/alan-platform.sh" "$@"
	else
		echo "Run ./alan.sh fetch first"
	fi
	exit
}

function download_self {
	curl -s "http://www.m-industries.com/tools/utils/$VERSION/$PLATFORM/utils.tar.gz" | tar xzfC - "$SCRIPTDIR"
}

if [[ $(uname) == "Darwin" ]]; then
	PLATFORM="darwin-x64"
elif [[ $(uname) == "Linux" ]]; then
	PLATFORM="linux-x64"
else
	PLATFORM="windows-x64"
fi

if [[ $# -lt 1 ]]; then
	pass_though "$@"
fi

case $1 in
	--version)
		echo $VERSION
		exit
		;;

	--help)
		echo "setup: [bootstrap|upgrade|fetch]"
		echo "  bootstrap: download utilities needed by alan.sh"
		echo "  upgrade:   download the latest versions.json for projects"
		echo "  fetch:     download an environment (use 'fetch --help' for more info)"
		echo ""
		pass_though "$@"
		;;

	bootstrap)
		if [[ $2 == "--version" ]]; then
			VERSION=$3
		fi
		download_self
		;;

	upgrade)
		curl -s -L -o versions.json "https://alan-platform.com/versions/versions.json"
		download_self
		;;

	fetch)
		if [[ -e "$INSTALL_ROOT/offline" ]]; then
			echo "Skipping fetch in offline mode"
			echo "Remove the 'offline' file to re-enable downloads"
			exit 0
		fi

		download_self

		if [[ "$2" == "" ]]; then
			# allow shorthand for devenv
			pushd "$INSTALL_ROOT" >> /dev/null
				"$SCRIPTDIR/utils/fetch" devenv
			popd >> /dev/null
		else
			shift 1
			pushd "$INSTALL_ROOT" >> /dev/null
				"$SCRIPTDIR/utils/fetch" "$@"
			popd >> /dev/null
		fi
		;;

	*)
		pass_though "$@"
		;;
esac
