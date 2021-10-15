set -e

CURRENT_DIR=`pwd`

default_list=()
default_len=${#default_list[@]}
if [ ${default_len} -gt 0 ]; then
    install_list=${default_list}
else
    install_list="$@"
fi

if [[ ${install_list} =~ "tmux" ]]; then
    echo "install tmux"
    apt update
    apt install -y tmux

    ## oh my tmux config
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    cd $HOME
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    ## config .tmux.cong.local set mouse mode
    sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local
fi

if [[ ${install_list} =~ "neovim" ]]; then
    ## neovim
    echo "install neovim"
    apt-get install software-properties-common
    add-apt-repository ppa:neovim-ppa/unstable
    apt update
    apt install neovim -y
fi

if [[ ${install_list} =~ "zsh" ]]; then
    ## zsh
    echo "install zsh"
    sudo apt install -y curl wget
    sudo apt install -y zsh
    sudo chsh -s /bin/zsh
    # theme: bira | murilasso | rgm
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

