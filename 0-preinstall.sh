#!/usr/bin/env bash
#-----------------------------------#
#  ___            _    _ __ _  ___  #
# | . | _ _  ___ | |_ | / // ||_ _| #
# |   || '_>/ | '| . ||  \ | | | |  #
# |_|_||_|  \_|_.|_|_||_\_\|_| |_|  #
#                                   #
#-----------------------------------#

echo "-------------------------------------------------"
echo "     Setting up mirrors for optimal download     "
echo "-------------------------------------------------"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -Sy pacman-contrib terminus-font --noconfirm --needed
setfont ter-v22b
sed -i 's/^#Para/Para/' /etc/pacman.conf
pacman -S reflector rsync --noconfirm --needed
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -e "-----------------------------------"
echo -e "  ___            _    _ __ _  ___  "
echo -e " | . | _ _  ___ | |_ | / // ||_ _| "
echo -e " |   || '_>/ | '| . ||  \ | | | |  "
echo -e " |_|_||_|  \_|_.|_|_||_\_\|_| |_|  "
echo -e "   Waiting to select Hard disk     "
echo -e "        Please standby........     "
echo -e "-----------------------------------"
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

echo -e "\nInstalling prereqs...\n$HR"
pacman -S btrfs-progs --noconfirm --needed

echo "-------------------------------------------------"
echo "         select your disk to format              "
echo "-------------------------------------------------"
lsblk
echo "Please enter disk to work on: (/dev/nvme0n1)"
read DISK
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
read -p "are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in

y|YES)
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on drive
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:301M ${DISK} # partition 1 (EFI), default start block, 300MB
sgdisk -n 2:0:0 ${DISK} # partition 2 (Root), default start, remaining

# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}

# label partitions
sgdisk -c 1:"EFI" ${DISK}
sgdisk -c 2:"ROOT" ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFI" "${DISK}p1"
mkfs.btrfs -L "ROOT" "${DISK}p2" -f
mount -t btrfs "${DISK}p2" /mnt
else
mkfs.vfat -F32 -n "EFI" "${DISK}1"
mkfs.btrfs -L "ROOT" "${DISK}2" -f
mount -t btrfs "${DISK}2" /mnt
fi
ls /mnt | xargs btrfs subvolume delete
btrfs subvolume create /mnt/@
umount /mnt
;;
esac

# mount target /
mount -t btrfs -o subvol=@ -L ROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat -L UEFISYS /mnt/boot/
echo "--------------------------------------"
echo "     Arch Install on Main Drive       "
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "--------------------------------------"
echo "   Bootloader Grub Installation       "
echo "--------------------------------------"
pacman -S grub grub-btrfs efibootmgr --noconfirm --needed
grub-install --target=x86_64-efi --efi-directory=/boot/efi --boot-loader-id=GRUB
grub-mkconifg -o /boot/grub/grub.cfg
[ ! -d "/mnt/boot/loader/entries" ] && mkdir -p /mnt/boot/loader/entries
cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch Linux  
linux /vmlinuz-linux  
initrd  /initramfs-linux.img  
options root=LABEL=ROOT rw rootflags=subvol=@
EOF
cp -R ~/ArchK1T /mnt/root/
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo "--------------------------------------"
echo "     SYSTEM READY FOR 1-setup         "
echo "--------------------------------------"
