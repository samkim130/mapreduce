#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
numprocs=$(cat /proc/cpuinfo | grep processor | wc -l)

echo "Installing Casablanca"
sudo apt-get install -y g++ git libboost-all-dev libwebsocketpp-dev openssl libssl-dev ninja-build libxml2-dev uuid-dev libunittest++-dev libcurl4-openssl-dev 
# sudo apt-get install -y libcpprest
cd ~/src
git clone https://github.com/Microsoft/cpprestsdk.git casablanca
cd casablanca
mkdir build
cd build
cmake -G Ninja .. -DCMAKE_BUILD_TYPE=Release
ninja
# cd Release/Binaries
# ./test_runner *_test.so
sudo ninja install

echo "Creating the CMake Find file"
cd /tmp
wget https://raw.githubusercontent.com/Azure/azure-storage-cpp/master/Microsoft.WindowsAzure.Storage/cmake/Modules/LibFindMacros.cmake
sudo mv LibFindMacros.cmake /usr/local/share/cmake-3.19/Modules
sudo wget https://raw.githubusercontent.com/Azure/azure-storage-cpp/master/Microsoft.WindowsAzure.Storage/cmake/Modules/FindCasablanca.cmake
sudo mv FindCasablanca.cmake /usr/local/share/cmake-3.19/Modules
wget https://raw.githubusercontent.com/Tokutek/mongo/master/cmake/FindSSL.cmake
sudo mv FindSSL.cmake /usr/local/share/cmake-3.19/Modules


echo "Install Azure Storage CPP"
cd ~/src
git clone https://github.com/Azure/azure-sdk-for-cpp/
cd azure-sdk-for-cpp/
mkdir -p build/
cd build/
cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=on
cmake --build .
sudo make install
cd ..
mkdir -p build-static/
cd build-static/
cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_STATIC_LIBS=on
cmake --build .
sudo make install
sudo ldconfig


echo "Install Cpp network lib"
cd ~/src
git clone https://github.com/cpp-netlib/cpp-netlib.git
cd cpp-netlib
git checkout 0.13-release
git submodule init
git submodule update
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_COMPILER=gcc   \
      -DCMAKE_CXX_COMPILER=g++ \
      -DCPP-NETLIB_BUILD_TESTS=OFF \
      ../
make -j${numprocs}
# As of version 0.9.3, cpp-netlib produces three static libraries. Using GCC on Linux these are:
#   libcppnetlib-client-connections.a
#   libcppnetlib-server-parsers.a
#   libcppnetlib-uri.a
# Users can find them in ~/cpp-netlib-build/libs/network/src.

echo "Install rapid json"
cd ~/src
git clone https://github.com/Tencent/rapidjson.git
cd rapidjson
git submodule update --init
mkdir -p build
cd build
cmake ../
make -j${numprocs} install
