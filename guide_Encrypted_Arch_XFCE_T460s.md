# Encrypted Arch Linux installation on a T460s with the XFCE desktop environment
This guide is ment to provide step by step instructions on how to get a fully functioning Arch Linux installation.

## Changelog
| Date | Comment |
| ------ | ------ |
| 2020/05/01 | Initial creation |

## Preparations
- disable Secure Boot and make sure your system boots in UEFI mode
- up to date Arch Linux ISO

## Preface
This guide assumes the target for installation is a Lenovo Laptop (i. e. T460s). It is highly recommended to have another computer ready from which you can ssh into the target. This makes the installation quite a lot easier.

## Step 1 - Prepare ssh access
1. Boot from USB
2. Change the keyboard layout if necessary: `loadkeys de-latin1`
3. Change the root password: `passwd`
4. Connect to Wi-Fi: `wifi-menu`
5. Start the ssh server: `systemctl start sshd.service`
6. (Use `ip addr` to get your IP)
7. You can now connect via ssh

## Step 2 - Prepare the disk
1. Sync the clock: `timedatectl set-ntp true`
2. The following commands wipe the disk and create the required labels. It creates a 512mb partition for the EFI bootloader and uses the remaining available space for root & user. A swap file will be created later on. 
3. Start fdisk: `fdisk /dev/sda`
4. Create a gpt partition table: `g`
5. Create the boot partition: `n,enter,enter,+512M`
6. Create the root partition: `n,enter,enter,enter`
7. Assign the EFI label: `t,1,1`
8. Assign the Linux label `t,2,24`
9. Write the changes: `w`

## Step 3 - LUKS encryption
1. Set up the encryption. You will be asked to enter a password. **Try to avoid special characters if your keyboard isn't english!** `cryptsetup -y -v luksFormat /dev/sda2`
2. Open the partition: `cryptsetup open /dev/sda2 cryptroot`
4. Format the partition: `mkfs.ext4 /dev/mapper/cryptroot`
5. Mount the partition: `mount /dev/mapper/cryptroot /mnt`

## Step 4 - Prepare the boot partition
1. Format the partition: `mkfs.fat -F32 /dev/sda1`
2. Create the boot directory: `mkdir /mnt/boot`
3. Mount the partition: `mount /dev/sda1 /mnt/boot`

## Step 5 - Install Arch Linux
1. Download Arch, the Linux kernel and an editor. VIM is highly recommended, but can be switch with nano for example. A short guide on how to use VIM will be given in a few paragraphs. `pacstrap /mnt base base-devel linux linux-firmware vim`
2. Create the fstab file: `genfstab -U /mnt >> /mnt/etc/fstab`
3. Chroot into the installed system: `arch-chroot /mnt`

## VIM Guide
- Open Documents: vim textfile.txt
- Enter writing mode: "i"
- Exit writing mode: "Esc"
- Save and quit a document: exit writing mode and type "!wq", press enter
- Force quit without saving: "!q"
- Delete lines: exit writing mode and type "dd"

## Step 6 - Configure the bootloader
1. Install the bootloader: `bootctl install`
2. Open mkinitcpio.conf: `vim /etc/mkinitcpio.conf`
3. Search for the HOOKS=() line and make sure it looks like this: HOOKS=(base **udev** autodetect **keyboard keymap** consolefont modconf block **encrypt** filesystems fsck)
4. Open the bootloader config: `cd /boot/loader`, `vim loader.conf`
5. Replace all entries with: 
```
timeout 3
default arch
```
6. Create a new entry for Arch: `cd entries`, `vim arch.conf`
7. Add the following lines. Use `:r !blkid` in VIM to find the correct UUID for dev/sda2 to replace "xyz" with
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options rw cryptdevice=UUID=xyz:cryptroot root=/dev/mapper/cryptroot
```
8. Create the ramdisk with: `mkinitcpio -p linux`
9. Navigate back: `cd ~`

## Step 7 - Swap
1. Create and activate the swapfile by executing the following commands:
```
fallocate -l 8GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```
2. Open the fstab file: `vim /etc/fstab`
3. Add `/swapfile none swap defaults 0 0` at the end of the file

## Step 8 - Timezone & Locale
1. Set the correct timezone: `ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime`
2. Sync the clock: `hwclock --systohc`
3. Open locale.gen `vim /etc/locale.gen` and uncomment "en_US.UTF-8", then run `locale-gen`
4. Open locale.conf `vim /etc/locale.conf` and add `LANG=en_US.UTF-8`
5. Open vconsole.conf `vim /etc/vconsole.conf` and add your keyboard layout: `KEYMAP=de-latin1-nodeadkeys`

## Step 9 - Hostname
1. Open /etc/hostname `vim /etc/hostname` and add your desired hostname: `T460s`
2. Open /etc/hosts and add the following lines:
```
127.0.0.1	localhost
::1			localhost
127.0.1.1	T460s.localdomain	T460s
```

## Step 10 - Finishing steps
1. Set the root password: `passwd`
2. Install the network manager and other useful tools: `pacman -S efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant mtools dosfstools linux-headers`
3. Exit: `exit`
4. Unmount: `umount -a`
5. Reboot: `reboot`
6. Login as root with the previously set password

## Step 11 - Set up networking
1. Start and enable the Network Manager: `systemctl start NetworkManager`, `systemctl enable NetworkManager`
2. Connect to Wi-Fi again: `nmtui`, activate connection

## Step 12 - Create a user
1. Replace "xyz" with your desired name: `useradd -m -G wheel xyz`
2. Set a password: `passwd xyz`
3. Add the user to the sudo group by opening `EDITOR=vim visudo` and uncommenting the `%wheel ALL=(ALL) ALL` line

## Step 13 - Graphics
1. Install the Intel video drivers: `pacman -S xf86-video-intel`
2. Install the xorg server (Just press Enter): `pacman -S xorg`

## Step 14 - Desktop Environment
This guide uses XFCE, since basically everything works out of the box on ThinkPads.
1. Install XFCE and additional packages: `pacman -S xfce4 xfce4-goodies`
2. Install additional file manager functionality: `sudo pacman -S gvfs`
3. Install an audio interface: `sudo pacman -S pavucontrol`
4. Exit `exit` and login with your user

## Step 15 - Finishing steps #2
1. Open the xinitrc `vim .xinitrc` and add `exec startxfce4`
2. Add acpi support for laptops: `pacman -S acpid`
3. Activate: `sudo systemctl enable acpid`
4. Create user folders by installing `sudo pacman -S xdg-user-dirs`, then run `xdg-user-dirs-update`
5. Reboot once more `reboot`

## Step 16 - Done!
Congrats, you now have a fully functional Arch Linux installation. There isn't a login manager installed, you can enter XFCE by `startx`.