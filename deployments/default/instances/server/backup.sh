#!/bin/sh
set -e

# --------------------------
# Configure
# --------------------------

SYSTEM="server"

#ABS_BACKUPDIR="/tmp"

# --------------------------
# Datastore: 34
# --------------------------

DATE_NOW=$(date +'%Y-%m-%d-%H-%M-%S')

TMPFILE=$(mktemp)
cat > "${TMPFILE}"

if [ -s "${TMPFILE}" ]; then
	if [ -n "${ABS_BACKUPDIR}" ]; then
		mkdir -p "${ABS_BACKUPDIR}/datalog/${SYSTEM}"
		tar czf  "${ABS_BACKUPDIR}/datalog/${SYSTEM}/${DATE_NOW}.tar.gz" -T "${TMPFILE}" "${1}" 2> /dev/null
	fi

	xargs rm < "${TMPFILE}"
fi

rm "${TMPFILE}"
