#### 1. ubuntu18.04 安装 vmware

> Build environment error! A required application is missing and Modconfig can not continue. xzCheck the log for more details.

```bash
sudo apt-get install gcc g++ make automake
sudo apt-get install libaio1 libglib2.0-dev

sudo vmware-modconfig --console --install-all
```

