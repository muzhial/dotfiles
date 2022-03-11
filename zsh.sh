## zsh
# if [ $1 -eq 1 ]; then
if command -v zsh > /dev/null 2>&1; then
    echo -e "\n===> exists zsh"
    echo "===> install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo -e "\n===> install zsh"
    sudo apt install -y zsh
    sudo chsh -s /bin/zsh
    # theme: bira | murilasso | rgm
    echo "===> install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
fi
# fi

cp ~/.dotfiles/muzhi.zsh-theme ~/.oh-my-zsh/themes/
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="muzhi"/' ~/.zshrc

echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
# source ~/.zshrc
