set -e

# echo $SHELL
# cat /etc/shells

apt install -y curl wget
apt install -y zsh
chsh -s /bin/zsh
# theme: bira
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

