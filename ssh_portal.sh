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
local return_port=$1
local grep_result=''
if [ -z $return_port ]; then
    return_port=49152
fi
local telnet_result=`netstat -lnt`
while [ "$return_port" -le 65535 ]; do
    grep_result=`echo $telnet_result | grep ":$return_port"`
    if [ -z "$grep_result" ]; then
        echo $return_port
        return 0
    fi
    let return_port=return_port+1
done
echo -n ''
return 1
}

function clean_profile(){
# $1:   name of profile to be cleaned
    if [ -e ".ssh_portal.active.$1" ]; then
        local closingport=`cat ".ssh_portal.active.$1"`
        [ -z `fuser ,,$closingport/tcp 2>/dev/null` ] && fuser $closingport/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null && rm ".ssh_portal.active.$1"
    fi
    return 0
}

#function ssh_connect() {

#}



###Global variables

###saved_profiles format: saved_profiles[profile_name] = "profile_name|user_name|server_address|firewall_address|encrypted_password"
echo 'SSH Portal V0.1 by You Zhaohe, 2018'
if [ -e .ssh_portal.data ]; then 
    source .ssh_portal.data
else
    declare -A saved_profiles
fi
while true; do
    echo '0: exit'
    echo '1: ssh connect to a profile'
    echo '2: sshfs mount remote directory'
    echo '3: unmount previously mounted directory'
    echo '4: list active mounted directories'
    echo '5: create profile'    
    read -p 'Please type a number to continue: ' input_command 
    if [ '0' == "$input_command" ]; then
        break
    elif [ '1' == "$input_command" ]; then
        read -p 'Please enter the profile name: ' profile_name
        if [ -z ${saved_profiles[$profile_name]+dummy} ]; then
            echo "Can't find such profile: $profile_name"
            continue
        fi
        while IFS='|' read profile_name user_name server_address firewall_address encrypted_password <<< `echo ${saved_profiles[$profile_name]}`
        do
            break
        done
        
        try_time=3
        isPortUsed=-1        
        while [ $try_time -gt "0" ]
        do
            read -s -p $'Enter the password: ' input_password
            echo ''
            encrypted_input=`echo -n $input_password | sha512sum | cut -d' ' -f1`
            if [ "$encrypted_input" != "$encrypted_password" ]; then 
                echo "Incorrect password!"
                let try_time=try_time-1        
            else
                #check port 
                #isPortUsed=`fuser $freeport/tcp 2>/dev/null | cut -f1`

                if [ ! -e ".ssh_portal.active.$profile_name" ]
                then
                    #This is the first active profile of the same ones
                    freeport=`find_free_port`
                    if [ $? -gt 0 ]; then
                        echo "Error in finding a free local port!!!"
                        break
                    fi
                    
                    #Close the tunnel after no connection is made to the local port and even if the terminal was closed by other means
                    #trap "[ -z \`fuser ,,$freeport/tcp 2>/dev/null\` ] && fuser $freeport/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null" 0
                    
                    if [ -z firewall_address ]; then
                        sshpass -p $input_password ssh -L $freeport:$server_address:22 -N -o StrictHostKeyChecking=no
                    else
                        sshpass -p $input_password ssh -f $user_name@$firewall_address -L $freeport:$server_address:22 -N -o StrictHostKeyChecking=no
                    fi
                    echo -n $freeport > .ssh_portal.active.$profile_name
                    
                else
                    freeport=`cat .ssh_portal.active.$profile_name`
                fi
                trap "clean_profile $profile_name" 0
                sshpass -p $input_password ssh -p $freeport $user_name@localhost -o StrictHostKeyChecking=no

                #Close the tunnel after no connection is made to the local port
                clean_profile $profile_name
                break
            fi
        done
    elif [ '2' == "$input_command" ]; then
        ###TODO: sshfs mount a profile
        
        read -p 'Please enter the profile name: ' profile_name
        if [ -z ${saved_profiles[$profile_name]+dummy} ]; then
            echo "Can't find such profile: $profile_name"
            continue
        fi
        
        while IFS='|' read profile_name user_name server_address firewall_address encrypted_password <<< `echo ${saved_profiles[$profile_name]}`; do
            break
        done
        
        exec 200>~/.ssh_portal.mount.$profile_name
        flock -xn 200 || { echo "Already connected to carbon!!!"; continue; }
        
        if [ -d ~/$user_name@$profile_name ]; then
            echo "Directory to be mounted already exists!!!"
            continue
        else
            mkdir ~/$user_name@$profile_name
        fi
        
        try_time="3"
        while [ $try_time -gt "0" ]; do
            read -s -p $'Enter the password: ' input_password
            echo ''
            encrypted_input=`echo -n $input_password | sha512sum | cut -d' ' -f1`
            if [ "$encrypted_input" != "$encrypted_password" ]; then 
                echo "Incorrect password!"
                let try_time=try_time-'1'        
            else
                if [ ! -e ".ssh_portal.active.$profile_name" ]
                then
                    #This is the first active profile of the same ones
                    freeport=`find_free_port`
                    if [ $? -gt 0 ]; then
                        echo "Error in finding a free local port!!!"
                        break
                    fi
                    
                    #Close the tunnel after no connection is made to the local port and even if the terminal was closed by other means
                    #trap "[ -z \`fuser ,,$freeport/tcp 2>/dev/null\` ] && fuser $freeport/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null" 0
                    if [ -z firewall_address ]; then
                        sshpass -p $input_password ssh -L $freeport:$server_address:22 -N -o StrictHostKeyChecking=no
                    else
                        sshpass -p $input_password ssh -f $user_name@$firewall_address -L $freeport:$server_address:22 -N -o StrictHostKeyChecking=no
                    fi
                    echo -n $freeport > .ssh_portal.active.$profile_name
                    
                else
                    freeport=`cat .ssh_portal.active.$profile_name`
                fi
                trap "clean_profile $profile_name" 0
                remote_home=`sshpass -p $input_password ssh -p $freeport $user_name@localhost -o StrictHostKeyChecking=no 'echo $HOME'`
                echo $input_password | sshfs -o password_stdin -p $freeport "$user_name@localhost:$remote_home" ~/$user_name@$profile_name
                break
            fi
        done
    elif [ '3' == "$input_command" ]; then
        ###TODO: unmount a previously mounted directory
        read -p 'Please enter the profile name: ' profile_name
        if [ -z ${saved_profiles[$profile_name]+dummy} ]; then
            echo "Can't find such profile: $profile_name"
            continue
        fi
        
        while IFS='|' read profile_name user_name server_address firewall_address encrypted_password <<< `echo ${saved_profiles[$profile_name]}`; do
            break
        done
       
        if [ -e .ssh_portal.mount.$profile_name ]; then
            fusermount -u ~/$user_name@$profile_name
            rm ~/.ssh_portal.mount.$profile_name
            clean_profile $profile_name
        else
            echo "Profile is not mounted!!!"
        fi
    elif [ '4' == "$input_command" ]; then
        ###TODO: list all active mounted directories
        ls -A .ssh_portal.mount.*
    elif [ '5' == "$input_command" ]; then
        ###TODO: create profile
        read -p 'Please enter the new profile name: ' profile_name
        while [ ! -z ${saved_profiles[$profile_name]+dummy} ]; do
            echo echo "Duplicated name of profile: $profile_name"
            read -p 'Please enter the new profile name: ' profile_name
        done
        read -p 'Please enter the user name: ' user_name
        while [ -z $user_name ]; do
            echo echo 'No user name was provided!!!'
            read -p 'Please enter the user name: ' user_name
        done
        read -p 'Please enter the server address: ' server_address
        while [ -z $server_address ]; do
            echo echo 'No server address was provided!!!'
            read -p 'Please enter the server address: ' server_address
        done
        read -p 'Please enter the firewall address (empty for not using firewall): ' firewall_address
        read -s -p 'Enter the password: ' encrypted_password
        echo ''
        encrypted_password=`echo -n $encrypted_password | sha512sum | cut -d' ' -f1`
        saved_profiles[$profile_name]="$profile_name|$user_name|$server_address|$firewall_address|$encrypted_password"
        declare -p saved_profiles > .ssh_portal.data
        unset profile_name
        unset user_name
        unset server_address
        unset firewall_address
        unset encrypted_password
        
    else
        echo "Can not understand command: $input_command !!!"
    fi
done




# ###hkucs.sh
# exec 200>~/.hkucs.sh.lock
# flock -xn 200 || { echo "Already connected to hkucs!"; exit 1; }
# trap 'rm ~/.hkucs.sh.lock; fusermount -u ~/h3523240; fuser 44556/tcp 2>/dev/null | cut -f1 | xargs -i kill {} 2>/dev/null' 0

# try_time="3"

# while [ $try_time -gt "0" ]
# do
    # read -s -p $'Enter the password: ' input_password
    # echo ''
    # encrypted_input=`echo -n $input_password | sha512sum`
    # if [ "$encrypted_input" != "$encrypted_password" ]
    # then 
        # echo "Incorrect password!"
        # let try_time=try_time-'1'        
    # else
        # sshpass -p $input_password ssh -f h3523240@gatekeeper.cs.hku.hk -L 44556:academy11.cs.hku.hk:22 -N
        # echo $input_password | sshfs -o password_stdin -p 44556 h3523240@localhost:/student/18/ext/h3523240 ~/h3523240

        # input_command=""
        # while 
            # [ "$input_command" != "close" ]
        # do
            # read -p "Type \"close\" to disconnect: " input_command
        # done

        
        
        # break
    # fi
    
# done
# #############################################
# ###carbon.sh
# exec 200>~/.carbon.sh.lock
# flock -xn 200 || { echo "Already connected to carbon!"; exit 1; }
# trap 'fusermount -u ~/carbon;' 0 #rm ~/.carbon.sh.lock;

# encrypted_password=''


# try_time="3"
# while [ $try_time -gt "0" ]
# do
    # read -s -p $'Enter the password: ' input_password
    # echo ''
    # encrypted_input=`echo -n $input_password | sha512sum`
    # if [ "$encrypted_input" != "$encrypted_password" ]
    # then 
        # echo "Incorrect password!"
        # let try_time=try_time-'1'        
    # else
        # echo $input_password | sshfs zhyou@147.8.150.78:/home/zhyou ~/carbon

        # input_command=""
        # while 
            # [ "$input_command" != "close" ]
        # do
            # read -p "Type \"close\" to disconnect: " input_command
        # done
        # break
    # fi
    
# done

# #############################################

