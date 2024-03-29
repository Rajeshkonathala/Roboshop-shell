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
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N"
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

VALIDATE $? " Disabling Current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? " Enabling NodeJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? " Installing NodeJS:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? " Creating Roboshop User "
else
    echo -e "Roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? " Creating app Directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? " Downloading Catalogue applicatiion"

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? " Unzipping Catalogue "

cd /app

npm install &>> $LOGFILE

VALIDATE $? " Installing NPM "

#use absolute path, Because Catalogue.service is there
cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? " Copying catalogue service file "

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " Daemon Reload "

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? " Enabling Catalogue "

systemctl start catalogue &>> $LOGFILE

VALIDATE $? " Starting Catalogue "

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? " Copying MongoDB Repo "

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? " Installing MongoDB Client "

mongo --host 172.31.44.167 </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading CATALOGUE data into MONGODB"
