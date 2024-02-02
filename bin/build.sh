# Script to build your protobuf, c++ binaries, and docker images here

numprocs=1

proto_dir=./src/protos

unameOut="$(uname -s)"
case "${unameOut}" in
   Linux*)
      numprocs=$(nproc)
      grpc_plugin_dir=/usr/local/bin/grpc_cpp_plugin
      openssl_dir=/usr/local/opt/openssl
      ;;
   Darwin*)
      numprocs=$(sysctl -n hw.physicalcpu i)
      grpc_plugin_dir=/opt/homebrew/bin/grpc_cpp_plugin
      export PATH="$HOME/.pyenv/versions/3.7.17/bin:$PATH"
      openssl_dir=/opt/homebrew/opt/openssl
      ;;
   #  CYGWIN*)    grpc_plugin_dir=Cygwin;;
   #  MINGW*)     grpc_plugin_dir=MinGw;;
   #  MSYS_NT*)   grpc_plugin_dir=Git;;
    *)          grpc_plugin_dir="UNKNOWN:${unameOut}"
esac
# echo ${grpc_plugin_dir}

protoc --proto_path=${proto_dir} --cpp_out=${proto_dir} ${proto_dir}/masterworker.proto
protoc --proto_path=${proto_dir} --grpc_out=${proto_dir} --plugin=protoc-gen-grpc=${grpc_plugin_dir}  ${proto_dir}/masterworker.proto

protoc --proto_path=${proto_dir} --cpp_out=${proto_dir} --python_out=${proto_dir} ${proto_dir}/userinterface.proto
protoc --proto_path=${proto_dir} --grpc_out=${proto_dir} --plugin=protoc-gen-grpc=${grpc_plugin_dir} --grpclib_python_out=${proto_dir} ${proto_dir}/userinterface.proto

rm -rf cmake/build
mkdir -p cmake/build
cd cmake/build
# cmake -DOPENSSL_ROOT_DIR=${openssl_dir} ../..
cmake -DOPENSSL_ROOT_DIR=${openssl_dir} -DCMAKE_BUILD_TYPE=Debug ../..
make -j ${numprocs}

cd ../..
