#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $ID -ne 0 ]
then
    echo -e " Switch to root user "
    exit 1
else
    echo -e " Sit Tight while we Create Servers for YOUR $Y Roboshop $N "
fi

aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type t2.micro --security-group-ids sg-0a7b5d6d0aaba9852 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web}]'