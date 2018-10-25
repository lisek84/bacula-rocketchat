#!/bin/bash

# Directory to store backups in
DST=/backup
# Any backups older than this will be deleted first
KEEPDAYS=2

DATE=$(date  +%Y-%m-%d)

find ${DST} -type f -mtime +${KEEPDAYS} -delete
rmdir $DST/* 2>/dev/null

mkdir -p ${DST}/${DATE}
rm -f ${DST}/today
ln -s ${DST}/${DATE} ${DST}/today

echo -n "Backing up RocketChat Server (Snap Install)... "
echo "...Stopping RocketChat for Backup Purpose..."
echo "...This starts service downtime at `date`..."
service snap.rocketchat-server.rocketchat-server stop
echo "...Creating Backup. This Could Take some time..."
backuplocation=`snap run rocketchat-server.backupdb | grep rocketchat_backup | cut -d' ' -f11-`
backupstatus=$?
echo "Backup created at $backuplocation. Process finished with $backupstatus"
        if [ $backupstatus -eq 0 ]; then
                mv $backuplocation ${DST}/${DATE}/
                echo "Backup Complete"
                echo "Restarting RocketChat via Snap"
                service snap.rocketchat-server.rocketchat-server start
                echo "End of service downtime at `date`"

        else
                echo "Dude, Something went wrong. I'm so sorry."
                echo "Restarting RocketChat via Snap"
                service snap.rocketchat-server.rocketchat-server start
                echo "End of service downtime at `date`"
                echo "Finished with errors"
                exit 1
        fi

echo "Done."
exit 0
