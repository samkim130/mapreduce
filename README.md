# Map Reduce

Improvement based on a previous school project.

## Installation
Run the install.sh script

The install script will do the following:
1. Install kubectl
2. Install protobuf
3. Install Kind
4. Install Helm
5. Install gRPC
6. Set up conservator
7. Install etcd/ZooKeeper

Let us know if you have any issues.

## Directory Structure

## Running

0. Create kind cluster `./init.sh`
1. Compile sources, prepare docker image, load it into kind: `./build.sh`
2. Start the k8s cluster with master and workers, 2 nodes each: `./cluster.sh up`
3. get master logs to inspect activity between nodes
3.1. Find pod named mr-master-xxxx: `kubectl get pods -n ws1`
3.2. Get lods: `kubectl logs [mr-master-xxx] -n ws1`, add flag `-f` to stream logs


## Sharding and Files

We have 3 containers for the inputs (mapreduce), intermediary files from the map phase and the output container for the final results from the reduce phase.
Once we have set of inputs blobs in the mapreduce container, the master will take those blobs, take their sizes and produce list of [Shard](../workshop1-c/src/master/models/shards.h) that consist of [ShardFragment](../workshop1-c/src/master/models/shards.h). Each ShardFragment points to a blob and the start and end offsets in it. This means that a shard can span multiple blobs, in the cases where the sharding cannot evenly split a single blob into the predefined shard size.

Once the sharding is done, we create the Map and Reduce [Jobs](../workshop1-c/src/master/models/jobs.h) that will present a workload for the workers. First we run
the map phase where we try to complete all MapJobs, along the way we feed the outputs from the map jobs to the ReduceJobs as inputs. Next we start the reduce phase on the available workers.

Once the reduce jobs finish, the results are stored in the outputs container in azure.

# Testing
`curl "10.244.0.9:50049?M=2&R=4&files=lorem.txt&mr_functions=mr_functions.py"`

Alternatively,

`kubectl port-forward svc/mr-proxy -n ws1 8080:8080`

`curl "http://localhost:8080?M=2&R=4&files=lorem.txt&mr_functions=mr_functions.py"`


Newest version
`python3.7 user_client.py -d folder -m mapper.py -r reducer.py -M 10 -R 3`
For -d option, don't include the '/' at the end, the script will get all files in that dir and upload it


