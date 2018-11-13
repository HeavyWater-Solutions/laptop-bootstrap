#!/usr/bin/env bash

set -x

# Boot strap the xcode tools
xcode-select -p
if [[ $? != 0 ]]; then
  xcode-select --install
fi

# configure git
read -r -p "Enter your heavywater.com email: " HW_EMAIL
git config --global user.email "$HW_EMAIL"

read -r -p "Enter your name as you want to display: " HW_NAME
git config --global user.name "$HW_NAME"

read -r -p "Enter your GitHub UserName: " HW_GITHUB_USER
git config --global github.username "$HW_GITHUB_USER"

if [ ! -f ~/.ssh/id_rsa ]; then
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

read -r -p "$HW_GITHUB_USER($HW_EMAIL) mfa: " OTP

curl -X POST -H "X-GitHub-OTP: $OTP" https://api.github.com/user/keys -u "$HW_GITHUB_USER" -d \
"{\"title\": \"$KEY_NAME\", \"key\": \"$KEY_VALUE\"}"


mkdir ~/dev
cd ~/dev
git clone ssh://git@github.com/HeavyWater-Solutions/hw-cli.git

./dev/hw-cli/process/laptop-install.sh
