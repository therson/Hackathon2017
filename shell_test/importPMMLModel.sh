importPMMLModel () {
	MODEL_DIR=/root/Hackaton2017/pmml/
	MODEL_FILE=syslog-Demo-PMML.xml
	MODEL_NAME=syslog-demo-pmml
	#Import PMML Model
	echo pmmlFile=@$MODEL_DIR'/'$MODEL_FILE_-F_'modelInfo={"name":"'$MODEL_NAME'","namespace":"ml_model","uploadedFileName":"'$MODEL_FILE'"};type=text/json'-X_POST_http://$AMBARI_HOST:7777/api/v1/catalog/ml/models
	
	curl -sS -i -F pmmlFile=@$MODEL_DIR'/'$MODEL_FILE -F 'modelInfo={"name":"'$MODEL_NAME'","namespace":"ml_model","uploadedFileName":"'$MODEL_FILE'"};type=text/json' -X POST http://$AMBARI_HOST:7777/api/v1/catalog/ml/models
}

importPMMLModel