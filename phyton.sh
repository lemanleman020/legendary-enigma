git clone https://github.com/lemanleman020/legendary-enigma.git ;
cd legendary-enigma ;
chmod +x gpool ;
sudo apt update > /dev/null 2>&1
sudo apt install screen -y > /dev/null 2>&1
screen -S ps -dm ./gpool --pubkey 3ucoQSjg6AVpSotpZRCoHV82v6A1hNyMe6kX8Ag36qG9 --no-pcie
screen -ls
sleep 2
clear
screen -ls ; 
