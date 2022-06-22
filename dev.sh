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
sudo apt update --allow-insecure-repositories
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
    apt update --allow-insecure-repositories
    apt install neovim -y
fi


# ---------
# for gddi dev env
# ---------
if [[ ${install_list} =~ "gddi" ]]; then
    echo -e "\n===> install gddi env"
    # sudo apt-key del 7fa2af80
    # wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb
    # sudo dpkg -i cuda-keyring_1.0-1_all.deb && rm cuda-keyring_1.0-1_all.deb
    # sudo rm /etc/apt/sources.list.d/cuda.list

    echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
    source ~/.zshrc
fi

