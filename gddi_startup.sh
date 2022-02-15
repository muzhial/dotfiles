set -e

echo "===> install python modules"
pip install mmcv-full==1.4.0
# cd /data/mmsegmentation && pip install -e .
# cd /data/mmclassification && pip install -e .
pip install scikit-learn \
    scipy\
    tensorboard \
    pycocotools

cd $HOME

