#!/bin/bash

echo "Report run on `date`"
echo ""

# determine docker id of rancher
DOCKER_ID=$(docker ps | grep "rancher/rancher:v2" | cut -d' ' -f1)

if [ -z "$DOCKER_ID" ]
then
  echo "Could not find Rancher 2 container, exiting..."
  exit -1
fi

echo "Rancher version: $(docker exec rancher-server kubectl get settings server-version --no-headers -o custom-columns=version:value)"
echo ""

docker exec ${DOCKER_ID} kubectl get clusters -o custom-columns=ClusterId:metadata.name,Name:spec.displayName,K8sVersion:spec.rancherKubernetesEngineConfig.kubernetesVersion,Created:metadata.creationTimestamp,Nodes:status.appliedSpec.rancherKubernetesEngineConfig.nodes[*].address

CLUSTER_IDS=$(docker exec ${DOCKER_ID} kubectl get clusters --no-headers -o custom-columns=id:metadata.name)

for ID in $CLUSTER_IDS
do
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "Cluster: ${ID}"
  docker exec ${DOCKER_ID} kubectl get nodes.management.cattle.io -n $ID -o custom-columns=NodeId:metadata.name,Address:status.rkeNode.address,Role:status.rkeNode.role[*],CPU:status.internalNodeStatus.capacity.cpu,RAM:status.internalNodeStatus.capacity.memory,OS:status.dockerInfo.OperatingSystem,DockerVersion:status.dockerInfo.ServerVersion,Created:metadata.creationTimestamp
done
