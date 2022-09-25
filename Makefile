# SPDX-License-Identifier: MIT

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export LOADADDR=0x8000

SRC_DIR=$(shell pwd)
BUILD_DIR=$(SRC_DIR)/build

SD_IMG_FILE=$(BUILD_DIR)/misc/sd.img
UIMAGE_FILE=$(BUILD_DIR)/linux/arch/arm/boot/uImage
DTS_FILE=$(SRC_DIR)/u-boot/arch/arm/dts/vexpress-v2p-ca9.dts #TODO: use dtc to compile dts to dtb

all: u-boot kernel rootfs kernel-install sd-img

u-boot:
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot vexpress_ca9x4_defconfig
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot

u-boot-clean:
	$(MAKE) O=$(BUILD_DIR)/u-boot -C $(SRC_DIR)/u-boot distclean

kernel:
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux vexpress_defconfig
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux uImage modules

kernel-clean:
	$(MAKE) O=$(BUILD_DIR)/linux -C $(SRC_DIR)/linux distclean

rootfs:
	sudo qemu-debootstrap --arch armhf bullseye $(BUILD_DIR)/rootfs \
		http://ftp.debian.org/debian
	@echo "123\n123" | sudo chroot $(BUILD_DIR)/rootfs passwd

rootfs-clean:
	sudo rm -fr $(BUILD_DIR)/rootfs

sd-img: kernel rootfs
	$(SRC_DIR)/scripts/create_sd_image.sh $(SD_IMG_FILE)
	$(SRC_DIR)/scripts/copy_to_sd.sh $(SD_IMG_FILE) \
		$(BUILD_DIR)/rootfs $(UIMAGE_FILE) $(DTS_FILE)

sd-img-clean:
	sudo rm -fr $(BUILD_DIR)/misc/sd.img

clean: u-boot-clean kernel-clean rootfs-clean sd-img-clean
	
.PHONY: all u-boot kernel rootfs kernel-install sd-img \
	clean kernel-clean u-boot-clean rootfs-clean sd-img-clean
