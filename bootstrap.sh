#!/usr/bin/env bash

# configure git
echo "Enter your heavyWater.com email"
read -r HW_EMAIL
git config --global user.email "$HW_EMAIL"

echo "Enter your name as you want to display"
read -r HW_NAME
git config --global user.name "$HW_NAME"

echo "Enter your GitHub UserName"
read -r HW_GITHUB_USER
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

# curl -X POST -H "X-GitHub-OTP: 567453" https://api.github.com/user/keys -u "$HW_GITHUB_USER" -d "{
#   \"title\": \"$HW_EMAIL\",
#   \"key\": \"ssh-rsa AAA...\"
# }"
echo "Follow the instructions for installing your key:
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/"
