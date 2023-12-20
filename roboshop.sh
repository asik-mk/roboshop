#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
INSTANCES=("mongodb" "redis" "rabbitmq" "web" "cart" "catalogue" "user" "payment" "mysql" "shipping")
AMI="ami-03265a0778a880afb"
SG="sg-0a7b5d6d0aaba9852"


if [ $ID -ne 0 ]
then
    echo -e " Switch to root user "
    exit 1
else
    echo -e " Sit Tight while we Create Servers for YOUR $Y Roboshop $N "
fi

for i in "$INSTANCES{[@]}"
do
    echo "Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t2.micro"
    else
        INSTANCE_TYPE="t2.micro"
    fi

aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web}]'
