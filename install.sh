#!/bin/bash


function confirm() {
    read -p "Proceed (y/n)[y]? " yn
    case $yn in
        [Yy]|Yes|yes|'' );;
        * ) exit;;
    esac
}

function check_name() {
    res=$(echo $1 | grep -Po "([^a-zA-Z\d\.\_\-])")
    if [ "${res}" ]; then
        echo "Invalid character in name: ${res[*]}"
        echo "Allowed values are (alphanumeric, hyphen, period, underscore)"
    else
        echo 0
    fi
}

function download_pt(){
    if ! test -f "ProfitTrailer.zip"; then
        echo "Downloading Profit Trailer..."
        wget -O ProfitTrailer.zip "https://download.profittrailer.com/ProfitTrailer.zip"
    fi
}

function extract_pt(){
    echo "Install unzip..."
    sudo apt-get -y install unzip -qq

    echo "Create directory ${1}...."
    mkdir -p $1
    unzip -o -j ProfitTrailer.zip -d $1 
}


usage="

Profit Trailer service installer for Ubuntu

You will still need to configure port forwarding and ensure that java is installed.
For Java, you may use openjdk 8:
sudo apt-get update
sudo apt-get -y install openjdk-8-jdk

Please see: https://github.com/vossenv/pt-configuration for more information.

Important Note:
The profit trailer ports should be set from within the application (default should be 8081/8082).

http://localhost:8081 OR http://{server_ip/server_dns}:8081

You can see what port the bot has started on by looking at that log for the service:
'sudo journalctl -f -u [service_name]'

usage:
./install.sh [--help|-h] [-n] [-y] [--update|-u]

where:
-h, --help  show this help text
-n set service name
-y yes to all prompts
-u update (will prompt for service name)\n\n"


while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
        --help|-h)
            printf "$usage"
            exit
            ;;
        -y)
            force=1
            shift ;;
        -n)
            result=$(check_name $2)
            ! [[ $result == '0' ]] && echo $result && exit
            svc_name=$2
            shift
            shift ;;
        --update|-u)
            update=1
            shift ;;
        *)
            echo "Parameter '$1' not recognized"
            exit
            shift # past argument
            shift # past value
    esac
done

echo "
----------------------------------------------------
$(tput setaf 5)Profit Trailer service installer for Ubuntu$(tput sgr 0)
Source: https://github.com/vossenv/pt-configuration
Version 1.0
----------------------------------------------------
"
[ "${update}" ] && echo "$(tput setaf 1)**UPDATE MODE**$(tput sgr 0)" && echo
if ! [ "${svc_name}" ]; then
    while true; do
        read -p "Enter service name (no spaces): " svc_name
        result=$(check_name $svc_name)
        [[ $result == '0' ]] && break
        echo $result
    done
fi

install_dir="${PWD}/$svc_name"
svc_path="/etc/systemd/system/${svc_name}.service"

if [ "${update}" ]; then
    if ! test -f $svc_path; then
        echo "Service by name of ${svc_name} does not exist or was not registered"
        exit
    fi
    install_dir=$(cat $svc_path| grep -Po '(?<=WorkingDirectory=).*')

    echo "Service ${svc_name} will be updated and some files in ${install_dir} replaced."
    echo "This will not affect your configuration data."
    echo

    ! [ "${force}" ] && confirm

    rm -f "ProfitTrailer.zip"
    download_pt
    echo "Updating: $svc_name..."
    extract_pt $install_dir
    echo "Update complete!"
    echo
    exit
fi

echo "----------------------------------------------------"
echo "The following service will be installed: "
echo "Profit Trailer Service:"
echo "$(tput setaf 2)Name: ${svc_name}"
echo "Directory: ${install_dir}$(tput sgr 0)"
echo


! [ "${force}" ] && confirm

if test -e $install_dir; then
    echo "Path '${install_dir}' already exists and will be overwritten, continue?"
    ! [ "${force}" ] && confirm
    echo
    echo "Remove directory ${install_dir}..."
    rm -rf $install_dir
fi

download_pt
extract_pt $install_dir

sudo chown root -R $install_dir
sudo chmod u+rwx -R $install_dir

echo
echo "Create run script..."
sudo tee $install_dir/run.sh <<-EOF > /dev/null
#!/usr/bin/env bash
/usr/bin/java -Djava.net.preferIPv4Stack=true -Dsun.stdout.encoding=UTF-8\
 -XX:+UseSerialGC -XX:+UseStringDeduplication -Xms64m -Xmx512m -XX:MaxMetaspaceSize=256m\
  -jar ProfitTrailer.jar
EOF

sudo tee $install_dir/usage.txt <<-EOF > /dev/null
To start the service:
    sudo service $svc_name start
To stop the service:
    sudo service $svc_name stop
To restart the service:
    sudo service $svc_name restart
To check status service:
    sudo service $svc_name status

To enable the service:
    sudo systemctl enable $svc_name.service
To disable the service:
    sudo systemctl disable $svc_name.service

To run the jar manually:
    ensure the service is stopped
    run './run.sh' from within the directory ($install_dir)

To watch the log file:
    tail -f $install_dir/logs/ProfitTrailer.log
To watch the service output:
    sudo journalctl -f -u $svc_name

EOF

echo "Create the service: $svc_path..."
sudo tee $svc_path <<-EOF > /dev/null
#!/usr/bin/env bash
[Unit]
Description=Profit Trailer - $svc_name
[Service]
User=root

WorkingDirectory=$install_dir
ExecStart=/bin/bash $install_dir/run.sh
SuccessExitStatus=143
TimeoutStopSec=10

#Restart=on-failure
#RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Enable the service..."
sudo systemctl daemon-reload
sudo systemctl enable $svc_name.service
echo "
----------------------------------------------------
 $(tput setaf 5)Service $svc_name installed!$(tput sgr 0)
 To start the service, run:
    $(tput setaf 2)sudo service $svc_name start$(tput sgr 0)

 To check the status, use:
    $(tput setaf 2)sudo service $svc_name status$(tput sgr 0)

 Profit Trailer will run on port 8081 or 8082 at first startup - you can change the port from within the UI.
 To see which port this service is starting on, view the PT output for it with the command:
    $(tput setaf 2)sudo journalctl -f -u $svc_name$(tput sgr 0)

 For more commands and usage, see $(tput setaf 2)$install_dir/usage.txt$(tput sgr 0)
"
