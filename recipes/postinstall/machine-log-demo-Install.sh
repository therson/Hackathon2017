#!/bin/bash
echo "*********************************Install Machine log demo data *****************************"
yum install -y wget
yum install -y git
git clone https://github.com/oascofare/Hackathon2017
cd Hackathon2017
chmod +x -R ./shell
./shell/installSyslogDemo.sh