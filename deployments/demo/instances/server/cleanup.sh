#!/bin/bash
set -e

# --------------------------
# Configure
# --------------------------

SYSTEM="server"

#ABS_BACKUPDIR="/tmp/cleanup"

DATE_NOW=$(date +'%Y-%m-%d-%H-%M-%S')

echo "- Running cleanup hook with ABS_BACKUPDIR=${ABS_BACKUPDIR}"

for SESSION_PATH in $(find "./sandbox.d/data/${SYSTEM}/session" -mindepth 1 -maxdepth 1 -type d); do
	TMPFILE=$(mktemp)
	find "${SESSION_PATH}" -type f > "${TMPFILE}"

	if [ -s "${TMPFILE}" ]; then
		SESSION=$(basename ${SESSION_PATH})

		if [ -n "${ABS_BACKUPDIR}" ]; then
			echo "- Archiving \"${ABS_BACKUPDIR}/session/${SESSION}/${DATE_NOW}.tar.gz\""
			mkdir -p "${ABS_BACKUPDIR}/session/${SESSION}"
			tar czf "${ABS_BACKUPDIR}/session/${SESSION}/${DATE_NOW}.tar.gz" -T "${TMPFILE}" "./image.d/system/${SYSTEM}"
		fi

		echo "- Removing archived session ${SESSION} files"
		xargs rm -v < "${TMPFILE}"
	fi

	rm -v "${TMPFILE}"
done
