# ToDo:
- [x]  Created project directory for the default NodeJS App 
- [x]  Setup app.js
- [x]  Ran `npm init` to build a package.json file and added .gitignore to ensure sensitive files are not pushed to a public repo
- [x]  Setup Github repo (https://github.com/themobileprof/saleschamp)
- [x]  Setup Github Actions CI script for NodeJS *buiding* and *testing* on Push/PR to "main" branch (Tests for Nodejs 10.x, 12.x, 14.x, 15.x)
> *I considered setting Github branch protection rules on main branch to require review, but it will make testing a bit clumpsy*
- [x]  Create Terraform files for installation of two VMs in two AWS Availability Zones and creating an Application Load Balancer and Auto scaling group to ensure redundancy on Instance failure and scaling VMs up or down to accomodate spike in traffic.
- [x]  Send load balancer logs to an S3 bucket
- [x]  Bash script that is run for system configuration from Terraform, chose this over Ancible, because I was trying to avoid Terraform's remote-exec and local-exec clumpsy integration of ancible
- [x]  Choice of PM2 as NodeJS process manager, to also help with load balancing across CPUs
- [x]  Provision and test the Servers using Terraform
- [x]  Setup SSH keys on the Servers
- [x]  Save private keys on Github Secrets
- [x] Create CD script, using the AWS Code Deploy and Github Actions hooks to trigger a git pull from the EC2 Servers
- [ ] Setup prometheus and cover availability of the VMs and Load Balancer
- [ ] Set an Alert on the resources that logs errors and sends an email
- [ ] Use Graphana to plot and check availability

