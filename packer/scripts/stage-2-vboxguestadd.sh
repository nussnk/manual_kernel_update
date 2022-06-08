#!/bin/bash

echo "================== stage2 start"
echo "`df -h`"
echo "================== sudo mkdir /mnt/vbg"
sudo mkdir /mnt/vbg
echo "================== cd ~"
cd ~
echo "================== sudo wget https://download.virtualbox.org/virtualbox/6.1.34/VBoxGuestAdditions_6.1.34.iso"
sudo wget https://download.virtualbox.org/virtualbox/6.1.34/VBoxGuestAdditions_6.1.34.iso
echo "================== sudo mount ~/VBoxGuestAdditions_6.1.34.iso /mnt/vbg"
sudo mount ~/VBoxGuestAdditions_6.1.34.iso /mnt/vbg
echo "================== sudo /mnt/vbg/VBoxLinuxAdditions.run"
sudo /mnt/vbg/VBoxLinuxAdditions.run
#echo "================== sudo reboot"
#sudo reboot

