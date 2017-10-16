#!/bin/bash
echo "*********************************Install and start syslog analytic demo simulation data *****************************"
git clone https://github.com/oascofare/Hackathon2017
cd Hackathon2017
./shell/configRsyslog.sh
./shell/gensessions.sh  100
