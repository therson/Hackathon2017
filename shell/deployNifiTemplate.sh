#!/bin/bash

export AMBARI_HOST=$(hostname -f)
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

getNifiHost () {
       	NIFI_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI/components/NIFI_MASTER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $NIFI_HOST
}

export NIFI_HOST=$(getNifiHost)
export ROOTPATH='~'
echo "export NIFI_HOST=$NIFI_HOST" >> ~/.bash_profile
echo "export ROOTPATH=$ROOTPATH" >> ~/.bash_profile



deployTemplateToNifi () {
       	TEMPLATE_DIR=$1
       	TEMPLATE_NAME=$2
       	
       	echo "*********************************Importing NIFI Template..."
       	# Import NIFI Template HDF 3.x
       	# TEMPLATE_DIR should have been passed in by the caller install process
       	sleep 1
       	TEMPLATEID=$(curl -v -F template=@"$TEMPLATE_DIR" -X POST http://$NIFI_HOST:9090/nifi-api/process-groups/root/templates/upload | grep -Po '<id>([a-z0-9-]+)' | grep -Po '>([a-z0-9-]+)' | grep -Po '([a-z0-9-]+)')
       	sleep 1

       	# Instantiate NIFI Template 3.x
       	echo "*********************************Instantiating NIFI Flow..."
       	curl -u admin:admin -i -H "Content-Type:application/json" -d "{\"templateId\":\"$TEMPLATEID\",\"originX\":100,\"originY\":100}" -X POST http://$NIFI_HOST:9090/nifi-api/process-groups/root/template-instance
       	sleep 1

       	# Rename NIFI Root Group HDF 3.x
       	echo "*********************************Renaming Nifi Root Group..."
       	ROOT_GROUP_REVISION=$(curl -X GET http://$NIFI_HOST:9090/nifi-api/process-groups/root |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)')

       	sleep 1
       	ROOT_GROUP_ID=$(curl -X GET http://$NIFI_HOST:9090/nifi-api/process-groups/root|grep -Po '("component":{"id":")([0-9a-zA-z\-]+)'| grep -Po '(:"[0-9a-zA-z\-]+)'| grep -Po '([0-9a-zA-z\-]+)')

       	PAYLOAD=$(echo "{\"id\":\"$ROOT_GROUP_ID\",\"revision\":{\"version\":$ROOT_GROUP_REVISION},\"component\":{\"id\":\"$ROOT_GROUP_ID\",\"name\":\"$TEMPLATE_NAME\"}}")

       	sleep 1
       	curl -d $PAYLOAD  -H "Content-Type: application/json" -X PUT http://$NIFI_HOST:9090/nifi-api/process-groups/$ROOT_GROUP_ID

}


configureNifiTempate () {
	GROUP_TARGETS=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/process-groups/root/process-groups | grep -Po '\"uri\":\"([a-z0-9-://.]+)' | grep -Po '(?!.*\")([a-z0-9-://.]+)')
    length=${#GROUP_TARGETS[@]}
    echo $length
    echo ${GROUP_TARGETS[0]}

    #for ((i = 0; i < $length; i++))
    for GROUP in $GROUP_TARGETS
    do
       	#CURRENT_GROUP=${GROUP_TARGETS[i]}
       	CURRENT_GROUP=$GROUP
       	echo "***********************************************************calling handle ports with group $CURRENT_GROUP"
       	handleGroupPorts $CURRENT_GROUP
       	echo "***********************************************************calling handle processors with group $CURRENT_GROUP"
       	handleGroupProcessors $CURRENT_GROUP
       	echo "***********************************************************done handle processors"
    done

    ROOT_TARGET=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/process-groups/root| grep -Po '\"uri\":\"([a-z0-9-://.]+)' | grep -Po '(?!.*\")([a-z0-9-://.]+)')

    handleGroupPorts $ROOT_TARGET

    handleGroupProcessors $ROOT_TARGET
}


echo "********************************* Deploying Nifi Template"
deployTemplateToNifi $ROOT_PATH/Hackathon2017/nifi/SyslogDemo-Hackaton.xml  MachineLog-Demo











