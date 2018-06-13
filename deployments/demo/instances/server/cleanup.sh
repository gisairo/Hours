#!/bin/sh
set -e

# --------------------------
# Configure
# --------------------------

SYSTEM="server"

#ABS_BACKUPDIR="/tmp"

# --------------------------
# Datastore: 24
# --------------------------

INIT_PWD=$(pwd)
BASEDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$BASEDIR"; pwd)
DATE_NOW=$(date +'%Y-%m-%d-%H-%M-%S')

for SESSION_PATH in $(find "${SCRIPTDIR}/session" -mindepth 1 -maxdepth 1 -type d); do
	TMPFILE=$(mktemp)
	find "${SESSION_PATH}" -type f > "${TMPFILE}"

	if [ -s "${TMPFILE}" ]; then
		SESSION=$(basename ${SESSION_PATH})

		if [ -n "${ABS_BACKUPDIR}" ]; then
			mkdir -p "${ABS_BACKUPDIR}/session/${SYSTEM}/${SESSION}"
			tar czf  "${ABS_BACKUPDIR}/session/${SYSTEM}/${SESSION}/${DATE_NOW}.tar.gz" -T "${TMPFILE}" "${INIT_PWD}/image.d/defin/system/${SYSTEM}" 2> /dev/null
		fi

		xargs rm < "${TMPFILE}"
	fi

	rm "${TMPFILE}"
done
