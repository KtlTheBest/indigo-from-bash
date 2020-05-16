#!/bin/bash

python_gen_key='./genkey.py'
CONFIG_FOLDER="config"


print_usage(){
    cat - << EOF
Usage: $0 [start|stop|help]
  start - start docker container of indigo
  stop  - stop docker container of indigo
  help  - print this help message
EOF
}

config_prompt(){
    mkdir $CONFIG_FOLDER
    echo -n "Please enter bot token: "
    read BOT_TOKEN
    echo $BOT_TOKEN > $CONFIG_FOLDER/token
    SECRET=$($python_gen_key)
    echo $SECRET > $CONFIG_FOLDER/key
    echo "Initializing the bot"
}

start_docker(){
    if [[ ! -d $CONFIG_FOLDER ]] ; then
        config_prompt
    else
        BOT_TOKEN=$(cat $CONFIG_FOLDER/token | tr -d '\n')
        SECRET=$(cat $CONFIG_FOLDER/key | tr -d '\n')
    fi

    run_docker_start_command="
docker run -d
  --name indigo
  -v $(pwd)/$CONFIG_FOLDER/:/indigo/config
  -e BOT_TOKEN=$BOT_TOKEN
  -e SECRET=$SECRET
  --restart=unless-stopped
  ktlthebest/indigo
"

    $run_docker_start_command
    #docker stop indigo && docker rm indigo
    if [[ ! $? ]] ; then
        docker rm indigo
    fi
}

stop_docker(){
    output=$(docker ps | grep indigo)
    if [[ -n output ]] ; then
        docker stop indigo >& /dev/null
        docker rm indigo >& /dev/null
    fi
}

if [[ $# -eq 0 ]] ; then
    print_usage
    exit 1
fi

case $1 in
    start) start_docker ;;
    stop)  stop_docker  ;;
    help)  print_usage  ;;
    *)
        echo "Unknown command!"
        print_usage
        exit 1
        ;;
esac
