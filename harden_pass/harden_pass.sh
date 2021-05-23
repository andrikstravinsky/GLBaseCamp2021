#!/bin/bash

sudo su
apt install -y libpam-cracklib
sed 's/\bpam_cracklib.so\b/& enforce_for_root reject_username/' /etc/pam.d/common-password
