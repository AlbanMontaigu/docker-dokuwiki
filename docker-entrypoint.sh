#!/bin/bash
set -e

# Backup the prev install in case of fail...
tar -zcf /var/backup/dokuwiki/dokuwiki-v$(date '+%y%m%d%H%M%S').tar.gz /var/www

# Since dokuwki can be upgraded by overwriting files do the upgrade !
# @TODO use VERSION file to check if necessary
# 
# File copy strategy taken from wordpress entrypoint
# @see https://github.com/docker-library/wordpress/blob/master/fpm/docker-entrypoint.sh
echo >&2 "Installing or upgrading dokuwiki in $(pwd) - copying now..."
tar cf - --one-file-system -C /usr/src/dokuwiki . | tar xf -
grep -Ev '^($|#)' data/deleted.files | xargs -n 1 rm -vf
# To disable wrong update messages
# @see https://www.dokuwiki.org/update_check
rm -f data/cache/messages.txt 
chown -R nginx:nginx ./
echo >&2 "Complete! Dokuwiki has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
