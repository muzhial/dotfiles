set -e

echo "PATH=/opt/conda/bin:$PATH"

sudo apt-key del 7fa2af80
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb && rm cuda-keyring_1.0-1_all.deb
sudo rm /etc/apt/sources.list.d/cuda.list
