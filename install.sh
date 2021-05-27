#!/bin/bash


echo ""
echo "Initiating install with the parameters:"

echo ""

echo "Installing the PT service..."


while true; do 
    read -p "Enter desired port (please make sure it is free)? " port
    res=$(echo $port | grep -Po "(\D)")
    if [ "${res}" ]; then
        echo "Invalid character: '${res}'"
    elif [ $port -le 1024 ]; then
        echo "Illegal port - port should be in range 1024 to 49151"
    else
        break;
    fi
done

while true; do 
    read -p "Enter service name (no spaces): " svc_name
    res=$(echo $svc_name | grep -Po "([^a-zA-Z\d\.\_\-])")
    if [ "${res}" ]; then
        echo "Invalid character: ${res[*]}"
        echo "Allowed values are (alphanumeric, hyphen, period, underscore)"
    else
        break;
    fi
done
echo "-------------------------------------------"
echo "The following service will be installed: "
echo "Profit Trailer Service:"
echo "Name: ${svc_name}"
echo "Port: ${port}"
echo
read -p "Proceed (y/n)[y]? " yn
case $yn in
	[Yy]|Yes|yes|'' );;
	* ) exit;;
esac

exit

sudo tee /etc/systemd/system/$svc_name.service <<-EOF > /dev/null
#!/usr/bin/env bash
[Unit]
Description=Profit Trailer on port $port ($svc_name)
[Service]
User=root

WorkingDirectory=$dir
ExecStart=/bin/bash $dir/startup.sh
SuccessExitStatus=143
TimeoutStopSec=10

#Restart=on-failure
#RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee $dir/startup.sh <<-EOF > /dev/null
#!/usr/bin/env bash
/usr/bin/python $2
EOF

sudo systemctl daemon-reload
sudo systemctl enable $type.service
echo ""

echo "----------------------------"
[ ! -d /etc/systemd/system/$type.service ] && echo "Service verified" || echo "Service failed to install"
[ ! -d $dir/startup.sh ] && echo "Startup file verified" || echo "Startup file failed to install"
echo "----------------------------"

