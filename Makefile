all: cmake-build docker-build

install-m1-mac:
	. ./bin/install_m1.sh

cmake-build:
	bash build.sh

docker-build:
	mkdir -p cmake/build/lib
	cp /usr/local/lib/libconservator-framework.so cmake/build/lib
	cp /usr/local/lib/libazure-core.so cmake/build/lib
	cp /usr/local/lib/libazure-storage-blobs.so cmake/build/lib
	cp /usr/local/lib/libazure-storage-common.so cmake/build/lib
	cp /usr/lib/x86_64-linux-gnu/libpython3.7m.so.1.0 cmake/build/lib
	sudo docker rmi -f masterworker
	docker build -t masterworker -t mapreduceteam2.azurecr.io/masterworker -f k8s/Dockerfile .
	docker push mapreduceteam2.azurecr.io/masterworker:latest

cluster-up:
	kind create cluster --name local
	mkdir -p ${HOME}/tmp
	TMPDIR=${HOME}/tmp/ kind load docker-image -n local masterworker
	bash cluster.sh up local

cluster-down:
	bash cluster.sh down local
	kind delete cluster --name local

cluster-up-az:
	bash cluster.sh up azure

cluster-down-az:
	bash cluster.sh down azure

cluster-apply:
	bash cluster.sh apply local

cluster-apply-az:
	bash cluster.sh apply azure

clean:
	rm -rf cmake/

clean-all: clean
	rm -rf ./src/protos/*.cc
	rm -rf ./src/protos/*.h
	rm -rf ./src/protos/*.py

install:
	bash install.sh
