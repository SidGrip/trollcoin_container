## **TrollCoin Qt & Daemon running in a Ubuntu 14 Docker Container**
<br>

https://hub.docker.com/r/sidgrip/trollcoin    |    https://github.com/TrollCoin2/TrollCoin-2.0/blob/master/README.md
<br>
#### To setup Non-Root Docker on Ubuntu 20.04

https://docs.docker.com/engine/security/rootless/
<br>
https://docs.docker.com/engine/install/linux-postinstall/
<br>
or
<br>
You can run this script - Everyting is run as user enter sudo password when prompted
##### - this was tested on a clean & updated install of Ubuntu 20.04
###### If your running a diffrent vertion of Ubuntu change line 21 in the script to reflect your docker install package
Copy & paste into terminal window
```
wget -q https://raw.githubusercontent.com/SidGrip/trollcoin_container/main/non_root_docker.sh
```
Then run ```bash non_root_docker.sh``` 
<br>
#### After the system reboots
Copy & paste into terminal window - Everyting is run as user enter sudo password when prompted
```
wget -q https://raw.githubusercontent.com/SidGrip/trollcoin_container/main/trollcoin_cointainer.sh
```
Then run ``` bash trollcoin_cointainer.sh``` 
<br>
<br>

#### ⚡ If you would like to compile it yourself
Copy & paste into terminal window
```
wget -q https://raw.githubusercontent.com/SidGrip/trollcoin_container/main/trollcoin_Dockerfile.sh
```
Then run ``` bash trollcoin_Dockerfile.sh && docker build --tag trollcoin:local .```
<br> 
This will gernerate a Dockerfile, build the container and compile both the Daemon and QT wallet. It will take a little time to complete.
<br>
You will see red warning/error messages.
<br>
#### After the container build is done
Copy & paste into terminal window - Everyting is run as user enter sudo password when prompted
```
wget -q https://raw.githubusercontent.com/SidGrip/trollcoin_container/main/local_troll_setup.sh
```
Then run ``` bash local_troll_setup.sh```
<br>
<br>
I tried to make this as seamless as possable
<br>
The script will create a .trollcoin data directory with TrollCoin & trollcoind - both files are scripts that run same as the Qt wallet or daemon would.
<br>
-- will give you an option to download a bootstrap that is a week behind
<br>
-- will autogen a config with random user/pass and add currents nodes
<br>
-- will place a shortcut in your desktop applicatoins for launching the Qt wallet
<br>
<br>
<h2 align="center">If this Makes Your Nipples So HARD, that you could cut glass!</h2>
<h3 align="center">Use that intense feeling and send a Donation</h3>
<h2 align="center">TwFN6UiRWUhYAjZZC6q8ThCqFffg9feR5N</h2>
<p align="center">
  <img width="450" src="https://media1.tenor.com/images/7a13ea9d38f091d68125ad13763d5721/tenor.gif?itemid=16217383" alt="TrollRoll">
</p>
<h4 align="center">Doing so will also bring about world peace!</h4>
<h6 align="center">-- well not really, but you could imagine if it would</h6>
