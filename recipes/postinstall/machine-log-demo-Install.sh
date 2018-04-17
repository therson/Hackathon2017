#!/bin/bash
echo "*********************************Install Machine log demo data *****************************"
yum install -y wget
yum install -y git
git clone https://github.com/amanda010792/CloudBreakArtifacts
 
echo "************ Installing HDF components ************************"
chmod +x -R ./CloudBreakArtifacts/recipes/
./CloudBreakArtifacts/recipes/hdp-hdf-post-install.sh
echo "************ Installing Demo  ************************"
git clone https://github.com/therson/Hackathon2017
cd Hackathon2017
chmod +x -R ./shell
./shell/configRsyslog.sh
./shell/pushSchemasToRegistry.sh
./shell/deploySAMTopology.sh
echo "* * * * *  root  /root/Hackathon2017/shell/gensessions-ag.sh 100" >> /etc/crontab
service  crond restart
./shell/deployNifiTemplate.sh

