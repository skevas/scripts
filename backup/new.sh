#!/bin/bash

################################################################################
#                                                                              #
# This backup script is used in a very specific setup.                         #
#                                                                              #
# Backup SRC and BACKUP_DESTINATION use BTRFS which support snapshoting. This  #
# is used to have a "local backup" (new snapshot in SRC) and a "remote backup" #
# (a new snapshot on the backup drive). Snapshotting is almost free in terms of#
# CPU cycles and space. However, you do not free any space when you delete     #
# files as they will remain in the snapshots. You have to delete the snapshots #
# (or files in the snapshots) to really free some space.                       #
# The good thing: You'll have something like a timemachine on your filesystem. #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
# Version: 0.2-20231207                                                        #
# * Rewrite                                                                    #
#                                                                              #
# Version: 0.1-20170619                                                        #
#                                                                              #
################################################################################


BACKUP_DESTINATION=/btrfs/backup
SRC=/btrfs/primary_home
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


STARTTIME=`date +%Y%m%d-%H%M%S`
btrfs subvolume snapshot $SRC/$SRC_SUBVOLUME $SRC/$SRC_SUBVOLUME-$STARTTIME
if [ $? -eq 0 ]; then
	echo "Snapshot created"
else
	echo "Failed to create snapshot. Exiting..."
	exit 1
fi


if [ -d $BACKUP_DESTINATION/$SRC_SUBVOLUME-backup-latest ]; then
	echo "Previous backup exists"
else
	echo "No previous backup. Creating target subvolume"
	btrfs subvolume create $BACKUP_DESTINATION/$SRC_SUBVOLUME-backup-latest
	if [ $? -eq 0 ]; then
		echo "Target created"
	else
		echo "Target creation failed"
		exit 1
	fi
fi


echo "Starting RSYNC"
rsync -azv --append --partial -P --delete $SRC/$SRC_SUBVOLUME-$STARTTIME/ $BACKUP_DESTINATION/$SRC_SUBVOLUME-backup-latest

echo "Creating backup snapshot"
ENDTIME=`date +%Y%m%d-%H%M%S`
btrfs subvolume snapshot $BACKUP_DESTINATION/$SRC_SUBVOLUME-backup-latest $BACKUP_DESTINATION/$SRC_SUBVOLUME-backup-$STARTTIME-$ENDTIME
if [ $? -eq 0 ]; then
	echo "Final snapshot created"
else
	echo "Final snapshot  creation failed"
	exit 1
fi

if [ $MOUNTING -eq 1 ]; then
	echo "Unmouting $BACKUP_DESTINATION"
	umount $BACKUP_DESTINATION
fi

exit 0
