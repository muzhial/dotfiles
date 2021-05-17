set -e

CURRENT_DIR=`pwd`

apt update
apt install -y tmux

## oh my tmux config
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
cd $HOME
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
## config .tmux.cong.local set mouse mode
sed -i 's/#set -g mouse on/set -g mouse on/' .tmux.conf.local

