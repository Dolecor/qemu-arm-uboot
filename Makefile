# SPDX-License-Identifier: MIT

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export LOADADDR=0x8000

SRC_DIR=$(shell pwd)
MISC_DIR=$(SRC_DIR)/misc
PSEUD_MODULE_SRC=$(SRC_DIR)/pseudo-device-driver/module

ROOTFS_DIR=$(MISC_DIR)/rootfs
SD_IMG_FILE=$(MISC_DIR)/sd.img
UIMAGE_FILE=$(SRC_DIR)/linux/arch/arm/boot/uImage
DTB_FILE=$(SRC_DIR)/u-boot/arch/arm/dts/vexpress-v2p-ca9.dtb
MODULES_DIR=$(MISC_DIR)/lib/modules
KERNEL_VERSION=$(shell cat $(SRC_DIR)/linux/include/config/kernel.release)
PSEUD_MODULE=$(MODULES_DIR)/$(KERNEL_VERSION)/pseud
# The size must be exactly as specified in the u-boot configuration
# during 'make menuconfig'. 0x40000 is a default value in configuration.
UBOOT_ENV_EXACT_SIZE=0x40000
UBOOT_ENV_TXT=$(SRC_DIR)/uboot.txt
UBOOT_ENV_IMG=$(MISC_DIR)/uboot.env

all: u-boot kernel rootfs pseud sd-img

# During `make menuconfig` select Environment and set the following:
# 	- in EXT4 file system
# 	- name of the block device (mmc)
# 	- device and partition (0:1)
# 	- name of EXT4 file (/boot/uboot.env)
# *also check that environment size option is equal to UBOOT_ENV_EXACT_SIZE
u-boot:
	$(MAKE) -C $(SRC_DIR)/u-boot vexpress_ca9x4_defconfig
	$(MAKE) -C $(SRC_DIR)/u-boot menuconfig
	$(MAKE) -C $(SRC_DIR)/u-boot
	$(SRC_DIR)/u-boot/tools/mkenvimage -s $(UBOOT_ENV_EXACT_SIZE) \
		-o $(UBOOT_ENV_IMG) $(UBOOT_ENV_TXT)

u-boot-clean:
	$(MAKE) -C $(SRC_DIR)/u-boot distclean
	rm -f $(UBOOT_ENV_BASE).env

kernel:
	$(MAKE) -C $(SRC_DIR)/linux vexpress_defconfig
	$(MAKE) -C $(SRC_DIR)/linux uImage modules

kernel-clean:
	$(MAKE) -C $(SRC_DIR)/linux distclean

rootfs: kernel
	sudo qemu-debootstrap --arch armhf bullseye $(ROOTFS_DIR) \
		http://ftp.debian.org/debian
	@echo "123\n123" | sudo chroot $(ROOTFS_DIR) passwd
	sudo $(MAKE) -C $(SRC_DIR)/linux modules_install \
		INSTALL_MOD_PATH=$(ROOTFS_DIR)

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
		$(ROOTFS_DIR) $(UIMAGE_FILE) $(DTB_FILE) $(MODULES_DIR) $(UBOOT_ENV_IMG)

sd-img-clean:
	sudo rm -fr $(SD_IMG_FILE)

clean: u-boot-clean kernel-clean rootfs-clean pseud-clean sd-img-clean
	
.PHONY: all u-boot kernel rootfs sd-img \
	clean kernel-clean u-boot-clean rootfs-clean pseud-clean sd-img-clean
