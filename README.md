# Hackathon2017
Assumptions:
-Cloudbreak machine is deployed, and configured with the necessary security group, network, template, blueprint, etc.


Deployment Steps

1.	Using a web browser, login to the cloudbreak UI

2.	Sign in with username: admin@example.com and 'cloudbreak' as the password

3.	In the top-right corner of the UI, Select your Credentials from the dropdown

4.	In the Cloudbreak UI, click the Create Cluster button at the top right, fill out the details as noted below (and the screenshot) and click next
  a.	Cluster name: machine-log-analytics-cluster
  b.	Region: RegionOne
  c.	Avail Zone: SE
  d.	Connector Variant: HEAT

5.	Setup Network and Security screen, choose 'fieldnetwork' and move to the blueprint section

6.	In the Blueprint config section, select 'machine-log-hdp-hdf' and configure the Host groups as follows.
  a.	Host_group_1
    i.	Group size: 1
    ii.	Template: m3xlarge
    iii.	Security group: modern-data-application-security-group
    iv.	Ambari Server: check this box
    v.	Recipes: check both of the following 
      1.	Machine-logs-demo-install
      2.	Pre-install-java-8

  b.	Host_group_2
    i.	Group size: 1
    ii.	Template: m3xlarge
    iii.	Security Group: modern-data-application-security-group
    iv.	Ambari server: unchecked
    v.	Recipes: check the following
      1.	Pre-install-java-8 


  c.	Host_group_3
    i.	Group size: 1
    ii.	Template: m3xlarge
    iii.	Security Group: modern-data-application-security-group
    iv.	Ambari server: unchecked
    v.	Recipes: check the following
      1.	Pre-install-java-8


7.	Now click on Show Advanced Options
  a.	Select Choose Failure Action
    i.	Rollback resources


8.	Configure HDP Repository
  a.	Ensure you have the latest HDP version and URLs defined. These can be obtained from the Hortonworks documentation: https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.2.0/bk_ambari-installation/content/hdp_26_repositories.html
  b.	Stack: HDP
  c.	Version: 2.6
  d.	Stack Repo ID: HDP-2.6.2.0
  e.	Base URL: http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.6.2.0
  f.	Utils Base URL: http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.21/repos/centos7


9.	Click on Review and Launch and confirm the configuration

10.	Click on Create Cluster to begin provisioning!
