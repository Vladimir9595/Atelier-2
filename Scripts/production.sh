#!/bin/bash

UpdateUpgrade () {

    echo "---------------------";
	echo "Mise à jour des libreries";
	echo "---------------------";

    sudo apt update && sudo apt upgrade -y;
};
UpdateUpgrade;

Install () {

	echo "---------------------";
	echo "Installation d'Apache - PHP - MariaDB";
	echo "---------------------";

	sudo apt install apache2 php -y php-fpm -y mariadb-server -y mariadb-client;

    sudo a2enmod proxy_fcgi setenvif;
    sudo a2enconf php7.4-fpm;

    sudo systemctl restart apache2;

};
Install;


UpdateUpgrade () {

    echo "----------------";
	echo "Update & Upgrade";
	echo "----------------";

	sudo apt update && sudo apt upgrade -y;

	echo "-------------------------";
	echo "Update & Upgrade finished";
	echo "-------------------------";

}
UpdateUpgrade;

clean () {

	echo "------------------";
	echo "Clean all packages";
	echo "------------------";

	sudo apt clean;
	sudo apt autoclean -y;
	sudo apt autopurge -y;

}
clean;

Reboot () {

    i=5;
	b=0;

	while [ "$i" -gt "$b" ] ; do
		echo -n 'Le serveur va redémarrer dans' "$i" 'secondes.\r';
		i=$((i-1))
		sleep 1;
	done

	sudo shutdown -r now;

	# Redémarre nécessaire pour appliquer les changements.

};
Reboot
