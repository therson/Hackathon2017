createStormView () {
	STORMUI_HOST=$STORMUI_HOST

	curl -u admin:admin -H "X-Requested-By:ambari" -X POST -d '{"ViewInstanceInfo":{"instance_name":"Storm_View","label":"Storm View","visible":true,"icon_path":"","icon64_path":"","description":"storm view","properties":{"storm.host":"'$STORMUI_HOST'","storm.port":"8744","storm.sslEnabled":"false"},"cluster_type":"NONE"}}' http://$AMBARI_HOST:8080/api/v1/views/Storm_Monitoring/versions/0.1.0/instances/Storm_View

}

createStormView