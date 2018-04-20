deploySAMTopology () {
	TOPOLOGY_ID=$1
	
	#Deploy Topology
	echo "********** curl -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/versions/$TOPOLOGY_ID/actions/deploy"
	curl -X POST http://$AMBARI_HOST:7777/api/v1/catalog/topologies/$TOPOLOGY_ID/versions/$TOPOLOGY_ID/actions/deploy
	
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

deploySAMTopology