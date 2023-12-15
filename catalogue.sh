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
        echo -e " $2..$R Failed $N"
        exit 1  
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
        dnf install nodejs -y
        VALIDATE $? "Installing NODEJS"

    else
        echo -e "$Y NODEJS Already installed $N"
    fi
useradd roboshop
VALIDATE $? "Creating user roboshop"

mkdir /app
VALIDATE $? "Creating a directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "donwloading catalogue application"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping the app data"

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "creating catalogue service"

systemctl daemon-reload

systemctl enable catalogue

systemctl start catalogue

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing Mongoclient"

mongo --host mongodb.mohammedasik.shop </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading data to mongodb"