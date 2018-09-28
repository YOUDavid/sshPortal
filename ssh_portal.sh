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

