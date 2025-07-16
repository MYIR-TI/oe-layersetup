

# Build
```
./oe-layertool-setup.sh -f configs/processor-sdk/myir-processor-sdk-11.00.15.05-am62lxx-config.txt
cd build
. conf/setenv
MACHINE=<machine> bitbake -k tisdk-default-image
```
