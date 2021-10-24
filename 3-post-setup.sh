#!/usr/bin/env bash
#-----------------------------------#
#  ___            _    _ __ _  ___  #
# | . | _ _  ___ | |_ | / // ||_ _| #
# |   || '_>/ | '| . ||  \ | | | |  #
# |_|_||_|  \_|_.|_|_||_\_\|_| |_|  #
#                                   #
#-----------------------------------#

echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------

echo -e "\nEnabling Login Display Manager"

sudo systemctl enable sddm.service

echo -e "\nSetup SDDM Theme"

sudo cat <<EOF > /etc/sddm.conf
[Theme]
Current=Nordic
EOF

# ------------------------------------------------------------------------

echo -e "\nEnabling the cups service daemon so we can print and sync time and allow networking"

systemctl enable cups.service
sudo systemctl enable NetworkManager.service
sudo ntpd -qg

echo ###############################################################################
echo #                           Cleaning                                          #
echo ###############################################################################

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo 
echo ###############################################################################
echo #          Done - Please Eject Install Media and Reboot                       #
echo ###############################################################################
