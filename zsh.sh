if command -v zsh > /dev/null 2>&1; then
    sudo chsh -s /bin/zsh
    zsh
    echo $SHELL
    echo -e "\n===> exists zsh"
    echo "===> install oh-my-zsh"
    # sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sh dockerfile/install.sh --unattended
else
    echo -e "\n===> install zsh"
    sudo apt install -y zsh
    sudo chsh -s /bin/zsh
    zsh
    # theme: bira | murilasso | rgm
    echo "===> install oh-my-zsh"
    #sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sh dockerfile/install.sh --unattended
fi

cp ~/.dotfiles/muzhi.zsh-theme ~/.oh-my-zsh/themes/
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="muzhi"/' ~/.zshrc

source ~/.zshrc

