#!/bin/bash
set -e

# Who and where am I ?
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] GLOBAL INFORMATIONS"
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] whoami : $(whoami)"
echo >&2 "[INFO] pwd : $(pwd)"

# Backup the prev install in case of fail...
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Backup old dokuwiki installation in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------------------"
tar -zcvf /var/backup/dokuwiki/dokuwiki-v$(date '+%Y%m%d%H%M%S').tar.gz .
echo >&2 "[INFO] Complete! Backup successfully done in $(pwd)"

# Since dokuwki can be upgraded by overwriting files do the upgrade !
# @TODO use VERSION file to check if necessary
# 
# File copy strategy taken from wordpress entrypoint
# @see https://github.com/docker-library/wordpress/blob/master/fpm/docker-entrypoint.sh
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Installing or upgrading dokuwiki in $(pwd) - copying now..."
echo >&2 "[INFO] ---------------------------------------------------------------"
echo >&2 "[INFO] Extracting new installation"
tar cvf - --one-file-system -C /usr/src/dokuwiki . | tar xvf -
echo >&2 "[INFO] Removing old files"
grep -Ev '^($|#)' data/deleted.files | xargs -n 1 rm -vf

# To disable wrong update messages
# @see https://www.dokuwiki.org/update_check
echo >&2 "[INFO] Removing upgrade message in dokuwiki"
rm -vf data/cache/messages.txt 

# Update template configuration site width with my needs
echo >&2 "[INFO] Customizing default style"
sed -i -e "s|75em|98em|g" lib/tpl/dokuwiki/style.ini

# Rights fixed
echo >&2 "[INFO] Fixing rights"
chown -Rfv nginx:nginx .

# Done
echo >&2 "[INFO] Complete! Dokuwiki has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
