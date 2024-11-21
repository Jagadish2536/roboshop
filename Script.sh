#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-05a6d6ae3c9b526b1
INSTANCES=("mongodb" "shipping" "mysql" "redis" "catalogue" "user" "cart" "web" "rabbitmq" "payment" "dispatch")
ZONE_ID=Z09496212DQ4BR1GX50TZ
DOMAIN_NAME="jagadish.online"

for i in "${INSTANCES[@]}"
do
    if [ $i == "Mongodb" ] || [ $i == "Shipping" ] || [ $i == "MySQL" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i : $IP_ADDRESS"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Testing creating a record set"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
    '
done
