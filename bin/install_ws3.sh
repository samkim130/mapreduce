!#/bin/bash

apt-get update
apt-get install ca-certificates curl apt-transport-https lsb-release gnupg


mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
  gpg --dearmor |
  tee /etc/apt/keyrings/microsoft.gpg > /dev/null
chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    tee /etc/apt/sources.list.d/azure-cli.list

apt-get update
apt-get install azure-cli


## for user cli
apt-get install -y python3.7 python3.7-dev python3-pip libffi-dev
python3.7 -m pip install cffi
python3.7 -m pip install azure-storage-blob

## for python grpc
python3.7 -m pip install grpcio
python3.7 -m pip install grpcio-tools
python3.7 -m pip install grpclib protobuf

