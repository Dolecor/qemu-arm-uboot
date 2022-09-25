#!/bin/bash

# Create SD card image

source scripts/config.txt

SD_IMG_FILE=$1

dd if=/dev/zero of=$SD_IMG_FILE bs=512M count=1

# Create MBR and one primary partition of type 83 (Linux):
#   o       - create a new empty DOS partition table
#   n       - add a new partition
#   (enter) - set default partition type (primary)
#   (enter) - set default partition number (1)
#   2048 - set first sector (2048)
#   (enter) - set default last sector (max)
#   t       - change a partition type
#   83      - Hex code (Linux)
#   w       - write table to disk and exit
echo -e "o\n" "n\n" "\n" "\n" "$FIRST_SECTOR\n" "\n" "t\n" "83\n" "w\n" \
    | sudo fdisk $SD_IMG_FILE

SD_PRIM_PT=$(sudo losetup -o $FIRST_SECTOR_OFFSET --find --show $SD_IMG_FILE)

sudo mkfs -t ext4 $SD_PRIM_PT

sudo losetup --detach $SD_PRIM_PT
