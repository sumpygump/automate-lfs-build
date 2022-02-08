# automate-lfs-build

This repository is a set of script which can be used to automate LFS build. It
follows the suggested flow from version 11.0 of the Linux From Scratch book
which you can find at linuxfromscratch.org:
https://linuxfromscratch.org/lfs/view/stable/

### Requirements

Install the basic required packages in a debian based distribution using the following command:

`$ apt install build-essential bison texinfo gawk git python2.7 kpartx -y`

### Recommended partition set up

To create the LFS system it is best to set it up on a hard drive partitioned as with at least four partitions as described below. You can create a virtual hard drive in virtualbox (recommended 20GB) and attaching it to your VM.

Assuming the drive for installing LFS is recognized by your linux machine as `/dev/sdb` for the purposes of the following scripts to partition and mount it.

```
sudo parted --script /dev/sdb mklabel gpt \
    mkpart primary 1MiB 100MiB \
    mkpart primary 100MiB 525MiB \
    mkpart primary 525MiB 19.3GB \
    mkpart primary 19.3GB 100%
sudo parted --script /dev/sdb set 1 bios_grub on
sudo mkfs.vfat /dev/sdb1
sudo mkfs.ext4 /dev/sdb2
sudo mkfs.ext4 /dev/sdb3
sudo mkswap /dev/sdb4
sudo tune2fs -c 1 -L LFSBOOT /dev/sdb2
sudo tune2fs -c 1 -L LFSROOT /dev/sdb3
```

Now to mount the drive at our LFS root and boot partitions:

```
export LFS=/mnt/lfs2
sudo mkdir -vp /mnt/lfs2
sudo mount -t ext4 -L LFSROOT $LFS
sudo mkdir -vp $LFS/boot
sudo mount -t ext4 -L LFSBOOT $LFS/boot
sudo swapon -v /dev/sdb4
```

### Scripts

Scripts must be executed in the same order as shown below

* 01-version-check.sh
    - This should be first script which should be executed, make sure there are no errors before proceding further.

* 02-setup-lfs-user
    - This script is responsible for creating lfs user and setting up bash for lfs.

* 03-build-toolchain
    - This script is responsible for setting up toolchain, must be executed with lfs user permission.

* 04-build-packages
    - This script is responsible for building minimum linux packages

* 05-make-bootable
    - This script is responsible for setting up some default configs and making grub MBR

* 06-create-image
    - This is optional script for creating an ISO image.


### Notes

* The scripts have been tested only on Ubuntu 18.04.1 LTS

* iso image has been tested with qemu using below command\
`$ qemu-system-x86_64 -drive format=raw,file=$LFS/iso/lfs.iso -nographic -enable-kvm -m 512M`

* Below procedure should work seamlessly, considering LFS env has been set

```
export LFS=/mnt/lfs
mkdir -p $LFS/automate-lfs-build
git clone https://github.com/ranjithum/automate-lfs-build $LFS/automate-lfs-build
cd $LFS/automate-lfs-build
mkdir -p $LFS/lfs-source; wget --input-file=./lfs-packages.txt --continue --directory-prefix=$LFS/lfs-source
./01-version-check.sh
./02-setup-lfs-user
su - lfs
cd automate-lfs-build
./03-build-toolchain
exit
./04-build-packages
./05-make-bootable
./06-create-image
```
