#!/bin/bash

# Copy files to SD card image

source scripts/config.txt

SD_IMG_FILE=$1
ROOTFS=$2
UIMAGE=$3
DTB=$4

MOUNT_DIR=/mnt/sd

SD_PRIM_PT=$(sudo losetup -o $FIRST_SECTOR_OFFSET --find --show $SD_IMG_FILE)
sudo mount $SD_PRIM_PT $MOUNT_DIR

sudo cp -r $ROOTFS/* $MOUNT_DIR
sudo cp $UIMAGE $MOUNT_DIR/boot/
sudo cp $DTB $MOUNT_DIR/boot/

sudo umount $SD_PRIM_PT
sudo losetup --detach $SD_PRIM_PT
