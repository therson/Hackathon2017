#!/bin/bash
echo "*********************************Install and start syslog analytic demo simulation data *****************************"
yum install -y wget
yum install -y git
git clone https://github.com/oascofare/Hackathon2017
cd Hackathon2017
chmod +x -R ./shell
./shell/configRsyslog.sh
nohup ./shell/gensessions.sh  1000000 &


