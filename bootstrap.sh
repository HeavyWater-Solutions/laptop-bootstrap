#!/usr/bin/env bash

# Check admin permission
echo "Checking admin permissions. Enter your user password:"
sudo echo "Admin permission configured"
if [ $? -ne 0 ]; then
  echo "FAILED on missing admin permissions"
  exit 1
fi

# Boot strap the xcode tools
xcode-select -p &> /dev/null
if [[ $? != 0 ]]; then
  xcode-select --install
fi

# SSH connectivity to github.
if nc -w 1 -z github.com "22" &> /dev/null; then
  echo "SSH access to github.com possible"
else
  echo "Unable to SSH to github.com, if you are on VPN disconnect, otherwise check with the network administrator"
  exit 1
fi

# Fail script on status codes other than 0.
set -e

# configure git
read -r -p "Enter your GitHub UserName: " HW_GITHUB_USER
git config --global github.username "$HW_GITHUB_USER"

if curl -i -s -u $HW_GITHUB_USER https://api.github.com/user | grep "X-GitHub-OTP: required" > /dev/null; then
  echo "MFA successful"
else
  echo "MFA unsuccessful - check github.com account or your OTP"
  exit 1
fi

read -r -p "Enter your heavywater.com email: " HW_EMAIL
git config --global user.email "$HW_EMAIL"

read -r -p "Enter your name as you want to display: " HW_NAME
git config --global user.name "$HW_NAME"

if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "\nLeave SSH key blank, enter desired SSH password.\n"
    ssh-keygen -q -t rsa -b 4096 -C "GitHub: $HW_GITHUB_USER <$HW_EMAIL>"
fi

eval "$(ssh-agent -s)"

cat >> ~/.ssh/config <<'EOF'
Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/id_rsa
EOF

ssh-add -K ~/.ssh/id_rsa

KEY_VALUE=$(cat ~/.ssh/id_rsa.pub)
MACHINE_NAME=$(uname -n | sed 's/\.local//')
KEY_NAME="$HW_EMAIL - $MACHINE_NAME"

echo -e "\nWait for fresh MFA code, enter MFA code & GitHub password before it expires.\n"

read -r -p "$HW_GITHUB_USER($HW_EMAIL) mfa: " OTP

curl -X POST -H "X-GitHub-OTP: $OTP" https://api.github.com/user/keys -u "$HW_GITHUB_USER" -d \
"{\"title\": \"$KEY_NAME\", \"key\": \"$KEY_VALUE\"}"


mkdir ~/dev
cd ~/dev
git clone ssh://git@github.com/HeavyWater-Solutions/hw-cli.git
cd ~
./dev/hw-cli/process/laptop-install.sh 2>&1 | tee ~/install-$(date +%Y%m%d-%H%M%S).log
