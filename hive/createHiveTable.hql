


CREATE EXTERNAL TABLE USER_SESSIONS (
	id string,
	timestamp_ux bigint,
	hostname string,
	login string,
	byuser string,
	event string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/tmp/rsyslogs';