#!/bin/bash

export AMBARI_HOST=$(hostname -f)
export ROOTPATH='~'
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

echo 'AMBARI-HOST='$AMBARI_HOST
echo 'CLUSTER-NAME='$CLUSTER_NAME

getZeppelinHost () {

        export ZEPPELIN_MASTER_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/ZEPPELIN/components/ZEPPELIN_MASTER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)' | grep -Po '([a-zA-Z0-9\-_!?.]+)')
       	echo 'ZEPPELIN_MASTER_HOST='$ZEPPELIN_MASTER_HOST
}

export ZEPPELIN_MASTER_HOST
 
getZeppelinNotebook() {
                export ZEPP_NOTEBOOK=~/Hackathon2017/zeppelin/SysLog-Model-Regression.json
                echo 'NOTEBOOK_PATH='$ZEPP_NOTEBOOK
}

getZeppelinHost
getZeppelinNotebook
# Login to Zeppelin
export SESSIONID=$(curl -i --data 'userName=admin&password=admin' -X POST http://$ZEPPELIN_MASTER_HOST:9995/api/login | grep -Po '"ticket":"[a-zA-Z0-9-]+' | grep -Po ':"([a-zA-Z0-9\-_!?.]+)' | grep -Po '[a-zA-Z0-9\-_!?.]+')
export JSONVAL='$(cat /root/Hackathon2017/zeppelin/SysLog-Model-Regression.json)'
echo 'SESSIONID:'$SESSIONID

# Create a Notebook

curl -i -b 'JSESSIONID=$SESSIONID; Path=/; HttpOnly' -H 'Content-Type:application/json' -X POST -d '{\"name\":\"I am REST API Note !!!\"}' http://$ZEPPELIN_MASTER_HOST:9995/api/notebook

#curl -i -b 'JSESSIONID=$SESSIONID; Path=/; HttpOnly' -H 'Content-Type:application/json' -X POST -d $JSONVAL http://$ZEPPELIN_MASTER_HOST:9995/api/notebook
 
 
# Run all paragraphs
#http://ZEPPSERVER_HOST:9995/api/notebook/job/[notebookId]
