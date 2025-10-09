#!/bin/bash
set -e

CWD=`pwd`
FILE_PATH=$(readlink -f "$0")
ROOT_DIR=$(dirname "$FILE_PATH")

# cmd args
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--extension)
            EXTENSION="$2"
            shift # past argument
            shift # past value
            ;;
        --default)
            DEFAULT=YES
            shift # past argument
            ;;
        --su)
            SU=true; shift;;
        --ssh_pw)
            SSHD_PW="$2"
            shift
            shift
            ;;
        -h|--help)
            HELP=1
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

if [ "$HELP" -eq "1" ]; then
    echo "Usage: $0 [--ssh_pw your-pw ssh] [tmux] [zsh] [fzf]"
    echo "  --help or -h          : Print this help menu."
    exit;
fi

if [ "$SU" = true ]; then
    sudo='sudo'
else
    sudo=''
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
check_and_install wget curl htop zip unzip zsh tmux neovim


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


# config zsh / oh-my-zsh
if [[ ${install_list} =~ "zsh" ]]; then
    # $sudo apt install zsh -y

    # Set zsh as default shell
    echo "-> setting zsh as default shell"
    if [ "$SU" = true ]; then
        $sudo usermod -s $(which zsh) $(whoami)
    else
        chsh -s $(which zsh)
    fi

    echo "[INFO] Default shell changed to zsh. You may need to log out and log back in for the change to take effect."

    # Add fallback to automatically start zsh from bash
    echo "-> adding zsh fallback to .bashrc"
    if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Auto-start zsh if available and not already in zsh" >> "$HOME/.bashrc"
        echo 'if [ -x "$(command -v zsh)" ] && [ "$0" != "-zsh" ] && [ -z "$ZSH_VERSION" ]; then' >> "$HOME/.bashrc"
        echo '    exec zsh' >> "$HOME/.bashrc"
        echo 'fi' >> "$HOME/.bashrc"
    fi

    # Install On-My-Zsh (unattended installation to avoid interrupting script)
    echo "-> installing oh-my-zsh"
    if [ ! -d $HOME/.oh-my-zsh ]; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi

    # cp $ROOT_DIR/zoo/mz.zsh-theme $HOME/.oh-my-zsh/themes/
    # sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="mz"/' $HOME/.zshrc

    echo "-> config pure theme in zsh"
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

    # Add pure prompt configuration to .zshrc
    echo "# --- pure theme ---" >> "$HOME/.zshrc"
    echo "fpath+=(\$HOME/.zsh/pure)" >> "$HOME/.zshrc"
    echo "autoload -U promptinit; promptinit" >> "$HOME/.zshrc"
    echo "prompt pure" >> "$HOME/.zshrc"
fi


if [[ ${install_list} =~ "fzf" ]]; then
    echo -e "-> install fzf"
    if [ -d $HOME/.fzf ]; then
        rm -rf $HOME/.fzf
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
    yes | $HOME/.fzf/install
fi
