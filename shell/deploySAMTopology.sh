#!/bin/bash

export ROOT_PATH=~
export AMBARI_HOST=$(hostname -f)
export ZK_HOST=$AMBARI_HOST
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

createKafkaTopics () {
	
	/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --zookeeper $ZK_HOST:2181 --create --topic syslog_pam_avro_v7 --partitions 1 --replication-factor 1
}

getStormUIHost () {
        STORMUI_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/STORM/components/STORM_UI_SERVER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

        echo $STORMUI_HOST
}

createStormView () {
	STORMUI_HOST=$(getStormUIHost)

	curl -u admin:admin -H "X-Requested-By:ambari" -X POST -d '{"ViewInstanceInfo":{"instance_name":"Storm_View","label":"Storm View","visible":true,"icon_path":"","icon64_path":"","description":"storm view","properties":{"storm.host":"'$STORMUI_HOST'","storm.port":"8744","storm.sslEnabled":"false"},"cluster_type":"NONE"}}' http://$AMBARI_HOST:8080/api/v1/views/Storm_Monitoring/versions/0.1.0/instances/Storm_View

}

createSAMCluster() {
        #Import cluster
        export CLUSTER_ID=$(curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/clusters -d '{"name":"'$CLUSTER_NAME'","description":"Demo Cluster","ambariImportUrl":"http://'$AMBARI_HOST':8080/api/v1/clusters/'$CLUSTER_NAME'"}'| grep -Po '\"id\":([0-9]+)'|grep -Po '([0-9]+)')

        #Import cluster config
        curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/cluster/import/ambari -d '{"clusterId":'$CLUSTER_ID',"ambariRestApiRootUrl":"http://'$AMBARI_HOST':8080/api/v1/clusters/'$CLUSTER_NAME'","password":"admin","username":"admin"}'
}

initializeSAMNamespace () {
	#Initialize New Namespace
	export NAMESPACE_ID=$(curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/namespaces -d '{"name":"test1","description":"test1","streamingEngine":"STORM"}'| grep -Po '\"id\":([0-9]+)'|grep -Po '([0-9]+)')

	#Add Services to Namespace
	curl -H "content-type:application/json" -X POST http://$AMBARI_HOST:7777/api/v1/catalog/namespaces/$NAMESPACE_ID/mapping/bulk -d '[{"clusterId":'$CLUSTER_ID',"serviceName":"STORM","namespaceId":'$NAMESPACE_ID'},{"clusterId":'$CLUSTER_ID',"serviceName":"HDFS","namespaceId":'$NAMESPACE_ID'},{"clusterId":'$CLUSTER_ID',"serviceName":"KAFKA","namespaceId":'$NAMESPACE_ID'},{"clusterId":'$CLUSTER_ID',"serviceName":"DRUID","namespaceId":'$NAMESPACE_ID'},{"clusterId":'$CLUSTER_ID',"serviceName":"HDFS","namespaceId":'$NAMESPACE_ID'},{"clusterId":'$CLUSTER_ID',"serviceName":"ZOOKEEPER","namespaceId":'$NAMESPACE_ID'}]'
}

importSAMTopology () {
	SAM_DIR=$1
	TOPOLOGY_NAME=$2
	#Import Topology
	sed -r -i 's;\{\{HOST1\}\};'$AMBARI_HOST';g' $SAM_DIR
	sed -r -i 's;\{\{CLUSTERNAME\}\};'$CLUSTER_NAME';g' $SAM_DIR
 
    	export TOPOLOGY_META=$(curl -F file=@$SAM_DIR -F 'topologyName='$TOPOLOGY_NAME -F 'namespaceId='$NAMESPACE_ID -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/actions/import)
    	#echo "TOPOLOGY_META=" $TOPOLOGY_META
	export TOPOLOGY_ID=$(echo $TOPOLOGY_META|grep -Po '\"id\":([0-9]+)'|grep -Po '([0-9]+)')
	#echo "TOPOLOGY_ID ="$TOPOLOGY_ID
	export VERSION_ID=$(echo $TOPOLOGY_META|grep -Po '\"versionId\":([0-9]+)'|grep -Po '([0-9]+)')
    	#echo "VERSION_ID="$VERSION_ID
}

deploySAMTopology () {
	TOPOLOGY_ID=$1
	VERSION_ID=$2

	#Deploy Topology
	echo "********** curl -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/versions/$VERSION_ID/actions/deploy"
	curl -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/versions/$VERSION_ID/actions/deploy
	
	#Poll Deployment State until deployment completes or fails
	echo "curl -X GET http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/deploymentstate"
	TOPOLOGY_STATUS=$(curl -X GET http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/deploymentstate | grep -Po '"name":"([A-Z_]+)'| grep -Po '([A-Z_]+)')
    sleep 2
    echo "TOPOLOGY STATUS: $TOPOLOGY_STATUS"
    LOOPESCAPE="false"
    if ! [[ "$TOPOLOGY_STATUS" == TOPOLOGY_STATE_DEPLOYED || "$TOPOLOGY_STATUS" == TOPOLOGY_STATE_DEPLOYMENT_FAILED ]]; then
    	until [ "$LOOPESCAPE" == true ]; do
            TOPOLOGY_STATUS=$(curl -X GET http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/deploymentstate | grep -Po '"name":"([A-Z_]+)'| grep -Po '([A-Z_]+)')
            if [[ "$TOPOLOGY_STATUS" == TOPOLOGY_STATE_DEPLOYED || "$TOPOLOGY_STATUS" == TOPOLOGY_STATE_DEPLOYMENT_FAILED ]]; then
                LOOPESCAPE="true"
            fi
            echo "*********************************TOPOLOGY STATUS: $TOPOLOGY_STATUS"
            sleep 2
        done
    fi
}

echo "********************************* Creating Kafka Topics"
createKafkaTopics

echo "********************************* Create Storm View"
createStormView

echo "********************************* Creating SAM Service Pool"
createSAMCluster

echo "********************************* Initializing SAM Namespace"
initializeSAMNamespace
echo "Namespaceid is:" $NAMESPACE_ID

echo "********************************* Import SAM Template"
TOPOLOGY_ID=$(importSAMTopology $ROOT_PATH/Hackathon2017/SAM/MachineLogAnalytics-v0.json MachineLog-Demo)
echo "Topology ID is:" $TOPOLOGY_ID
echo "Version ID is:" $VERSION_ID

echo "********************************* Deploy SAM Topology"
deploySAMTopology $TOPOLOGY_ID $VERSION_ID
