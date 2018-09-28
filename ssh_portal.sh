#!/bin/bash
function password_check() {
# $1:   input password
# $2:   encrypted_password
# echo: input password if $1==$2, empty otherwise
# $?:   0 if $1 == $2, 1 otherwise
    local encrypted_input=`echo -n $1 | sha512sum`
    if [ $encrypted_input==$2 ]; then
        echo $1
        return 0
    else
        echo -n ''
        return 1
    fi
}

function find_free_port() {
# $1: lowest known unoccupied port
# echo: free local port if success, empty otherwise
# $?: 1 if success, 0 otherwise
local lowest_known_unoccupied_port=$1
local grep_result=''
if [ -z ${lowest_known_unoccupied_port+x} ]; then
    lowest_known_unoccupied_port=49152
fi
while [ "$lowest_known_unoccupied_port" -le 65535 ]; do
    grep_result=`netstat -lnt | grep ":$lowest_known_unoccupied_port"`
    if [ -z "$grep_result" ]; then
        echo $lowest_known_unoccupied_port
        return 0
    fi
    let lowest_known_unoccupied_port=lowest_known_unoccupied_port+1
done
echo -n ''
return 1
}


function ssh_connect() {

}

function tes(){
    if [ -z ${a+x} ]
    then
    echo 1
    else
    echo 0
}




###Global variables
lowest_known_unoccupied_port=49152
###saved_profiles format: arr[profile_name] = "user_name|server_name"

while true; do
    if [ -e .ssh_portal.data ]; then 
        source .ssh_portal.data
    else
        declare -A saved_profiles
    fi
    echo 'SSH Portal V0.1 by You Zhaohe, 2018'
    echo '0: exit'
    echo '1: ssh connect to a profile'
    echo '2: sshfs mount remote directory'
    echo '3: create profile'    
    read -s -p $'Please type a number to continue: \n' input_command 
    if [ '0' == "$input_command" ]; then
        declare -p saved_profiles > .ssh_portal.data
        
        break
    elif [ '1' == "$input_command" ]; then
        ###TODO: ssh connect a profile
    elif [ '2' == "$input_command" ]; then
        ###TODO: sshfs mount a profile
    elif [ '3' == "$input_command" ]; then
        ###TODO: create profile
    else
        echo "Can not understand command: $input_command !!!"
    fi
done




###ssh_hkucs.sh
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
#######################################


###hkucs.sh
exec 200>~/.hkucs.sh.lock
flock -xn 200 || { echo "Already connected to hkucs!"; exit 1; }
trap 'rm ~/.hkucs.sh.lock; fusermount -u ~/h3523240; fuser 44556/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null' 0

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
#############################################
###carbon.sh
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

#############################################
