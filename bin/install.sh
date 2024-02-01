#!/bin/bash

# docker stuff
sudo apt update -y
sudo apt-get install -y curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update -y
apt-cache policy docker-ce

# install deps
sudo apt-get install -y nmap bridge-utils openvswitch-switch apt-transport-https ca-certificates software-properties-common docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker ${USER}

# This install script is for debian based linux distributions only
numprocs=$(nproc)
if [ "$1" != "zk" ] && [ "$1" != "etcd" ]
then 
	echo "Please provide 'zk' or 'etcd' as an argument to this script"
        exit
fi	
#Install CMake

sudo apt-get install -y g++ zookeeper libboost-all-dev ant check build-essential autoconf libtool pkg-config checkinstall git zlib1g libssl-dev
if [ "$1" == "zk" ]
then
	sudo apt-get install zookeeper libzookeeper-mt2 zookeeperd zookeeper-bin libzookeeper-mt-dev
fi
echo "Instaling cmake 3.0+"
mkdir -p ~/src
cd ~/src
sudo apt-get remove -y cmake
wget http://www.cmake.org/files/v3.19/cmake-3.19.5.tar.gz
tar xf cmake-3.19.5.tar.gz
cd cmake-3.19.5
./configure
make -j${numprocs}
sudo checkinstall -y --pkgname cmake
echo "PATH=/usr/local/bin:$PATH" >> ~/.profile
source ~/.profile


# Install Kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install go (for Kind)
mkdir -p ~/src
cd ~/src
wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install Kind
git clone https://github.com/kubernetes-sigs/kind
cd kind
make
make install
cp bin/kind /usr/local/bin/

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

if [ "$1" == "zk" ]
then
#Install Conservator
echo "Installing Conservator C++ Zookeeper Wrapper"
mkdir -p ~/src
cd ~/src
git clone https://github.com/rjenkins/conservator.git
cd conservator
cmake .
make -j${numprocs}
sudo checkinstall -y --pkgname conservator
fi

# Install C++ GRPC
echo "Installing GRPC"
mkdir -p ~/src
cd ~/src
git clone --recurse-submodules -b v1.35.0 https://github.com/grpc/grpc
cd grpc
mkdir -p cmake/build
cd cmake/build
cmake \
	  -DCMAKE_BUILD_TYPE=Release \
	    -DgRPC_INSTALL=ON \
	      -DgRPC_BUILD_TESTS=OFF \
	        -DgRPC_SSL_PROVIDER=package \
		  ../..
make -j${numprocs}
sudo checkinstall -y --pkgname grpc
sudo ldconfig

if [ "$1" == "etcd"]
then
#Install cpprestsdk
mkdir -p ~/src
cd ~/src
git clone https://github.com/microsoft/cpprestsdk.git
cd cpprestsdk
mkdir build && cd build
cmake .. -DCPPREST_EXCLUDE_WEBSOCKETS=ON -DBUILD_SHARED_LIBS=on
make -j2 && sudo make install
cd ..
mkdir build-static && cd build-static
cmake .. -DCPPREST_EXCLUDE_WEBSOCKETS=ON -DBUILD_SHARED_LIBS=off
make -j2 && sudo make install





#install etcd client
mkdir -p ~/src
cd ~/src
git clone https://github.com/etcd-cpp-apiv3/etcd-cpp-apiv3.git
cd etcd-cpp-apiv3
mkdir build && cd build
cmake ..
make -j2 && sudo make install
mkdir build-static && cd build-static
cmake .. -DBUILD_SHARED_LIBS=off -DBUILD_STATIC_LIBS=on
make -j2 && sudo make install
fi




#install GLOG
mkdir -p ~/src
cd ~/src
git clone https://github.com/google/glog.git
cd glog
cmake -H. -Bbuild -G "Unix Makefiles"
cmake --build build
cmake --build build --target test
sudo cmake --build build --target install
cmake -H. -DBUILD_SHARED_LIBS=off -DBUILD_STATIC_LIBS=on -Bbuild-static -G "Unix Makefiles"
cmake --build build-static
cmake --build build-static --target test
sudo cmake --build build-static --target install

echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

# Clean up
sudo rm kubectl
sudo rm kubectl.sha256
