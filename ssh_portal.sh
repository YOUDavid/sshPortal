while true
do
    echo 'SSH Portal V0.1 by You Zhaohe, 2018'
    echo '0: exit'
    echo '1: ssh connect to a profile'
    echo '2: sshfs mount remote directory'
    read -s -p $'Please type a number to continue: \n' input_command 
    if [ '0' == "$input_command" ]
    break
    elif [ '1' == "$input_command" ]
    then

    elif [ '2' == "$input_command" ]
    then

    else
        echo "Can not understand command: $input_command !!!"
    fi
done

