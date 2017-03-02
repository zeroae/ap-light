#!/usr/bin/env python
import paramiko
import os
import stat

manta_state_dir=os.path.join(os.environ['AP_STATE_DIR'], 'manta')

if not os.path.exists(manta_state_dir):
    os.makedirs(manta_state_dir, 0755);

if not os.path.exists('/root/.ssh'):
    os.makedirs('/root/.ssh', 0755)

private_key=os.environ['MANTA_PRIVATE_KEY'].replace('#', '\n')
with open('/root/.ssh/id_rsa', 'w') as f:
    f.write(private_key)
os.chmod('/root/.ssh/id_rsa', stat.S_IREAD)

key=paramiko.rsakey.RSAKey.from_private_key_file('/root/.ssh/id_rsa')
with open('/root/.ssh/id_rsa.pub', 'w') as f:
    f.write(key.get_base64())
