set -e
# TODO: git failed, retry specified times

CURRENT_DIR=`pwd`
GIT_REPO_LIST=(
    ~/.tmux
)

default_list=()
default_len=${#default_list[@]}
if [ ${default_len} -gt 0 ]; then
    install_list=${default_list}
else
    install_list="$@"
fi

# common utils
echo -e "\n===> apt install tools"
sudo apt update
sudo apt install -y \
    wget curl tmux


echo -e "\n===> rm thirdparty git repo first"
for repo in ${GIT_REPO_LIST[@]}; do
    if [ -d $repo ]; then
        rm -rf $repo
    fi
done


if [[ ${install_list} =~ "pip" ]]; then
    echo -e "\n===> config pip source"
    mkdir -p ~/.pip
    cp pip.conf ~/.pip
fi


if [[ ${install_list} =~ "tmux" ]]; then
    echo -e "\n===> config tmux"
    ## oh my tmux config
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    cd $HOME
    ln -s -f .tmux/.tmux.conf
    cp ~/.dotfiles/.tmux.conf.local .
    ## config .tmux.cong.local set mouse mode
    #sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local
fi


if [[ ${install_list} =~ "neovim" ]]; then
    ## neovim
    echo -e "\n===> install neovim"
    apt-get install software-properties-common
    add-apt-repository ppa:neovim-ppa/unstable
    apt update
    apt install neovim -y
fi


#if [[ ${install_list} =~ "zsh" ]]; then
    ## zsh
    #if command -v zsh > /dev/null 2>&1; then
    #    echo -e "\n===> exists zsh"
    #    echo "===> install oh-my-zsh"
    #    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    #else
    #    echo -e "\n===> install zsh"
    #    sudo apt install -y zsh
    #    sudo chsh -s /bin/zsh
    #    # theme: bira | murilasso | rgm
    #    echo "===> install oh-my-zsh"
    #    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    #fi

    #cp ~/.dotfiles/muzhi.zsh-theme ~/.oh-my-zsh/themes/
    #sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="muzhi"/' ~/.zshrc
#fi

