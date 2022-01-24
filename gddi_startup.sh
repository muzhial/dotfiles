echo "PATH=/opt/conda/bin:$PATH" >> ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="rgm"/' ~/.zshrc
source ~/.zshrc


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
sed -i 's/tmux_conf_theme_status_left=" ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "/tmux_conf_theme_status_left=" #S "/' .tmux.conf.local
sed -i 's/tmux_conf_theme_status_right=" #{prefix}#{pairing}#{synchronized}#{?battery_status,#{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b | #{username}#{root} | #{hostname} "/tmux_conf_theme_status_right=" #{prefix}#{pairing}#{synchronized} | #{username}#{root} | #{hostname} "/' .tmux.conf.local
sed -i 's/tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_12"/tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_12"/' .tmux.conf.local
sed -i 's/tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_15"/tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_15"/' .tmux.conf.local


echo "===> install python modules"
pip install mmcv-full
cd /data/mmsegmentation && pip install -e .
cd /data/mmclassification && pip install -e .

cd $HOME

