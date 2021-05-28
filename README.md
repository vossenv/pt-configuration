
# Profit Trailer Setup (Ubuntu)

Prerequisites: 
- java 8
- unzip (will be installed by script)

To download:

`wget -O install.sh https://git.io/JGm96;` Or `curl -o pi-shrink.sh https://git.io/JGm96;`

Make it executable

`chmod +x install.s.sh`

Run the script!

`sudo ./install.sh`

Additional options:
```
usage:
	./install.sh [-h] [-p] [-n] [-y]  

where:
	-h, --help show this help text
	-p set port number
	-n set service name
	-y yes to all prompts
```


Example output:

```
vagrant@ubuntu2004:/ptconfig$ ./install.sh

Profit Trailer service installer for Ubuntu (2021)
Source: https://github.com/vossenv/pt-configuration

Enter desired port (please make sure it is free)? 9090
Enter service name (no spaces): pt_service_1

-------------------------------------------
The following service will be installed:
Profit Trailer Service:
Name: pt_service_1
Port: 9090
Directory: /ptconfig/pt_service_1

Proceed (y/n)[y]? y
Downloading Profit Trailer...
--2021-05-28 05:11:43--  https://download.profittrailer.com/ProfitTrailer.zip
Resolving download.profittrailer.com (download.profittrailer.com)... 162.241.230.196
Connecting to download.profittrailer.com (download.profittrailer.com)|162.241.230.196|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 87319708 (83M) [application/zip]
Saving to: ‘ProfitTrailer.zip’

ProfitTrailer.zip                               100%[======================================================================================================>]  83.27M  2.91MB/s    in 31s

2021-05-28 05:12:15 (2.66 MB/s) - ‘ProfitTrailer.zip’ saved [87319708/87319708]

Install unzip...
Create directory /ptconfig/pt_service_1....
Archive:  ProfitTrailer.zip
  inflating: /ptconfig/pt_service_1/linux-update.sh
  inflating: /ptconfig/pt_service_1/pm2-ProfitTrailer.json
  inflating: /ptconfig/pt_service_1/ProfitTrailer.jar
  inflating: /ptconfig/pt_service_1/Run-ProfitTrailer.cmd
Create run script...
Create the service: /etc/systemd/system/pt_service_1.service...
Enable the service...
Created symlink /etc/systemd/system/multi-user.target.wants/pt_service_1.service → /etc/systemd/system/pt_service_1.service.

-------------------------------------------
Service pt_service_1 installed!
To start the service, run 'sudo service pt_service_1 start'
Check the status with 'sudo service pt_service_1 status'.  If you see a java error, please ensure java is installed.

Profit Trailer will run on port 8081 at first startup - you must change the port to 9090 from within the UI.
For more commands and usage, see /ptconfig/pt_service_1/usage.txt
```