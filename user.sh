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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling old version of NODEJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NODEJS:18"

yum list installed nodejs &>> $LOGFILE
    if [ $? -ne 0 ]
    then
        dnf install nodejs -y &>> $LOGFILE
        VALIDATE $? "Installing NODEJS"

    else
        echo -e "$Y NODEJS Already installed $N"
    fi
useradd roboshop &>> $LOGFILE
VALIDATE $? "Creating user roboshop"

mkdir -p /app
VALIDATE $? "Creating a directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "donwloading user application data"

cd /app

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping the user data"

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "creating user service"

systemctl daemon-reload &>> $LOGFILE

systemctl enable user &>> $LOGFILE

systemctl start user &>> $LOGFILE

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing Mongoclient"

mongo --host mongodb.mohammedasik.shop </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading data to mongodb"

netstat -lntp