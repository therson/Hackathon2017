#!/bin/bash

yum install rsyslog

echo "*.* @127.0.0.1:7780" >> /etc/rsyslog.conf 

service rsyslog restart