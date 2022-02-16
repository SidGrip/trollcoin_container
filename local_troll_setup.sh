#!/bin/bash
FTP='https://bootstrap.specminer.com/Trollcoin'
GITHUB='https://github.com/TrollCoin2/TrollCoin-2.0.git'
USER=$(whoami)
USERDIR=$(eval echo ~$USER)
STRAP='bootstrap.dat'
CONF='trollcoin.conf'
DIR='.trollcoin'
DAEMON='trollcoind'
NAME='TrollCoin'
RPC_PORT='17000'
P2P_PORT='15000'
BBlue='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;97m'
YELLOW='\033[0;93m'
NC='\033[0m'

function troll_install() {
echo -e "Starting ${YELLOW}$NAME ${WHITE}Docker Container${NC}"
docker run -t -d -e DISPLAY=:0 --net=host -v=/etc/localtime:/etc/localtime:ro -v=/$USERDIR/$DIR:/$USERDIR/$DIR --name trollcoin trollcoin:local

sudo su - <<EOF
sudo chown -R $USER /$USERDIR/$DIR
sudo chmod 770 /$USERDIR/$DIR
sudo ufw allow 15000/tcp comment "trollcoin" >/dev/null
EOF

docker cp /etc/machine-id trollcoin:/etc/machine-id

clear
}

function active_nodes() {
# get list of curent active nodes from chainz block explorer sort and save to tmp file for use in config
curl -s$ https://chainz.cryptoid.info/troll/api.dws?q=nodes -o /tmp/peers.txt

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/nodes.txt 2>&1
# Everything below will go to the file /tmp/nodes.txt

grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /tmp/peers.txt |
while read nodes
do
    echo addnode=$nodes
done
}

function troll_config() {
PEERS=$(</tmp/nodes.txt)
clear
echo -e "Creating ${YELLOW}$TROLL_COIN_NAME${NC} Config"
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $USERDIR/$DIR/$CONF
maxconnections=25
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
port=$P2P_PORT
$PEERS
EOF
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
    read -p "Download $NAME $STRAP? (Y or N)" yn
    case $yn in
        [Yy]* ) wget --progress=bar:force -O $USERDIR/$DIR/$STRAP $FTP/$STRAP 2>&1 | progressfilt; break;;
        [Nn]* ) echo You must like waiting a long time for shit to sync; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear
}

function qt_script() {
#create scripts to control Trollcoin Qt wallet and Daemon in Docker container
cat << 'EOT' > $USERDIR/$DIR/$NAME
#!/bin/bash
CONTAINER_NAME='trollcoin'
CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
if [ ! "${CID}" ]; then
  docker start trollcoin >/dev/null 2>&1
  docker exec trollcoin $USERDIR/TrollCoin-2.0/TrollCoin
else
  docker exec trollcoin $USERDIR/TrollCoin-2.0/TrollCoin "$@"
fi
EOT
sudo chmod u+x $USERDIR/$DIR/$NAME
}

function daemon_script() {
cat << 'EOT' > $USERDIR/$DIR/$DAEMON
#!/bin/bash
CONTAINER_NAME='trollcoin'
CID=$(docker ps -q -f status=running -f name=^/${CONTAINER_NAME}$)
if [ ! "${CID}" ]; then
  docker start trollcoin >/dev/null 2>&1
  docker exec trollcoin $USERDIR/TrollCoin-2.0/src/trollcoind
else
  docker exec trollcoin $USERDIR/TrollCoin-2.0/src/trollcoind "$@"
fi
EOT
sudo chmod u+x $USERDIR/$DIR/$DAEMON
}

function troll_cut() {
#Create .desktop app to launch trollcoin
echo -e "Creating ${YELLOW}$$NAME${NC} Desktop Applicatoin Shortcut"
wget -O $USERDIR/$DIR/trollcoin.png $FTP/trollcoin.png >/dev/null 2>&1
clear
cat << EOF > $USERDIR/.local/share/applications/TrollCoin.desktop
[Desktop Entry]
Name=TrollCoin
Version=v2.0
Icon=$USERDIR/$DIR/trollcoin.png
Exec=$USERDIR/$DIR/TrollCoin
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
if [ ! -f "$USERDIR/$DIR/$STRAP" ]; then
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
echo -e "${WHITE}Everything is Done $USER, ${YELLOW}$NAME${WHITE} should now work with any newer version of Ubuntu${NC}"
}

function setup_node() {
  troll_install
  bootstrap
  qt_script
  daemon_script
  troll_cut
  important_information
  active_nodes
  troll_config

}

##### Main #####
clear
setup_node
