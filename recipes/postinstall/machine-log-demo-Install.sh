#!/bin/bash
echo "*********************************Install Machine log demo data *****************************"
yum install -y wget
yum install -y git

git clone https://github.com/vakshorton/CloudBreakArtifacts

echo "************ Installing HDF components ************************"
chmod +x -R ./CloudBreakArtifacts/recipes/
./CloudBreakArtifacts/recipes/hdp-hdf-post-install.sh

echo "************ Installing Demo  ************************"
git clone https://github.com/oascofare/Hackathon2017
cd Hackathon2017
chmod +x -R ./shell
./shell/pushSchemasToRegistry.sh
./shell/deploySAMTopology.sh
./shell/deployNifiTemplate.sh
sudo ./shell/configRsyslog.sh
sudo ./shell/gensessions-ag.sh 1000000

