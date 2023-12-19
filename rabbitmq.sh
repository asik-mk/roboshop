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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "downloading Rabbitmq script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE

VALIDATE $? "downloading Rabbitmq repos"

dnf install rabbitmq-server -y &>>$LOGFILE

VALIDATE $? "Installing rabbitmq-server"

systemctl enable rabbitmq-server &>>$LOGFILE


systemctl start rabbitmq-server 

rabbitmqctl add_user roboshop roboshop123

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
