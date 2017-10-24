#!/bin/bash

export AMBARI_HOST=$(hostname -f)
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

getNifiHost () {
       	NIFI_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI/components/NIFI_MASTER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $NIFI_HOST
}

export NIFI_HOST=$(getNifiHost)
export ROOT_PATH='~'
echo "export NIFI_HOST=$NIFI_HOST" >> ~/.bash_profile
echo "export ROOT_PATH=$ROOT_PATH" >> ~/.bash_profile



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

    echo "*********************************  Updating and Starting Controller Services..."
    handleControllerServices

    ROOT_TARGET=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/process-groups/root| grep -Po '\"uri\":\"([a-z0-9-://.]+)' | grep -Po '(?!.*\")([a-z0-9-://.]+)')

    echo "*********************************  Starting Processors..."
    handleGroupProcessors $ROOT_TARGET
}


handleControllerServices () {

    ID_PROCESSGROUP=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/process-groups/root |grep -Po '"id":"([a-zA-z0-9\-]+)'|grep -Po ':"([a-zA-z0-9\-]+)'|grep -Po '([a-zA-z0-9\-]+)'|head -1)
    echo "Process Group ID: $RECORD_READER"

    #schema-registry -> HortonworksSchemaRegistry
    SCHEMA_REGISTRY=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/flow/process-groups/$ID_PROCESSGROUP/controller-services |grep -Po '"schema-registry":"[a-zA-Z0-9-]+'|grep -Po ':"[a-zA-Z0-9-]+'|grep -Po '[a-zA-Z0-9-]+'|head -1)
    REVISION_SCHEMA_REGISTRY=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/controller-services/$SCHEMA_REGISTRY |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)' |head -1)
    echo "Schema Registry ID: $SCHEMA_REGISTRY"
    echo "Schema Registry REV: $REVISION_SCHEMA_REGISTRY"

    curl -u admin:admin -i -H "Content-Type:application/json" -X PUT -d "{\"id\":\"$SCHEMA_REGISTRY\",\"revision\":{\"version\":$REVISION_SCHEMA_REGISTRY},\"component\":{\"id\":\"$SCHEMA_REGISTRY\",\"state\":\"ENABLED\",\"properties\":{\"url\":\"http:\/\/$AMBARI_HOST:7788\/api\/v1\"}}}" http://$AMBARI_HOST:9090/nifi-api/controller-services/$SCHEMA_REGISTRY

    #record-reader -> CSVReader
    RECORD_READER=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/flow/process-groups/$ID_PROCESSGROUP/controller-services |grep -Po '"record-reader":"[a-zA-Z0-9-]+'|grep -Po ':"[a-zA-Z0-9-]+'|grep -Po '[a-zA-Z0-9-]+'|head -1)
    REVISION_RECORD_READER=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/controller-services/$RECORD_READER |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)' |head -1)
    echo "Schema Registry ID: $RECORD_READER"
    echo "Schema Registry REV: $REVISION_RECORD_READER"

    curl -u admin:admin -i -H "Content-Type:application/json" -X PUT -d "{\"id\":\"$RECORD_READER\",\"revision\":{\"version\":$REVISION_RECORD_READER},\"component\":{\"id\":\"$RECORD_READER\",\"state\":\"ENABLED\"}}" http://$AMBARI_HOST:9090/nifi-api/controller-services/$RECORD_READER


    #record-writer -> AvroRecordSetWriter
    RECORD_WRITER=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/flow/process-groups/$ID_PROCESSGROUP/controller-services |grep -Po '"record-writer":"[a-zA-Z0-9-]+'|grep -Po ':"[a-zA-Z0-9-]+'|grep -Po '[a-zA-Z0-9-]+'|head -1)
    REVISION_RECORD_WRITER=$(curl -u admin:admin -i -X GET http://$AMBARI_HOST:9090/nifi-api/controller-services/$RECORD_WRITER |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)' |head -1)
    echo "Schema Registry ID: $RECORD_WRITER"
    echo "Schema Registry REV: $REVISION_RECORD_WRITER"

    curl -u admin:admin -i -H "Content-Type:application/json" -X PUT -d "{\"id\":\"$RECORD_WRITER\",\"revision\":{\"version\":$REVISION_RECORD_WRITER},\"component\":{\"id\":\"$RECORD_WRITER\",\"state\":\"ENABLED\"}}" http://$AMBARI_HOST:9090/nifi-api/controller-services/$RECORD_WRITER

}


handleGroupProcessors () {
    TARGET_GROUP=$1

    TARGETS=($(curl -u admin:admin -i -X GET $TARGET_GROUP/processors | grep -Po '\"uri\":\"([a-z0-9-://.]+)' | grep -Po '(?!.*\")([a-z0-9-://.]+)'))
    length=${#TARGETS[@]}
    echo $length
    echo ${TARGETS[0]}

    for ((i = 0; i < $length; i++))
    do
        ID=$(curl -u admin:admin -i -X GET ${TARGETS[i]} |grep -Po '"id":"([a-zA-z0-9\-]+)'|grep -Po ':"([a-zA-z0-9\-]+)'|grep -Po '([a-zA-z0-9\-]+)'|head -1)
        REVISION=$(curl -u admin:admin -i -X GET ${TARGETS[i]} |grep -Po '\"version\":([0-9]+)'|grep -Po '([0-9]+)')
        TYPE=$(curl -u admin:admin -i -X GET ${TARGETS[i]} |grep -Po '"type":"([a-zA-Z0-9\-.]+)' |grep -Po ':"([a-zA-Z0-9\-.]+)' |grep -Po '([a-zA-Z0-9\-.]+)' |head -1)
        echo "Current Processor Path: ${TARGETS[i]}"
        echo "Current Processor Revision: $REVISION"
        echo "Current Processor ID: $ID"
        echo "Current Processor TYPE: $TYPE"

        if ! [ -z $(echo $TYPE|grep "PublishKafka") ]; then
            echo "***************************This is a PutKafka Processor"
            echo "***************************Updating Kafka Broker Porperty and Activating Processor..."
            PAYLOAD=$(echo "{\"id\":\"$ID\",\"revision\":{\"version\":$REVISION},\"component\":{\"id\":\"$ID\",\"config\":{\"properties\":{\"bootstrap.servers\":\"$AMBARI_HOST:6667\"}},\"state\":\"RUNNING\"}}")
        else
            echo "***************************Activating Processor..."
            PAYLOAD=$(echo "{\"id\":\"$ID\",\"revision\":{\"version\":$REVISION},\"component\":{\"id\":\"$ID\",\"state\":\"RUNNING\"}}")
        fi
               echo "$PAYLOAD"
               curl -u admin:admin -i -H "Content-Type:application/json" -d "${PAYLOAD}" -X PUT ${TARGETS[i]}
        done
}





echo "********************************* Deploying Nifi Template"
#deployTemplateToNifi $ROOT_PATH/Hackathon2017/nifi/SyslogDemo-Hackaton.xml  MachineLog-Demo
deployTemplateToNifi /home/cloudbreak/Hackathon2017/nifi/SyslogDemo-Hackaton.xml  MachineLog-Demo

echo "********************************* Configuring Nifi Template"
configureNifiTempate



