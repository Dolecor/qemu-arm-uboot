# SPDX-License-Identifier: MIT

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export LOADADDR=0x8000

SRC_DIR=$(shell pwd)
BUILD_DIR=$(SRC_DIR)/build

all: u-boot kernel rootfs

u-boot:
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot vexpress_ca9x4_defconfig
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot

u-boot-clean:
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot distclean

kernel:
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux vexpress_defconfig
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux uImage

kernel-clean:
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux distclean

rootfs:
	sudo qemu-debootstrap --arch armhf bullseye $(BUILD_DIR)/rootfs http://ftp.debian.org/debian
	@echo "123\n123" | sudo chroot $(BUILD_DIR)/rootfs passwd

rootfs-clean:
	sudo rm -r $(BUILD_DIR)/rootfs

clean: u-boot-clean kernel-clean rootfs-clean

.PHONY: all u-boot kernel rootfs clean kernel-clean u-boot-clean rootfs-clean
