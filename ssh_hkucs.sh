
#!/bin/bash

encrypted_password='1a03a787f0b1adc8e13e3f2e85242ca00ff9a9439a7c0eba038deec8b18dc6ae9304d14460fe64f0423fc78d536f5b9a3055c984a41078b7b48821f6eb104365  -'
try_time="3"
isPortUsed="-1"
trap '[ -z `fuser ,,1081/tcp 2>/dev/null` ] && fuser 1081/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null' 0
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
        #check port 1081
        isPortUsed=`fuser 1081/tcp 2>/dev/null | cut -f1`

        if [ -z $isPortUsed ]
        then
            #port 1081 is not used
            sshpass -p $input_password ssh -f h3523240@gatekeeper.cs.hku.hk -L 1081:academy11.cs.hku.hk:22 -N
        fi
        
        sshpass -p $input_password ssh -p 1081 h3523240@localhost

        break
    fi
done



