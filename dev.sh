#set -e

sudo='sudo'
CURRENT_DIR=`pwd`

default_list=()
default_len=${#default_list[@]}
if [ ${default_len} -gt 0 ]; then
    install_list=${default_list}
else
    install_list="$@"
fi

# common utils
echo -e "\n===> apt install ..."
$sudo apt update --allow-insecure-repositories
$sudo apt install -y \
    wget curl tmux openssh-server \
    htop zip unzip


# echo -e "\n===> rm thirdparty git repo first"
# for repo in ${GIT_REPO_LIST[@]}; do
#     if [ -d $repo ]; then
#         rm -rf $repo
#     fi
# done

if [[ ${install_list} =~ "zsh" ]]; then
    $sudo apt install zsh -y
    $sudo chsh -s $(which zsh)

    # Install On-My-Zsh
    if [ ! -d $HOME/.oh-my-zsh ]; then
        sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
    fi

    cp ~/.dotfiles/mz.zsh-theme ~/.oh-my-zsh/themes/
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="mz"/' ~/.zshrc
    $sudo usermod -s $(which zsh) $(whoami)
fi


if [[ ${install_list} =~ "pip" ]]; then
    echo -e "\n===> config pip source"
    mkdir -p ~/.pip
    cp pip.conf ~/.pip
fi


if [[ ${install_list} =~ "tmux" ]]; then
    echo -e "\n===> config tmux"
    #if [ ! -d $HOME/.tmux ]; then
        #git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    #fi
    cp -r ~/.dotfiles/.tmux ~/
    ## oh my tmux config
    cd $HOME
    ln -s -f .tmux/.tmux.conf
    cp ~/.dotfiles/.tmux.conf.local .
    ## config .tmux.cong.local set mouse mode
    #sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local
fi


if [[ ${install_list} =~ "neovim" ]]; then
    ## neovim
    echo -e "\n===> install neovim"
    $sudo apt-get install software-properties-common
    $sudo add-apt-repository ppa:neovim-ppa/unstable
    $sudo apt update --allow-insecure-repositories
    $sudo apt install neovim -y
fi


if [[ ${install_list} =~ "ssh" ]]; then
    # in docker container should start sshd service:
    # `service ssh start`

    # openssh-server
    mkdir -p /var/run/sshd
    # echo 'root:muzhi' | chpasswd
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    echo "export VISIBLE=now" >> /etc/profile
fi


if [[ ${install_list} =~ "fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi


# ---------
# source dev env
# ---------
if [[ ${install_list} =~ "env" ]]; then
    echo -e "\n===> source env"
    # sudo rm /etc/apt/sources.list.d/cuda.list

    #cp ~/.dotfiles/mz.zsh-theme ~/.oh-my-zsh/themes/
    #sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="mz"/' ~/.zshrc
    #$sudo usermod -s $(which zsh) $(whoami)

    zshell=$(echo $SHELL | grep "zsh")
    bashell=$(echo $SHELL | grep "bash")
    # gddi env
    if [[ $zshell != "" ]]; then
        echo "in zsh"
	echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
	source ~/.zshrc
    fi
    if [[ $bashell != "" ]]; then
	echo "in bash"
        echo "PATH=/opt/conda/bin:$PATH" >> ~/.bashrc
        source ~/.bashrc
    fi
fi
