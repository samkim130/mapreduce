# Script to build your protobuf, c++ binaries, and docker images here

numprocs=$(nproc)

proto_dir=./src/protos

protoc --proto_path=${proto_dir} --cpp_out=${proto_dir} ${proto_dir}/masterworker.proto
protoc --proto_path=${proto_dir} --grpc_out=${proto_dir} --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin  ${proto_dir}/masterworker.proto

protoc --proto_path=${proto_dir} --cpp_out=${proto_dir} --python_out=${proto_dir} ${proto_dir}/userinterface.proto
protoc --proto_path=${proto_dir} --grpc_out=${proto_dir} --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin --grpclib_python_out=${proto_dir} ${proto_dir}/userinterface.proto

rm -rf cmake/build
mkdir -p cmake/build
cd cmake/build
# cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl ../..
cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl -DCMAKE_BUILD_TYPE=Debug ../..
make -j ${numprocs}

cd ../..
