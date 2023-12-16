#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ ID -ne 0 ]
then
    echo " Swtich to root user "
    exit 1
else
    echo " proceeding "
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? " Installing remi-release "

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? " Preparing Redis:remi-6.2  "

dnf install redis -y $LOGFILE
VALIDATE $? " Installing Redis "

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf $LOGFILE
VALIDATE $? " Allowing remote access "

systemctl enable redis $LOGFILE
VALIDATE $? " Enablning redis "

systemctl start redis $LOGFILE
VALIDATE $? " Starting redis "
