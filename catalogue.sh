#!/bin/bash

set -e #ERR
trap  echo  "this is error in line $LINENO,command $BASH_COMMAND'" ERR

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
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

dnf module disable nodejs -y
VALIDATE $? "disable nodejs on server"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling nodejs:20 module"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "creating roboshop system user"

mkdir /app -p
VALIDATE $? "creating application directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue zip file"
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "extracting catalogue zip file"
npm install
VALIDATE $? "installing npm dependencies"