# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.


Описание моих действий

На своей машине создаем папку hw01 заходим в нее
делаем git clone  https://github.com/dmitry-lyutenko/manual_kernel_update .
vi Vagrantfile. Меняем cpus => 4,
vagrant up
vagrant ssh
uname -r 
  3.10.0-1127.el7.x86_64

качаем wget исходники ядра

cd /usr/src/kernel/ && sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.17.9.tar.xz


5. распаковываем 
sudo tar xvf linux-5.17.9.tar.xz
cd linux-5.17.9.tar.xz

6. копируем текущие параметры ядра
cp /boot/config-3.10.0-1127.el7.x86_64 .oldconfig

sudo make oldconfig

получаем ошибки gcc command not found
flex command not found
bison command not found

sudo yum install gcc gcc-c++ flex bison

sudo make oldconfig

*** Compiler is too old.
***   Your GCC version:    4.8.5
***   Minimum GCC version: 5.1.0

7. Обновляем компилятор на gcc-7.3.0
создаем папку /usr/src/gcc/ и переходим в нее
sudo mkdir /usr/src/gcc
cd /usr/src/gcc

качаем gcc-7.3.0
sudo wget http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.gz
распаковываем, заходим в папку, качаем недостающие части, задаем параметры компилятора, собираем, устанавливаем
sudo tar zxf gcc-7.3.0.tar.gz
sudo cd gcc-7.3.0
sudo ./contrib/download_prerequisites
sudo ./configure --disable-multilib --enable-languages=c,c++
sudo make -j 4
sudo make install

проверяем версию
gcc --version
но видим все ту же gcc 4.8.5
удаляем ее sudo yum remove gcc.x86_64
проверяем теперь версию
gcc --version - получаем gcc (GCC) 7.3.0

8. Собираем ядро
переходим в папку с исходниками ядра
sudo make oldconfig

получаем ошибку, что компилятор не найден
выполняем команду, для размещения ссылки на новый компилятор в стандартном месте
sudo ln -s /usr/local/bin/gcc /usr/bin/gcc

sudo make oldconfig
получаем вопросы о параметрах сборки ядра
отвечаю все по умолчанию
далее sudo make
ошибка openssl/opensslv.h no such file or directory
ставим sudo yum install openssl
ошибка не исчезла
ставим sudo yum install openssl-devel
теперь новая ошибка bc: command not found
sudo yum install bc
gelf.h no such file
гуглим, не хватает elfutis-libelf-devel. Ставим
пробуем снова sudo make
ошибка perl command not found
sudo yum install perl -y
sudo make -j 4
готово. Запускаем sudo make install
получаем множеественные ошикбки о отстутствии модулей, папки с модулями и пр
пробуем 
sudo make modules_install
пробуем sudo make install
готово
в /boot/ видим ядро vmlinuz-5.17.9
пробуем перезагрузку sudo reboot
vagrant ssh
uname -r 
3.10.0...
пробуем задать первое ярдо для загрузки
sudo grub2-set-default 0
sudo reboot
vagrant ssh
uname -r
5.17.9 есть!

=====================

Теперь проделываем то же самое, но через packer скрипты
Меняем centos.json файл, указываем 4 cpus

меняем скрипт packer/scripts/stage-1-kernel-update.sh
добавляем туда все, что описано выше, но несколько оптимизированнее^
установка пакетов пачками
копирование старых параметров ядра через шаблон 
cp /boot/config-* .oldconfig
makd oldconfig заменяем на make olddefconfig



запускаем 
packer build centos.json
не работает, ругает на формат
делаем packer fix centos.json > centos_fixed.json
переименновывем файл
mv centos_fixed.json centos.json
пробуем еще раз
packer build centos.json

по итогу работы получаем файл centos-7.7.1908-kernel-5-x86_64-Minimal.box
тестируем его через
vagrant box add --name centos-7-5-src centos-7.7.1908-kernel-5-x86_64-Minimal.box
создаем папку test
зайдем в нее и запустим vagrant init centos-7-5-src
vagrant up
vagrant ssh
uname -r
5.17.9

теперь загружаем образ в облако
vagrant cloud publish --release nussnk/centos-7-5-src 1.0 virtualbox /home/nikolay/ohw01/manual_kernel_update/centos-7.7.1908-kernel-5-x86_64-Minimal.box

============
теперь разбираемся с shared folder

при создании бокса, наш виртуалка удалилась
но у нас теперь есть ее образ
правим Vagrantfile - меняем имя бокса на nussnk/centos-7-5-src
vagrant up

заходим
vagrant ssh
надо установить linux guest addition
если VBoxGuestAddition.iso нет в системе, то качаем 
sudo wget https://download.virtualbox.org/virtualbox/6.1.34/VBoxGuestAdditions_6.1.34.iso
sudo mkdir /mnt/vbg
монтируем sudo mount VBoxGuestAdditions_6.1.34.iso /mnt/vbg
запускаем sudo /mnt/vbg/VBoxLinuxAdditions.run
происходит установка нужных компонентов
по завершении делаем vagrant halt
правим VagrantFile
меняем 
 config.vm.synced_folder ".", "/vagrant", disabled: true
на 
 config.vm.synced_folder ".", "/vagrant", disabled: false

vagrant up
после старта вм имеем realtime синхронизацию текущей папки на хосте с папкой /vagrant в вм

создадим новый box. Прописываем все, что сделали для shared folder в stage-2-vboxguestadd.sh файл
переименновываем файл stage-2-clean.sh в stage-3-clean.sh
обновляем в centos.json список скриптов для провиженинга
а также меняем параметр start_retry_timeout с 1 на 5 минут, иначе получаем ошибку при сборке между 1 и 2 скприптом провиженинга
и запускаем packer build centos.json

получаем box, загружаем его в vagrant облако
vagrant cloud publish --release nussnk/centos-7-5-src-shared_folder 1.0 virtualbox /home/nikolay/otus/ohw01/packer/centos-7.7.1908-kernel-5-x86_64-Minimal.box
удаляем box с диска, чтобы не тянуть его в git

правим Vagrantfile
указываем наш образ nussnk/centos-7-5-src-shared_folder



git add .
git commit -am "update from src and with shared folder"
git push

