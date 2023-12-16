#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M)
LOGFILE="/tmp/$0-$TIMESTAMP-log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo " $2...$R failed $N"
    else 
        echo " $2...$G success $N "
    fi
}

if [ $ID -ne 0 ]
then
    echo " Switch to $R root $N user "
    exit 1
else 
    echo " Brace yourselves "
fi

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabling old version of mysql"

cp /home/centos/roboshop/mysql.repo /etc/yum.repos.d/mysql.repo

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing Mysql"

systemctl enable mysqld
VALIDATE $? "Enabling Mysql"

systemctl start mysqld
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Changing mysql root password"

netstat -lntp