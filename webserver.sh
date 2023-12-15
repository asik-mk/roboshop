#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP-log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $ID -ne 0 ]
then
    echo " Switch to root user "
    exit 1
else 
    echo " Proceeding "
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

yum list installed nginx &>> $LOGFILE
    if [ $? -ne 0 ]
    then

    dnf install nginx -y &>> $LOGFILE
    VALIDATE $? "Installing nginx"

    systemctl enable nginx &>> $LOGFILE
    VALIDATE $? "Enabling nginx"

    systemctl start nginx
    VALIDATE $? "starting nginx"

    else
        echo -e "$Y Nginx is already installed $N"
    fi

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>> $LOGFILE
VALIDATE $? "Downloading roboshop application from web"

cd /usr/share/nginx/html 

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping the files"

cp /home/centos/roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copying the roboshop.conf to nginx directory"

systemctl restart nginx &>> $LOGFILE

netstat -lntp