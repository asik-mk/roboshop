#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
R="e\[31m"
G="e\[32m"
Y="e\[33m"
N="e\[0m"

VALIDATE(){

    if [ $1 -ne 0 ]
    then   
        echo -e "$R There is some issue. Please check logfile $N $LOGFILE"
    else 
        echo -e "$2 $G ... Success"
    fi
}

if [ $ID -ne 0 ]
then
    echo " Switch to root user "
    exit 1
else
    echo " Sit Tight while we configure PAYMENT interface for you "
fi

dnf install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing Python36"

useradd roboshop &>>$LOGFILE

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip  &>>$LOGFILE

VALIDATE $? "Downloading Payment "

cd /app 

unzip /tmp/payment.zip &>>$LOGFILE

VALIDATE $? "Unzipping payment data "

pip3.6 install -r requirements.txt &>>$LOGFILE

cp /home/centos/roboshop/payment.service /etc/systemd/system/payment.service 
