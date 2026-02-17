#!/bin/bash

 SG_ID="sg-07907c7964eaaf4c5"
 AMI_ID="0220d79f3f480ecf5"
 
for instance in $0
do      
   instance_id=$(
    aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "t3.micro" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output tex )          
    if [ $instance == "frontend" ]; then
        
        IP=$(
        aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text 
         )
        else
        IP=$(
        aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text 
         )
      echo "IP address  $IP"
   fi
done
