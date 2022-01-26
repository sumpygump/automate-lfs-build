# automate-lfs-build

This repository is a set of script which can be used to automate LFS build. It
follows the suggested flow from version 8.4 of teh Linux From Scratch book
which you can find at linuxfromscratch.org:
https://linuxfromscratch.org/museum/lfs-museum/8.4/LFS-BOOK-8.4-HTML/index.html

### Requirements

Install the basic required packages in a debian based distribution using the following command:

`$ apt install build-essential bison texinfo gawk git python2.7 kpartx -y`

### Scripts

Scripts must be executed in the same order as shown below

* 01-version-check.sh
    - This should be first script which should be executed, make sure there are no errors before proceding further.

* 02-setup-lfs-user
    - This script is responsible for creating lfs user and setting up bash for lfs.

* 03-build-toolchain
    - This script is responsible for setting up toolchain, must be executed with lfs user permission.

* 04-build-packages
    - This script is responsible for building minimum linux with busybox

* 05-create-image
    - This is optional script for creating an ISO image.


### Notes

* The scripts have been tested only on Ubuntu 18.04.1 LTS

* iso image has been tested with qemu using below command\
`$ qemu-system-x86_64 -drive format=raw,file=$LFS/iso/lfs.iso -nographic -enable-kvm -m 512M`

* Below procedure should work seemlessly, considering LFS env has been set
```
$ mkdir -p $LFS/automate-lfs-build
$ git clone https://github.com/ranjithum/automate-lfs-build $LFS/automate-lfs-build
$ cd $LFS/automate-lfs-build
$ mkdir -p $LFS/lfs-source; wget --input-file=./lfs-packages.txt --continue --directory-prefix=$LFS/lfs-source
$ ./01-version-check.sh
$ ./02-setup_lfs_user
$ su - lfs
$ cd automate-lfs-build
$ ./03-build_toolchain
$ exit
$ ./04-build_packages
$ ./05-create_image
```
