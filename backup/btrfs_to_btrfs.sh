#!/bin/bash

################################################################################
#                                                                              #
# This backup script is used in a very specific setup.                         #
#                                                                              #
# Backup SRC and BACKUP_DESTINATION use BTRFS which support snapshoting. This  #
# is used to have a "local backup" (new snapshot in SRC) and a "remote backup" #
# (a new snapshot on the backup drive). Snapshotting is almost free in terms of#
# CPU cycles and space. However, you do not free any space when you delete     #
# files as they will remain in the snapshorts. You have to delete the snapshots#
# (or files in the snapshots) to really free some space.                       #
# The good thing: You'll have something like a timemachine on your filesystem. #
#                                                                              #
# Know Bugs:                                                                   #
#                                                                              #
# * The script finds some folders based on grepping. You might end up with the #
#   wrong folders if the have similar names. E.g., having "home" and "home2"   #
#   will cause trouble.                                                        #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
# Version: 0.1-20170619                                                        #
#                                                                              #
################################################################################


BACKUP_DESTINATION=/btrfs
SRC=/btrfs-usb
SRC_SUBVOLUME=home

MOUNTING=-1
if mountpoint -q -- "$BACKUP_DESTINATION"; then
	echo "Backup mounted!"
	MOUNTING=0
else
	mount $BACKUP_DESTINATION
	MOUNTING=1
fi

if mountpoint -q -- "$BACKUP_DESTINATION"; then
	echo "Backup dir looks good"
else
	echo "Backup failed, dir not mounted?"
	exit 1
fi

btrfs subvolume snapshot $SRC/$SRC_SUBVOLUME $SRC/$SRC_SUBVOLUME-`date +%Y%m%d-%H%M%S`

if [ $? -eq 0 ]; then
	LATEST_HOME=`ls -1 $SRC/ | grep $SRC_SUBVOLUME | tail -n 1`
	LATEST_BACKUP=`ls -1 $BACKUP_DESTINATION/ | grep $SRC_SUBVOLUME | tail -n 1`

	SOURCE=$SRC/$LATEST_HOME/
	DESTINATION=$BACKUP_DESTINATION/$LATEST_HOME/

	btrfs subvolume snapshot $BACKUP_DESTINATION/$LATEST_BACKUP $BACKUP_DESTINATION/$LATEST_HOME
	rsync -az -P --delete $SOURCE $DESTINATION
else
	echo "Backup failed, snapshot not created"
fi

if [ $MOUNTING -eq 1 ]; then
	echo "Unmouting $BACKUP_DESTINATION"
	umount $BACKUP_DESTINATION
fi

exit 0
