
#!/bin/bash

export AMBARI_HOST=$(hostname -f)
export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

getZeppelinHost () {
       	ZEPPELIN_MASTER_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI/components/ZEPPELIN_MASTER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $ZEPPELIN_MASTER_HOST
}

export NIFI_HOST=$(getNifiHost)
echo "export ZEPPELIN_MASTER_HOST=$NIFI_HOST" >> ~/.bash_profile

 
 #getZeppelinNotebook() {
                ZEPP_NOTEBOOK=SysLogModel-v1.json
                echo $ZEPP_NOTEBOOK
#}
# Login to Zeppelin
#curl -i --data 'userName=admin&password=password1' -X POST http://ZEPPSERVER_HOST:9995/api/login
#curl -i --data 'userName=admin&password=admin' -X POST http://172.26.230.144:9995/api/login
 
# Create a Notebook
#curl -H 'Content-Type:application/json' -XPUT -d $ZEPP_NOTEBOOK http://$ZEPPSERVER_HOST:9995/api/notebook
 
#curl -H 'Content-Type:application/json' -XPUT -d SysLogModel-v1.json http://172.26.230.144:9995/api/notebook
 
# Run all paragraphs
#http://ZEPPSERVER_HOST:9995/api/notebook/job/[notebookId]
        