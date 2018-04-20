importSAMTopology () {
	SAM_DIR=/root/Hackathon2017/SAM/MachineLogAnalytics-v0.json
	TOPOLOGY_NAME=MachineLog-Demo
	#Import Topology
	sed -r -i 's;\{\{HOST1\}\};'$AMBARI_HOST';g' $SAM_DIR
	sed -r -i 's;\{\{CLUSTERNAME\}\};'$CLUSTER_NAME';g' $SAM_DIR
 
	export TOPOLOGY_ID=$(curl -F file=@$SAM_DIR -F 'topologyName='$TOPOLOGY_NAME -F 'namespaceId='$NAMESPACE_ID -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/actions/import| grep -Po '\"id\":([0-9]+)'|grep -Po '([0-9]+)')

    echo $TOPOLOGY_ID
}

importSAMTopology