#!/usr/bin/env bash

set -ex

# Boot strap the xcode tools
xcode-select -p
if [[ $? != 0 ]]; then
  xcode-select --install
fi

# configure git
read -r HW_EMAIL -p "Enter your heavyWater.com email"
git config --global user.email "$HW_EMAIL"

read -r HW_NAME -p "Enter your name as you want to display"
git config --global user.name "$HW_NAME"

read -r HW_GITHUB_USER -p "Enter your GitHub UserName"
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
KEY_NAME=$(uname -n | sed 's/\.local//' | cat "$HW_EMAIL - ")

read -r OTP -p "$HW_GITHUB_USER($HW_EMAIL) mfa: "

curl -X POST -H "X-GitHub-OTP: $OTP" https://api.github.com/user/keys -u "$HW_GITHUB_USER" -d \
"{\"title\": \"$KEY_NAME\", \"key\": \"$KEY_VALUE\"}"
