#!/bin/bash
set -e

# --------------------------
# Configure
# --------------------------

SYSTEM="server"

#ABS_BACKUPDIR="/tmp/backup"

DATE_NOW=$(date +'%Y-%m-%d-%H-%M-%S')

echo "- Running backup hook with ABS_BACKUPDIR=${ABS_BACKUPDIR}"

TMPFILE=$(mktemp)
cat /dev/stdin > "${TMPFILE}"

if [ -s "${TMPFILE}" ]; then
	if [ -n "${ABS_BACKUPDIR}" ]; then
		echo "- Archiving \"${ABS_BACKUPDIR}/datalog/${DATE_NOW}.tar.gz\""
		mkdir -p "${ABS_BACKUPDIR}/datalog"
		tar czf "${ABS_BACKUPDIR}/datalog/${DATE_NOW}.tar.gz" -T "${TMPFILE}" "./image.d/system/${SYSTEM}"
	fi

	echo "- Removing archived datalog files"
	xargs rm -v < "${TMPFILE}"
fi

rm -v "${TMPFILE}"
