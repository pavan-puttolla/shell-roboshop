#!/bin/bash

 SG_ID="sg-07907c7964eaaf4c5"
 AMI_ID="ami-0220d79f3f480ecf5"
 ZONE_ID="Z048222339YB2Q89ONAT9"
 DOMAIN_NAME="pspk.online"
 
for instance in $@
do      
   instance_id=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "t3.micro" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text )          
    if [ $instance == "frontend" ]; then
        
        IP=$(aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PublicIpAddress' \
         --output text
         )
         RECORED_NAME="$DOMAIN_NAME"  #PSPK.ONLINE
    else
        IP=$(aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text
         )
       RECORED_NAME="$instance.$DOMAIN_NAME" #MONGODB.PSPK.ONLINE
       fi 
        echo "IP address:  $IP"

        aws route53 change-resource-record-sets \
            --hosted-zone-id "$ZONE_ID" 
            --change-batch '{
            "Comment": "Updating A record",
              "Changes": [
              {
              "Action": "UPSERT",
              "ResourceRecordSet": {
              "Name": "'$RECORED_NAME'",
              "Type": "A",
              "TTL": 1,
              "ResourceRecords": [
              {
               "Value": "'$IP'"
              }
            ]
        }
    }
  ]
}' 

echo "Record updated for $instance"

done