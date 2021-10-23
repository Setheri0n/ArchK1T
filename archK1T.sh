#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/ArchK1T/1-setup.sh
    source /mnt/root/ArchK1T/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchK1T/2-user.sh
    arch-chroot /mnt /root/ArchK1T/3-post-setup.sh