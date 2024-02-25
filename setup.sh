#!/bin/bash
#set -e


# Usage:
# ./dev.sh --ssh_pw <pw> tmux ...


# sudo='sudo'
CWD=`pwd`
FILE_PATH=$(readlink -f "$0")
ROOT_DIR=$(dirname "$FILE_PATH")

#default_list=()
#default_len=${#default_list[@]}
#if [ ${default_len} -gt 0 ]; then
#    install_list=${default_list}
#else
#    install_list="$@"
#fi

# cmd args
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--extension)
      EXTENSION="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--searchpath)
      SEARCHPATH="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    --nosu)
      NOSU=true
      shift
      ;;
    --ssh_pw)
      SSHD_PW="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

install_list=${POSITIONAL_ARGS[@]}

if [ "$NOSU" = true ]; then
    sudo=''
else
    sudo='sudo'
fi


# ----- function -----
check_shell() {
    zshell=$(echo $0 | grep "zsh")
    bashell=$(echo $0 | grep "bash")
    if [[ $zshell != "" ]]; then
	    return 0
    fi
    if [[ $bashell != "" ]]; then
	    return 1
    fi
}


is_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        # echo "$1 is installed."
        return 0  # true
    else
        # echo "$1 is not installed."
        return 1  # false
    fi
}


check_and_install() {
    local flag_update=false
    for arg in "$@"; do
        echo "-> install $arg"
        if ! is_cmd $arg; then
            if [ "$flag_update" = false ]; then
                $sudo apt update --allow-insecure-repositories
                flag_update=true
            fi
            $sudo apt install -y $arg
        fi
    done
}


# common utils
check_and_install wget curl htop zip unzip zsh tmux


if [[ ${install_list} =~ "zsh" ]]; then
    # $sudo apt install zsh -y
    # TODO: not working, the SHELL not changed
    # $sudo chsh -s $(which zsh)
    # $sudo usermod -s $(which zsh) $(whoami)

    # Install On-My-Zsh
    if [ ! -d $HOME/.oh-my-zsh ]; then
        sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
    fi

    cp $ROOT_DIR/zoo/mz.zsh-theme $HOME/.oh-my-zsh/themes/
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="mz"/' $HOME/.zshrc
fi


if [[ ${install_list} =~ "pip" ]]; then
    echo -e "-> config pip source"
    mkdir -p $HOME/.pip
    cp $ROOT_DIR/zoo/pip.conf $HOME/.pip
fi


if [[ ${install_list} =~ "tmux" ]]; then
    # $sudo apt install tmux -y
    echo -e "-> config tmux"
    #if [ ! -d $HOME/.tmux ]; then
        #git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    #fi
    cp -r $ROOT_DIR/.tmux $HOME
    ## oh my tmux config
    cd $HOME
    ln -s -f .tmux/.tmux.conf
    cp $ROOT_DIR/zoo/.tmux.conf.local .
    cd $CWD
    ## config .tmux.cong.local set mouse mode
    #sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local
fi


if [[ ${install_list} =~ "neovim" ]]; then
    ## neovim
    echo -e "-> install neovim"
    $sudo apt-get install software-properties-common
    $sudo add-apt-repository ppa:neovim-ppa/unstable
    $sudo apt update --allow-insecure-repositories
    $sudo apt install neovim -y
fi


if [[ ${install_list} =~ "ssh" ]]; then
    $sudo apt install openssh-server -y
    echo -e "-> config ssh"
    # in docker container should start sshd service:
    # `service ssh start`

    # cp $_cwd_/zoo/ssh_config ~/.ssh/config

    # openssh-server settings
    mkdir -p /var/run/sshd
    echo "root:$SSHD_PW" | chpasswd
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    #echo "export VISIBLE=now" >> /etc/profile
fi


# ---------
# source dev env
# ---------
if [[ ${install_list} =~ "env" ]]; then
    echo -e "-> source env"
    # sudo rm /etc/apt/sources.list.d/cuda.list

    #$sudo usermod -s $(which zsh) $(whoami)

    # gddi env
    if check_shell; then
        echo -e "-> in zsh"
        # config my zsh
        # cp $_cwd_/mz.zsh-theme ~/.oh-my-zsh/themes/
        # sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="mz"/' ~/.zshrc
        # source ~/.zshrc

	    if is_cmd conda; then
	        echo "PATH=/opt/conda/bin:$PATH" >> $HOME/.zshrc
	        source $HOME/.zshrc
	    fi
    else
	    echo -e "-> in bash"
        source $HOME/.bashrc

	    if is_cmd conda; then
	        echo "PATH=/opt/conda/bin:$PATH" >> $HOME/.bashrc
            source $HOME/.bashrc
	    fi
    fi
fi


if [[ ${install_list} =~ "fzf" ]]; then
    echo -e "-> install fzf"
    if [ -d $HOME/.fzf ]; then
        rm -rf $HOME/.fzf
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    yes | $HOME/.fzf/install
fi
