
#!/bin/bash
exec 200>~/.hkucs.sh.lock
flock -xn 200 || { echo "Already connected to hkucs!"; exit 1; }
trap 'rm ~/.hkucs.sh.lock; fusermount -u ~/h3523240; fuser 44556/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null' 0
encrypted_password='1a03a787f0b1adc8e13e3f2e85242ca00ff9a9439a7c0eba038deec8b18dc6ae9304d14460fe64f0423fc78d536f5b9a3055c984a41078b7b48821f6eb104365  -'
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
        sshpass -p $input_password ssh -f h3523240@gatekeeper.cs.hku.hk -L 44556:academy11.cs.hku.hk:22 -N
        echo $input_password | sshfs -o password_stdin -p 44556 h3523240@localhost:/student/18/ext/h3523240 ~/h3523240

        input_command=""
        while 
            [ "$input_command" != "close" ]
        do
            read -p "Type \"close\" to disconnect: " input_command
        done

        
        
        break
    fi
    
done


