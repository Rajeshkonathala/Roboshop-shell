#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executed at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R FAILED $N"
    else
        echo -e "$2 .. $Y SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "ERROR:: $R Please run this script with root access $N"
    exit 1 #you can give other than 0
else
    echo "you are root user"
fi #fi means reverse of if, indication of condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? " Disabling NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enabling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Installing NodeJS:18"

useradd roboshop

VALIDATE $? " Adding Roboshop"

mkdir /app

VALIDATE $? " Creating app Directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? " Downloading Catalogue applicatiion"

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? " Unzipping Catalogue "

cd /app

npm install 

VALIDATE $? " Installing NPM "

#use absolute path, Because Catalogue.service is there
cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? " Copying catalogue service file "

systemctl daemon-reload

VALIDATE $? " Daemon Relode "

systemctl enable catalogue

VALIDATE $? " Enabling Catalogue "

systemctl start catalogue

VALIDATE $? " Starting Catalogue "

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? " Copying MongoDB Repo "

dnf install mongodb-org-shell -y

VALIDATE $? " Installing MongoDB Client "

mongo --host mongodb.rajresh.online </app/schema/catalogue.js

VALIDATE $? " Loading CATALOGUE data into MONGODB "
