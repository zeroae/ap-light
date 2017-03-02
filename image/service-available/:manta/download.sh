#!/bin/bash -e

LC_ALL=C
DEBIAN_FRONTEND=noninteractive

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if [ -z $(which python) ]; then
    apt-get install python
fi

if [ -z $(which pip) ]; then
   curl -Lvo get-pip.py https://bootstrap.pypa.io/get-pip.py
   python get-pip.py
   rm -f get-pip.py
fi

apt-get install -y python-dev gcc
apt-get install -y libffi-dev libssl-dev
pip --no-cache-dir install manta==2.6.0

mv $DIR/assets/mantash.local $AP_ROOT/tool
ln -s $AP_ROOT/tool/mantash.local /sbin

apt-get remove -y python-dev gcc
apt-get autoremove -y

exit 0
