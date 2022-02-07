set -e

if [ $1 -eq 1 ]; then
    cp ~/.dotfiles/muzhi.zsh-theme ~/.oh-my-zsh/themes/
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="muzhi"/' ~/.zshrc

    echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
    source ~/.zshrc
fi

if [ $2 -eq 1 ];then
echo "===> install python modules"
pip install mmcv-full==1.4.0
# cd /data/mmsegmentation && pip install -e .
# cd /data/mmclassification && pip install -e .
pip install scikit-learn \
    scipy\
    tensorboard \
    pycocotools
fi

cd $HOME

