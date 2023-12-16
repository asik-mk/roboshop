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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "donwloading cart application data"

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping the cart data"

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "creating cart service"

systemctl daemon-reload &>> $LOGFILE

systemctl enable cart &>> $LOGFILE

systemctl start cart &>> $LOGFILE

netstat -lntp