pushSchemasToRegistry (){
			echo "**************** creating shema ID******************"
 curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "type": "avro", "schemaGroup": "Kafka", "name": "syslog_pam_avro_v7", "description": "Syslog PAM Schema v7", "compatibility": "BACKWARD", "evolve": true }' "http://$REGISTRY_HOST:7788/api/v1/schemaregistry/schemas"
 
                          echo "**************** updating schema ID******************"
 curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "description": "Syslog PAM Schema v7", "schemaText": "{\n \"type\": \"record\",\n \"namespace\": \"hortonworks.hdp.refapp.syslogapp\",\n \"name\": \"syslogpameventkafka\",\n \"fields\": [\n {\n \"name\": \"EventId\",\n \"type\": \"string\"\n },\n {\n \"name\": \"timestamp_ux\",\n \"type\": \"int\"\n },\n {\n \"name\": \"event_month\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_day\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_dow\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"event_hour\",\n \"type\": [\n \"int\",\n \"null\"\n ],\n \"default\": 0\n },\n {\n \"name\": \"shostname\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionUser\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionByUser\",\n \"type\": [\n \"string\",\n \"null\"\n ],\n \"default\": \"Unknown\"\n },\n {\n \"name\": \"SessionEvent\",\n \"type\": \"string\"\n }\n ]\n}"}' "http://$REGISTRY_HOST:7788/api/v1/schemaregistry/schemas/syslog_pam_avro_v7/versions"

	                   echo "**************** done pushing the schema ******************"
}

pushSchemasToRegistry