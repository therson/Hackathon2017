#!/bin/bash

export AMBARI_HOST=$(hostname -f)
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')


getRegistryHost () {
       	REGISTRY_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/REGISTRY/components/REGISTRY_SERVER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	
       	echo $REGISTRY_HOST
}


export REGISTRY_HOST=$(getRegistryHost)

echo "export REGISTRY_HOST=$REGISTRY_HOST" >> ~/.bash_profile

pushSchemasToRegistry (){
			echo "**************** creating shema ID******************"
 curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "type": "avro", "schemaGroup": "Kafka", "name": "syslog_pam_avro_v7", "description": "Syslog PAM Schema v7", "compatibility": "BACKWARD", "evolve": true }' 'http://$REGISTRY_HOST:7788/api/v1/schemaregistry/schemas'
 
                          echo "**************** updating schema ID******************"
 curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "description": "Syslog PAM Schema v7", "schemaText": "{\n \"type\": \"record\",\n \"namespace\": \"hortonworks.hdp.refapp.syslogapp\",\n \"name\": \"syslogpameventkafka\",\n \"fields\": [\n {\n \"name\": \"EventId\",\n \"type\": \"string\"\n },\n {\n \"name\": \"timestamp_ux\",\n \"type\": \"int\"\n },\n {\n \"name\": \"event_month\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_day\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_dow\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_hour\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"shostname\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionUser\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionByUser\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionEvent\",\n \"type\": \"string\"\n }\n ]\n}"}' 'http://$REGISTRY_HOST:7788/api/v1/schemaregistry/schemas/syslog_pam_avro_v7/versions'
	                   echo "**************** done pushing the schema ******************"
}



echo "********************************* Registering Schemas"
pushSchemasToRegistry	