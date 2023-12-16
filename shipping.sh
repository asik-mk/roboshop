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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding User roboshop"

mkdir -p /app &>> $LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "downloading shipping data"

cd /app
unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping data"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

cp /home/centos/roboshop/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload

systemctl enable shipping 

systemctl start shipping

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.mohammedasik.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading Schema"


systemctl restart shipping




