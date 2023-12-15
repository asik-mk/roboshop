#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP-log"

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
        echo -e " $2..$R Failed "
        exit 1  
    else 
        echo -e " $2..$G success "
    fi
}

yum list installed mongo-org 
    if [ $? -ne 0 ]
    then

    cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
    VALIDATE $? "copying mongo repo"

    dnf install mongodb-org -y &>> $LOGFILE
    VALIDATE $? "Installing Mongodb"

    else
        echo -e "$Y Mongo db Already installed $N"
    fi

systemctl enable mongod
VALIDATE $? "Enabling Mongodb"

systemctl start mongod
VALIDATE $? "starting Mongodb"  

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote access globally"

systemctl restart mongod 
VALIDATE $? "Restarting mongodb"

#EOS
