#!/bin/zsh
set -e

brew update
brew upgrade

# assumes xcode command line tools are installed
# xcode-select --install

# dev packages
brew install cmake cmake-docs
brew install pkgconf check wget openssl

# essentials
brew install protobuf grpc
brew install docker
brew install kubectl kind helm
brew install zookeeper etcd
brew install glog rapidjson


# may need to override PATH
# export PATH="/opt/homebrew/Cellar:$PATH"

# optional if using zookeeper
numprocs=$(sysctl -n hw.physicalcpu i)

echo "Installing Conservator C++ Zookeeper Wrapper"
sudo mkdir -p /usr/local/src
pushd ./
cd /usr/local/src
sudo git clone git@github.com:gatech-projects-samkim/conservator.git
cd conservator
git config --global --add safe.directory /usr/local/src/conservator
sudo git checkout macversion
sudo cmake .
sudo make -j${numprocs}
popd

# python (use 3.7)
brew install -f pyenv
pyenv install 3.7
export PATH="$HOME/.pyenv/versions/3.7.17/bin:$PATH"
python -m pip install grpcio grpcio-tools grpclib protobuf

# TODO azure