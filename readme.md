
#Build

```
git clone https://migit.goho.co/MYD-YM62X-Linux/oe-layersetup.gitg
cd oe-layersetup
./oe-layertool-setup.sh -f configs/processor-sdk/myir-processor-sdk-scarthgap-11.01.05.03-am62x-config.txt
cd build
. conf/setenv

MACHINE=<machine> bitbake -k tisdk-default-image
```



