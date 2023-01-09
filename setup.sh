#!/bin/bash
set -e
HC='\033[1;32m'
NC='\033[0m'
echo "installing docker and docker compose"
apt install docker docker-compose
echo ""
read -e -p " [?] Enter your domain or subdomain: " MYDOMAIN
MYDOMAIN=$(echo "$MYDOMAIN" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
[[ -z "$MYDOMAIN" ]] && { echo "Error: Domain URL is needed."; exit 1; }

echo -e "\n$HC+$NC Checking IP <=> Domain..."
RESIP=$(dig +short "$MYDOMAIN" | grep '^[.0-9]*$' || echo 'NONE')
SRVIP=$(curl -qs http://checkip.amazonaws.com  | grep '^[.0-9]*$' || echo 'NONE')

if [ "$RESIP" = "$SRVIP" ]; then
    echo -e "\n$HC+$NC $RESIP => $MYDOMAIN is valid."
else
    echo -e "\033[1;31m -- Error: \033[0m Server IP is $HC$SRVIP$NC but '$MYDOMAIN' resolves to \033[1;31m$RESIP$NC\n"
    echo -e "If you have just updated the DNS record, wait a few minutes and then try again. \n"
    exit;
fi

echo -e "\n$HC+$NC Installing certbot..."
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

echo -e "\n$HC+$NC Issuing SSL certificate..."
#certbot certonly --standalone -d $MYDOMAIN --register-unsafely-without-email --non-interactive --agree-tos
#cp -r /etc/letsencrypt ./
docker-compose up -d
echo -e "x-ui is running on $MYDOMAIN:54321 you can change setting by 'docker exec -it x-ui x-ui.sh'"