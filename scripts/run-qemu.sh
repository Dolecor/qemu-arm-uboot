#!/bin/bash
# SPDX-License-Identifier: MIT
#
# Run qemu with artifacts built with Makefile

UBOOT_IMG=$1
SD_IMG=$2

qemu-system-arm -M vexpress-a9 -m 1G -nographic -kernel $UBOOT_IMG -sd $SD_IMG
