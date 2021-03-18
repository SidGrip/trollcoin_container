#!/bin/bash
USER=$(whoami)
CONFIG_FILE='trollcoin.conf'
USERDIR=$(eval echo ~$user)
CONFIGFOLDER='.trollcoin'
FTP='ftp://45.77.246.197/Trollcoin'
RED='\033[0;31m'
NC='\033[0m'

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec &> >(tee setup.log) 2>&1
# Everything below will go to the file 'setup.log':

echo -e "Installing ${RED}Trollcoin${NC} Docker Container"
docker run -t -d -e DISPLAY=:0 --net=host -v=/$USERDIR/.trollcoin:/home/troll/.trollcoin --name=trollcoin sidgrip/trollcoin:latest

sudo su - <<EOF
sudo chown -R $USER /$USERDIR/.trollcoin
sudo chmod 770 /$USERDIR/.trollcoin
sudo ufw allow 15000/tcp comment "trollcoin" >/dev/null
EOF

clear

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

while true; do
    read -p "Download Trollcoin Bootstrap? (Y or N)" yn
    case $yn in
        [Yy]* ) wget --progress=bar:force -O $USERDIR/$CONFIGFOLDER/bootstrap.dat $FTP/bootstrap.dat 2>&1 | progressfilt; break;;
        [Nn]* ) echo You must like waiting a long time for shit to sync; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "Downloading ${RED}Trollcoin${NC} Peer Address"
wget --progress=bar:force -P $USERDIR/$CONFIGFOLDER $FTP/peers.txt 2>&1 | progressfilt
sleep 2
PEERS=$(<$USERDIR/$CONFIGFOLDER/peers.txt)
sleep 1

echo "Creating config file"
{
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $USERDIR/$CONFIGFOLDER/$CONFIG_FILE
maxconnections=35
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=17000
port=15000
gen=0
listen=1
daemon=1
server=1
$PEERS
EOF
}
sleep 1
rm $USERDIR/$CONFIGFOLDER/peers.txt
docker exec trollcoin /home/troll/scripts/copy.sh
docker cp /etc/machine-id trollcoin:/etc/machine-id

clear

echo -e "Creating ${RED}Trollcoin${NC} Shortcut"
#Create .desktop app to launch trollcoin
cat << EOF > $USERDIR/.local/share/applications/TrollCoin.desktop
[Desktop Entry]
Name=Trollcoin
Version=v2.0
Icon=$USERDIR/$CONFIGFOLDER/trollcoin.png
Exec=$USERDIR/$CONFIGFOLDER/TrollCoin
Terminal=true
Type=Application
Categories=Applicatoin;
Keywords=Crypto;Trollcoin;Diet;Coke;
EOF

sudo chmod +x $USERDIR/.local/share/applications/TrollCoin.desktop
sudo update-desktop-database


clear

#Checking for Bootstrap
if [ -f "$USERDIR/$CONFIGFOLDER/bootstrap.dat" ]; then
  # Control will enter here if file doesn't exist.
echo -e "When you start the wallet for the frist time it will sync from the bootstrap." 
sleep 2
echo -e "This could take hours, days or weeks depending on the speed of your machine"
sleep 2
echo -e "When it's done the wallet will rename the bootstrap.dat file to bootstrap.dat.old"
sleep 2
echo -e "Then you can delete the bootstrap.dat.old file"

else
clear

fi

echo -e "Everything is Done $USER, ${RED}Trollcoin${NC} should now work with any newer vertion of Ubuntu"}
