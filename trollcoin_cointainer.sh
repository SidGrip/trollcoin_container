#!/bin/bash
FTP='ftp://78.141.243.202/Trollcoin'
GITHUB='https://github.com/SidGrip/trollcoin_container/releases/download/2.1.0.0'
USER=$(whoami)
USERDIR=$(eval echo ~$user)
STRAP='bootstrap.dat'
COIN_PATH='/usr/local/bin'
TROLL_CONFIG_FILE='trollcoin.conf'
TROLL_CONFIGFOLDER='.trollcoin'
TROLL_COIN_DAEMON='trollcoind'
TROLL_COIN_NAME='TrollCoin'
TROLL_RPC_PORT='17000'
TROLL_COIN_PORT='15000'
BBlue='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;97m'
YELLOW='\033[0;93m'
NC='\033[0m'

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec &> >(tee setup.log) 2>&1
# Everything below will go to the file 'setup.log':

function troll_install() {
echo -e "Installing ${YELLOW}$TROLL_COIN_NAME ${WHITE}Docker Container${NC}"
docker run -t -d -e DISPLAY=:0 --net=host -v /etc/localtime:/etc/localtime:ro -v=/$USERDIR/$TROLL_CONFIGFOLDER:/home/troll/.trollcoin --name=trollcoin sidgrip/trollcoin:latest

sudo su - <<EOF
sudo chown -R $USER /$USERDIR/$TROLL_CONFIGFOLDER
sudo chmod 770 /$USERDIR/$TROLL_CONFIGFOLDER
sudo ufw allow 15000/tcp comment "trollcoin" >/dev/null
EOF

docker cp /etc/machine-id trollcoin:/etc/machine-id

clear
}

function bootstrap() {
#Downloading Bootstrap
progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%s' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}
clear
while true; do
    read -p "Download $TROLL_COIN_NAME $STRAP? (Y or N)" yn
    case $yn in
        [Yy]* ) wget --progress=bar:force -O $USERDIR/$TROLL_CONFIGFOLDER/$STRAP $FTP/$STRAP 2>&1 | progressfilt; break;;
        [Nn]* ) echo You must like waiting a long time for shit to sync; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
}

function config_file() {
IP4=$(curl ipv4.icanhazip.com)
IP6=$(curl ipv6.icanhazip.com)

if [[ -n $IP4 ]] && [[ -n $IP6 ]]; then 
clear
echo "Both IPv4 - $IP4 & Ipv6 - $IP6 Address's detected"
PEERS=$(curl -s$ $FTP/$TROLL_CONFIGFOLDER/{seed_ipv6.txt,seed_ipv4.txt})

elif [[ $IP4 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
clear
echo "$IP IPv4 Address Detected"
PEERS=$(curl -s$ $FTP/$TROLL_CONFIGFOLDER/seed_ipv4.txt)

elif [[ $IP6 =~ "${1#*:[0-9a-fA-F]}" ]]; then
clear
echo "$IP IPv6 Address Detected"
PEERS=$(curl -s$ $FTP/$TROLL_CONFIGFOLDER/seed_ipv6.txt)

else
echo No IP Found
fi
clear
echo -e "Creating ${YELLOW}$TROLL_COIN_NAME${NC} Config"
{
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $USERDIR/$TROLL_CONFIGFOLDER/$TROLL_CONFIG_FILE
maxconnections=25
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$TROLL_RPC_PORT
port=$TROLL_COIN_PORT
$PEERS
EOF
}
sleep 2
clear
}

function qt_script() {
#create scripts to control Trollcoin Qt wallet and Daemon in Docker container
cat << 'EOT' > $USERDIR/$TROLL_CONFIGFOLDER/$TROLL_COIN_NAME
#!/bin/bash
CONTAINER_NAME='trollcoin'
CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
if [ ! "${CID}" ]; then
  docker start trollcoin >/dev/null 2>&1
  docker exec -it trollcoin /home/troll/trollcoin/TrollCoin
else
  docker exec -it trollcoin /home/troll/trollcoin/TrollCoin "$@"
fi
EOT
sudo chmod u+x $USERDIR/$TROLL_CONFIGFOLDER/$TROLL_COIN_NAME
}

function daemon_script() {
cat << 'EOT' > $USERDIR/$TROLL_CONFIGFOLDER/$TROLL_COIN_DAEMON
#!/bin/bash
CONTAINER_NAME='trollcoin'
CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
if [ ! "${CID}" ]; then
  docker start trollcoin >/dev/null 2>&1
  docker exec -it trollcoin /home/troll/trollcoin/trollcoind
else
  docker exec -it trollcoin /home/troll/trollcoin/trollcoind "$@"
fi
EOT
sudo chmod u+x $USERDIR/$TROLL_CONFIGFOLDER/$TROLL_COIN_DAEMON
}

function troll_cut() {
#Create .desktop app to launch trollcoin
echo -e "Creating ${YELLOW}$TROLL_COIN_NAME${NC} Desktop Applicatoin Shortcut"
wget -O $USERDIR/$TROLL_CONFIGFOLDER/trollcoin.png $GITHUB/trollcoin.png >/dev/null 2>&1
clear
cat << EOF > $USERDIR/.local/share/applications/TrollCoin.desktop
[Desktop Entry]
Name=TrollCoin
Version=v2.0
Icon=$USERDIR/$TROLL_CONFIGFOLDER/trollcoin.png
Exec=$USERDIR/$TROLL_CONFIGFOLDER/TrollCoin
Terminal=true
Type=Application
Categories=Applicatoin;
Keywords=Crypto;TrollCoin;Diet;Coke;
EOF

sudo chmod +x $USERDIR/.local/share/applications/TrollCoin.desktop
sudo update-desktop-database

clear
}

function important_information() {
if [ ! -f "$USERDIR/$TROLL_CONFIGFOLDER/$STRAP" ]; then
clear
else
echo -e "${WHITE}When you start the wallet for the frist time it will sync from the bootstrap." 
sleep 2
echo -e "This could take hours, days or weeks depending on the speed of your machine"
sleep 2
echo -e "When it's done the wallet will rename the ${WHITE}bootstrap.dat to bootstrap.dat.old"
sleep 2
echo -e "Then you can delete the bootstrap.dat.old file${NC}"
sleep 2
fi
echo -e "${WHITE}Everything is Done $USER, ${YELLOW}$TROLL_COIN_NAME${WHITE} should now work with any newer version of Ubuntu${NC}"
}

function setup_node() {
  troll_install
  bootstrap
  config_file
  qt_script
  daemon_script
  troll_cut
  important_information
}

##### Main #####
clear
setup_node
