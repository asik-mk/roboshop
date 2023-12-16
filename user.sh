#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP-log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
APP=$1
if [ $ID -ne 0 ]
then
    echo " Switch to root user "
    exit 1
else 
    echo " Sit Tight while we install $APP "
fi

VALIDATE(){

    if [ $1 -ne 0 ]
    then
        echo -e " $2..$Y Already Exists! Cannot Duplicate! $N"
        #exit 1  
    else 
        echo -e " $2..$G success $N"
    fi
}

dnf module disable nodejs -y  
VALIDATE $? "disabling old version of NODEJS"

dnf module enable nodejs:18 -y 
VALIDATE $? "Enabling NODEJS:18"

yum list installed nodejs 
    if [ $? -ne 0 ]
    then
        dnf install nodejs -y 
        VALIDATE $? "Installing NODEJS"

    else
        echo -e "$Y NODEJS Already installed $N"
    fi
useradd roboshop 
VALIDATE $? "Creating user roboshop"

mkdir -p /app
VALIDATE $? "Creating a directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip 
VALIDATE $? "donwloading user application data"

cd /app

unzip -o /tmp/user.zip 
VALIDATE $? "Unzipping the user data"

npm install 
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/user.service /etc/systemd/system/user.service 
VALIDATE $? "creating user service"

systemctl daemon-reload 

systemctl enable user 

systemctl start user 

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo 

dnf install mongodb-org-shell -y 
VALIDATE $? "installing Mongoclient"

mongo --host mongodb.mohammedasik.shop </app/schema/user.js 
VALIDATE $? "Loading data to mongodb"

netstat -lntp