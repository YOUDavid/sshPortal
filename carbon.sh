#!/bin/bash

exec 200>~/.carbon.sh.lock
flock -xn 200 || { echo "Already connected to carbon!"; exit 1; }
trap 'fusermount -u ~/carbon;' 0 #rm ~/.carbon.sh.lock;








encrypted_password=''


try_time="3"
while [ $try_time -gt "0" ]
do
    read -s -p $'Enter the password: ' input_password
    echo ''
    encrypted_input=`echo -n $input_password | sha512sum`
    if [ "$encrypted_input" != "$encrypted_password" ]
    then 
        echo "Incorrect password!"
        let try_time=try_time-'1'        
    else
        echo $input_password | sshfs zhyou@147.8.150.78:/home/zhyou ~/carbon

        input_command=""
        while 
            [ "$input_command" != "close" ]
        do
            read -p "Type \"close\" to disconnect: " input_command
        done
        break
    fi
    
done


