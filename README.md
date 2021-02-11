## **TrollCoin Qt & Daemon running in a Ubuntu 14 Docker Container**
<br>

![TROLL logo](https://avatars2.githubusercontent.com/u/16044831?v=3&u=c30f9a963a650436d286920035513bc94828d560&s=140)

https://github.com/TrollCoin2/TrollCoin-2.0/blob/master/README.md
<br>
#### To setup Non-Root Docker on Ubuntu 20.04
##### - this was tested on a clean & updated install of Ubuntu 20.04
https://docs.docker.com/engine/security/rootless/
<br>
https://docs.docker.com/engine/install/linux-postinstall/
<br>
or
<br>
You can run this script - Everyting is run as user enter sudo password when prompted
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
#### I tried to make this as seamless as possable
###### The script will create a .trollcoin data directory with TrollCoin & trollcoind - both files are scripts that run same as the Qt wallet or daemon would.
###### -- will give you an option to download a bootstrap that is a week behind
###### -- will autogen a config with random user/pass and add currents nodes
###### -- will also place a shortcut in your desktop applicatoins for launching the Qt wallet
<br>
<h2 align="center">If this Makes Your Nipples So HARD, that you could cut glass!</h2>
<h3 align="center">Please consider sending ALL YOUR TROLLCOIN to this burn address</h3>
<h2 align="center">TdSatSgVqvJNZ2PheSTDEXkA3BbraAE3gH</h2>
<h3 align="center">So we can rid the world of this counterproductive crypto garbage</h3>
<p align="center">
  <img width="450" src="https://media1.tenor.com/images/7a13ea9d38f091d68125ad13763d5721/tenor.gif?itemid=16217383" alt="TrollRoll">
</p>
<h5 align="center">Doing so will also bring about world peace,  well not really but you could imagine if it could</h5>
