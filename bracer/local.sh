# Build AMI with aegea ami-e6c7cd9c


aegea launch --iam-role S3fromEC2 --ami-tags Name=czbiohub-miniconda -t m4.4xlarge  olgabot-igrec-m4
# aegea ssh ubuntu@olgabot-igrec-m4
ssh -i ~/.ssh/aegea.launch.olgabot.Olgas-MacBook-Pro.pem ubuntu@ec2-34-210-67-18.us-west-2.compute.amazonaws.com


aegea launch --iam-role S3fromEC2 --ami-tags Name=czbiohub-miniconda -t m4.4xlarge  olgabot-igrec-tabula-muris        
aegea launch --ami ami-f8cd3085 --iam-role S3fromEC2  --instance-type m4.4xlarge olgabot-tabula-muris-bcell
