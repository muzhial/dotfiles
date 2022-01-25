set -e

if [ $1 -eq 1 ]; then
echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="muzhi"/' ~/.zshrc
source ~/.zshrc
fi

git clone https://github.com/muzhichan/dotfiles.git ~/.dotfiles
cp ~/.dotfiles/muzhi.zsh-theme ~/.oh-my-zsh/themes/

if [ $2 -eq  1 ]; then
echo "===> install tmux"
sudo apt update
sudo apt install -y tmux
## oh my tmux config
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
cd $HOME
ln -s -f .tmux/.tmux.conf
cp ~/.dotfiles/.tmux.conf.local .
fi

if [ $3 -eq 1 ];then
echo "===> install python modules"
pip install mmcv-full==1.4.0
# cd /data/mmsegmentation && pip install -e .
# cd /data/mmclassification && pip install -e .
fi

cd $HOME

