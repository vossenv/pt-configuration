#!/bin/bash


function confirm() {
    read -p "Proceed (y/n)[y]? " yn
    case $yn in
        [Yy]|Yes|yes|'' );;
        * ) exit;;
    esac
}

function check_port() {
    res=$(echo $1 | grep -Po "(\D)")
    if [ "${res}" ]; then
        echo "Invalid character in port: '${res}'"
        elif [ $1 -le 1024 ]; then
        echo "Illegal port - port should be in range 1024 to 49151"
    else
        echo 0
    fi
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
`sudo journalctl -f -u {service_name}`

usage:
    ./install.sh [-h] [-n] [-y]

where:
    -h, --help  show this help text
    -n set service name
    -y yes to all prompts\n\n"


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
              *)
                echo "Parameter '$1' not recognized"
                exit
                shift # past argument
                shift # past value
  esac
done
echo
echo "Profit Trailer service installer for Ubuntu (2021)"
echo "Source: https://github.com/vossenv/pt-configuration"
echo

if ! [ "${svc_name}" ]; then
    while true; do
        read -p "Enter service name (no spaces): " svc_name
        result=$(check_name $svc_name)
        [[ $result == '0' ]] && break
        echo $result
    done
fi

install_dir="${PWD}/$svc_name"
svc="$svc_name.service"

echo
echo "-------------------------------------------"
echo "The following service will be installed: "
echo "Profit Trailer Service:"
echo "Name: ${svc_name}"
echo "Directory: ${install_dir}"
echo

! [ "${force}" ] && confirm

if test -e $install_dir; then
    echo "Path '${install_dir}' already exists and will be overwritten, continue?"
    ! [ "${force}" ] && confirm
    echo "Remove directory ${install_dir}..."
    rm -rf $install_dir
fi

if ! test -f "ProfitTrailer.zip"; then
    echo "Downloading Profit Trailer..."
    wget -O ProfitTrailer.zip "https://download.profittrailer.com/ProfitTrailer.zip"
fi

echo "Install unzip..."
sudo apt-get -y install unzip -qq

echo "Create directory ${install_dir}...."
mkdir -p $install_dir
unzip -j ProfitTrailer.zip -d $install_dir

sudo chown root -R $install_dir
sudo chmod u+rwx -R $install_dir

echo "Create run script..."
sudo tee $install_dir/run.sh <<-EOF > /dev/null
#!/usr/bin/env bash
java -Djava.net.preferIPv4Stack=true -Dsun.stdout.encoding=UTF-8\
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
    sudo systemctl enable $svc
To disable the service:
    sudo systemctl disable $svc

To run the jar manually:
    ensure the service is stopped
    run './run.sh' from within the directory ($install_dir)

To watch the log file:
    tail -f $install_dir/logs/ProfitTrailer.log
To watch the service output:
    sudo journalctl -f -u $svc_name

EOF

echo "Create the service: /etc/systemd/system/$svc..."
sudo tee /etc/systemd/system/$svc <<-EOF > /dev/null
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
sudo systemctl enable $svc
echo
echo "-------------------------------------------"
echo "Service $svc_name installed!"
echo "To start the service, run 'sudo service $svc_name start'"
echo "Check the status with 'sudo service $svc_name status'.  If you see a java error, please ensure java is installed."
echo
echo "Profit Trailer will run on port 8081 or 8082 at first startup - you can change the port from within the UI."
echo "For more commands and usage, see $install_dir/usage.txt"
echo
