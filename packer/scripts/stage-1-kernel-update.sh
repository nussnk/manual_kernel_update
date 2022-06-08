#!/bin/bash

echo "==================let's start"
echo "`df -h`"
# ставим wget и качаем исходники ядра
echo "==================sudo yum install wget -y"
sudo yum install wget -y
echo "================== sudo mkdir /usr/src/kernel"
sudo mkdir /usr/src/kernel
echo "================== cd /usr/src/kernel/"
cd /usr/src/kernel/
echo "================== pwd"
pwd
echo "`df -h`"
echo "================== sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.17.9.tar.xz"
sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.17.9.tar.xz
echo "`df -h`"


# распаковываем 
echo "================== sudo tar xvf linux-5.17.9.tar.xz"
sudo tar xvf linux-5.17.9.tar.xz
ls
echo "================== sudo rm linux-5.17.9.tar.xz"
sudo rm linux-5.17.9.tar.xz
echo "================== cd linux-5.17.9"
cd linux-5.17.9
echo "================== pwd"
pwd

# копируем текущие параметры ядра
echo "sudo cp /boot/config-|uname -r| .oldconfig"
sudo cp /boot/config-`uname -r` .oldconfig
echo "cp result is $?"
echo "================== ls -la | grep .oldconfig"
ls -la | grep .oldconfig
echo "================== sudo yum install -y gcc gcc-c++ flex bison bzip2"
sudo yum install -y gcc gcc-c++ flex bison bzip2


# Обновляем компилятор на gcc-7.3.0
# создаем папку /usr/src/gcc/ и переходим в нее
echo "================== sudo mkdir /usr/src/gcc"
sudo mkdir /usr/src/gcc
echo "================== cd /usr/src/gcc"
cd /usr/src/gcc
echo "================== pwd"
pwd

# качаем gcc-7.3.0
echo "`df -h`"
echo "================== sudo wget http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.gz"
sudo wget http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.gz
# распаковываем, заходим в папку, качаем недостающие части, задаем параметры компилятора, собираем, устанавливаем
echo "`df -h`"
echo "================== sudo tar xvf gcc-7.3.0.tar.gz"
sudo tar xvf gcc-7.3.0.tar.gz
echo "================== sudo rm gcc-7.3.0.tar.gz"
sudo rm gcc-7.3.0.tar.gz
echo "pwd and ls"
pwd
ls
echo "`df -h`"
echo "================== cd gcc-7.3.0"
cd gcc-7.3.0
echo "are we in gcc now?"
echo "are we in gcc now?"
pwd
ls
echo "================== sudo ./contrib/download_prerequisites"
sudo ./contrib/download_prerequisites
echo "================== sudo ./configure --disable-multilib --enable-languages=c,c++"
sudo ./configure --disable-multilib --enable-languages=c,c++
echo "`df -h`"
echo "================== sudo make -j 16"
sudo make -j 16
echo "`df -h`"
echo "================== sudo make install"
sudo make install

# удаляем старую версию gcc
echo "================== sudo yum remove gcc.x86_64 -y"
sudo yum remove gcc.x86_64 -y
echo "================== sudo ln -s /usr/local/bin/gcc /usr/bin/gcc"
sudo ln -s /usr/local/bin/gcc /usr/bin/gcc

# получаем вопросы о параметрах сборки ядра
# отвечаю все по умолчанию
echo "================== cd /usr/src/kernel/linux-5.17.9"
cd /usr/src/kernel/linux-5.17.9
echo "`df -h`"
echo "================== sudo make olddefconfig "
sudo make olddefconfig 
echo "`df -h`"
# ставим доп пакеты необходимые для сборки ядра
echo "================== sudo yum install openssl openssl-devel bc elfutils-libelf-devel perl -y"
sudo yum install openssl openssl-devel bc elfutils-libelf-devel perl -y
echo "================== cd /usr/src/kernel/linux-5.17.9"
cd /usr/src/kernel/linux-5.17.9
echo "`df -h`"
echo "================== sudo make -j 16"
sudo make -j 16
echo "`df -h`"
echo "================== sudo make modules_install"
sudo make modules_install
echo "`df -h`"
echo "================== sudo make install"
sudo make install
echo "================== sudo grub2-set-default 0"
sudo grub2-set-default 0
echo "================== sudo shutdown -r now"
sudo shutdown -r now

