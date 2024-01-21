#!/bin/bash

TARGET_REPO=~/tmp/bb_test/test_repo
BACKUP_SOURCE=~/tmp/bb_test/test_data
DESTINATION_MOUNT_POINT=/mnt/

if mountpoint -q $DESTINATION_MOUNT_POINT ; then
	if [ ! -d "$TARGET_REPO" ]; then
		echo "Backup Repo does not exist. Creating..."
		borg init --encryption none $TARGET_REPO
		echo "Done"
	fi

	echo "Creating backup..."
	borg create -C auto,zstd $TARGET_REPO::`date +%Y%m%d-%H%M%S` $BACKUP_SOURCE
	echo "Done"

	exit 0

else
	echo Destination not mounted
	exit 1
fi

