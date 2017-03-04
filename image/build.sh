#!/bin/sh -ex

mkdir -p $AP_ROOT/service
mkdir -p $AP_ROOT/environment $AP_ROOT/environment/startup
chmod 700 $AP_ROOT/environment/ $AP_ROOT/environment/startup

groupadd -g 8377 docker_env

# dpkg options
cp $AP_ROOT/file/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
cp $AP_ROOT/file/dpkg_nolocales /etc/dpkg/dpkg.cfg.d/01_nolocales

# General config
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
MINIMAL_APT_GET_INSTALL='apt-get install -y --no-install-recommends'

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
echo -n no > $AP_ROOT/environment/INITRD

apt-get update

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## Install apt-utils.
$MINIMAL_APT_GET_INSTALL apt-utils python locales curl unzip ca-certificates jq

## Upgrade all packages.
apt-get dist-upgrade -y --no-install-recommends

# fix locale
locale-gen C.UTF-8
dpkg-reconfigure locales
/usr/sbin/update-locale LANG=C.UTF-8

echo -n C.UTF-8 > $AP_ROOT/environment/LANG
echo -n C.UTF-8 > $AP_ROOT/environment/LANGUAGE
echo -n C.UTF-8 > $AP_ROOT/environment/LC_CTYPE

# install PyYAML
tar -C $AP_ROOT/file/ -xvf $AP_ROOT/file/PyYAML-3.11.tar.gz
cd $AP_ROOT/file/PyYAML-3.11/
python setup.py install
cd -

apt-get autoremove -y
apt-get clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

# Remove useless files
rm -rf $AP_ROOT/file
rm -rf $AP_ROOT/build.sh $AP_ROOT/Dockerfile
