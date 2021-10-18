if [[ ${install_list} =~ "zsh" ]]; then
    echo "===> install zsh"
    sudo apt install -y \
        curl \
	wget \
	zsh
    sudo chsh -s /bin/zsh
    # theme: bira | murilasso | rgm
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="rgm"/' ~/.zshrc
    source ~/.zshrc
fi


if [[ ${install_list} =~ "dev" ]]; then
    echo "===> install tmux"
    sudo apt update
    sudo apt install -y tmux
    ## oh my tmux config
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    cd $HOME
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    ## config .tmux.cong.local set mouse mode
    sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local


    echo "===> install python modules"
    pip install mmcv-full
    cd /data/mmsegmentation && pip install -e .
    cd /data/mmclassification && pip install -e .
fi

