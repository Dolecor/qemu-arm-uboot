# SPDX-License-Identifier: MIT

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export LOADADDR=0x8000

SRC_DIR=$(shell pwd)
TMP_DIR=$(SRC_DIR)/tmp
PSEUD_MODULE_SRC=$(SRC_DIR)/pseudo-device-driver/module

ROOTFS_DIR=$(TMP_DIR)/rootfs
SD_IMG_FILE=$(TMP_DIR)/sd.img
UIMAGE_FILE=$(SRC_DIR)/linux/arch/arm/boot/uImage
DTB_FILE=$(SRC_DIR)/u-boot/arch/arm/dts/vexpress-v2p-ca9.dtb
MODULES_DIR=$(TMP_DIR)/lib/modules
KERNEL_VERSION=$(shell make -s -C $(SRC_DIR)/linux kernelversion)
PSEUD_MODULE=$(MODULES_DIR)/$(KERNEL_VERSION)/pseud

all: u-boot kernel rootfs pseud sd-img
	mkdir $(TMP_DIR)

u-boot:
	$(MAKE) -C $(SRC_DIR)/u-boot vexpress_ca9x4_defconfig
	$(MAKE) -C $(SRC_DIR)/u-boot

u-boot-clean:
	$(MAKE) -C $(SRC_DIR)/u-boot distclean

kernel:
	$(MAKE) -C $(SRC_DIR)/linux vexpress_defconfig
	$(MAKE) -C $(SRC_DIR)/linux uImage modules

kernel-clean:
	$(MAKE) -C $(SRC_DIR)/linux distclean

rootfs:
	sudo qemu-debootstrap --arch armhf bullseye $(ROOTFS_DIR) \
		http://ftp.debian.org/debian
	@echo "123\n123" | sudo chroot $(ROOTFS_DIR) passwd

rootfs-clean:
	sudo rm -fr $(ROOTFS_DIR)

pseud: kernel
	$(MAKE) -C $(PSEUD_MODULE_SRC) HEADERS=$(SRC_DIR)/linux
	mkdir -p $(PSEUD_MODULE)
	cp $(PSEUD_MODULE_SRC)/pseud.ko $(PSEUD_MODULE)/pseud.ko

pseud-clean:
	$(MAKE) -C $(PSEUD_MODULE_SRC) HEADERS=$(SRC_DIR)/linux clean
	rm -fr $(PSEUD_MODULE)

sd-img: u-boot kernel rootfs pseud
	$(SRC_DIR)/scripts/create_sd_image.sh $(SD_IMG_FILE)
	$(SRC_DIR)/scripts/copy_to_sd.sh $(SD_IMG_FILE) \
		$(ROOTFS_DIR) $(UIMAGE_FILE) $(DTB_FILE) $(MODULES_DIR)

sd-img-clean:
	sudo rm -fr $(SD_IMG_FILE)

clean: u-boot-clean kernel-clean rootfs-clean pseud-clean sd-img-clean
	rm -fr $(TMP_DIR)
	
.PHONY: all u-boot kernel rootfs sd-img \
	clean kernel-clean u-boot-clean rootfs-clean pseud-clean sd-img-clean
