
#Build

```
git clone https://github.com/MYIR-TI/oe-layersetup.git -b develop_ym62x_V11.01.05.03
cd oe-layersetup
./oe-layertool-setup.sh -f configs/processor-sdk/myir-processor-sdk-scarthgap-11.01.05.03-myd-ym62x-config.txt
cd build
. conf/setenv

MACHINE=<machine> bitbake -k tisdk-default-image

```



