#!/bin/bash

dnf -y install epel-release
dnf -y groupinstall Xfce
systemctl disable gdm
systemctl set-default graphical

dnf -y install libglvnd-devel elfutils-libelf-devel
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) nouveau.modeset=0"

systemctl isolate graphical

dnf -y install tigervnc-server
useradd msadmin
usermod --password $(echo "M1cr0s0ft2020" | openssl passwd -1 -stdin) msadmin
mkdir -p ~msadmin/.vnc
cat <<EOF> ~msadmin/.vnc/config
session=xfce
geometry=1200x800
localhost
alwaysshared
EOF
echo "M1cr0s0ft2020" | vncpasswd -f > ~msadmin/.vnc/passwd
chown -R msadmin:msadmin ~msadmin/.vnc/
chmod 0600 ~msadmin/.vnc/passwd

cat <<EOF>> /etc/tigervnc/vncserver.users
:0=msadmin
:1=msadmin
EOF
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:0.service
systemctl enable vncserver@:0 --now

## Install NoVNC 
dnf -y install snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install novnc
sleep 5
snap install novnc
nohup /snap/bin/novnc --vnc localhost:5900 --listen 6080 &
snap set novnc services.n6082.listen=6080 services.n6082.vnc=localhost:5900




