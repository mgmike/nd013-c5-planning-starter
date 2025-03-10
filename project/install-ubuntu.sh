#! /bin/bash
sudo apt-get install libuv1-dev libssl-dev libz-dev libgoogle-glog-dev
git clone https://github.com/uWebSockets/uWebSockets 
cd uWebSockets
git checkout e94b6e1
mkdir build
cd build
cmake ..
make 
sudo make install
cd ..
cd ..
sudo rm -r uWebSockets
sudo ln -s /usr/lib64/libuWS.so /usr/lib/libuWS.so

pip3 install websocket-client