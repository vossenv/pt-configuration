
# Profit Trailer Setup (Ubuntu)

**Before you begin**:
	Make sure your ports are configured.  You may want to enable UFW (don't forget to allow ssh traffic), and forward a range of ports for your PT bots.  More information on port forwarding in Ubuntu can be found here:
	[https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04)

**Prerequisites**: 
- java 8
- unzip (will be installed by script)

Java 8 can be installed as follows:
```
sudo apt-get update
sudo apt-get -y install openjdk-8-jdk
```

To download:

`wget -O install.sh https://git.io/JGm96;` Or `curl -o pi-shrink.sh https://git.io/JGm96;`

Make it executable

`chmod +x install.sh`

Run the script!

`sudo ./install.sh`

Additional options:
```
usage:
    ./install.sh [--help|-h] [-n] [-y] [--update|-u] [--remove-r]

where:
    -h, --help  show this help text
    -n set service name
    -y yes to all prompts
    -u update (will prompt for service name)
    -r remove (will prompt for service name)
```

Run the script with no user interaction:

`sudo ./install.sh -n pt-service-name -y`

**Important Note**

The profit trailer ports should be set from within the application (default should be 8081/8082). 

`http://localhost:8081 OR http://{server_ip/server_dns}:8081`

You can see what port the bot has started on by looking at that log for the service:

`sudo journalctl -f -u {service_name}`

**Example output**:

![example_output](/images/example.jpg)