#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[33m" # Yellow color
B="\e[34m" # Blue color
N="\e[0m"  # No color (reset)

if [ $USERID -ne 0 ]; then
   echo -e "$R please run with root access $N" | tee -a $LOGS_FILE 
   exit 1
fi
mkdir  -p $LOGS_FOLDER
VALIDATE(){
    if [ $1 -ne 0 ]; then
       echo -e "$2 -----installation is $R failure $N" | tee -a $LOGS_FILE
       exit 1
    else 
    echo -e "$2 ....installation is $G success $N" | tee -a $LOGS_FILE
    fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo file"

dnf install mongodb-org -y 
VALIDATE $? "mongodb installation on server"

systemctl enable mongod 
VALIDATE $? "enabling mongod service"

systemctl start mongod 
VALIDATE $? "starting mongod service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connection to mongodb"

systemctl restart mongod
VALIDATE $? "restarted Mongodb" 
