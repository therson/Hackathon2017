createSAMCluster() {
	#Import cluster
	export CLUSTER_ID=$(curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/clusters -d '{"name":"'$CLUSTER_NAME'","description":"Demo Cluster","ambariImportUrl":"http://'$AMBARI_HOST':8080/api/v1/clusters/'$CLUSTER_NAME'"}'| grep -Po '\"id\":([0-9]+)'|grep -Po '([0-9]+)')

	#Import cluster config
	curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/cluster/import/ambari -d '{"clusterId":'$CLUSTER_ID',"ambariRestApiRootUrl":"http://'$AMBARI_HOST':8080/api/v1/clusters/'$CLUSTER_NAME'","password":"admin","username":"admin"}'
}

createSAMCluster