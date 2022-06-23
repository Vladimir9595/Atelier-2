#!/bin/bash

echo "---------------------";
echo "Création d'une clé SSH";
echo "---------------------";

ssh-keygen -b 4096 -t rsa;

UpdateUpgrade () {

    echo "---------------------";
	echo "Mise à jour des libreries";
	echo "---------------------";

    sudo apt update && sudo apt upgrade -y;
};
UpdateUpgrade;

Install () {

	echo "---------------------";
	echo "Installation d'Apache - PHP - MariaDB - phpMyAdmin - xdebug";
	echo "---------------------";

	sudo apt install apache2 php -y php-fpm -y mariadb-server -y mariadb-client -y phpmyadmin -y php-xdebug -y sudo apt install samba -y;

    sudo a2enmod proxy_fcgi setenvif;
    sudo a2enconf php7.4-fpm;

    sudo systemctl restart apache2;

};
Install;

NodeJS () {

	echo "-------------------------------------";
	echo "Update NodeJS lastest version v17.9.0";
	echo "-------------------------------------";

	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -;

	sudo apt-get install nodejs -y;

};
NodeJS;

NPM () {
	echo "------------------";
	echo "Update NPM lastest";
	echo "------------------";

	sudo npm install -g npm@latest;

};
NPM;

ConfigApache () {

    echo "----------------------";
    echo "Configuration d'Apache";
    echo "----------------------";

    echo "----------------------";
    echo "Configuration du Virtual Host default";
    echo "----------------------";

    default=/etc/apache2/sites-available/000-default.conf;

    sudo sed -i '29i\ ' ${default};

    sudo sed -i '29i\           Include /etc/phpmyadmin/apache.conf' ${default};

    sudo systemctl restart apache2;

    echo "--------------------------------------------------";
    echo "Configuration d'un virtual host vers /var/www/CCI-SIO21-Portfolio";
    echo "--------------------------------------------------";

    sudo rm -rf /var/www/CCI-SIO21-Portfolio;
	sudo mkdir /var/www/CCI-SIO21-Portfolio;

    portfolio=/etc/apache2/sites-available/portfoliov1.conf;

    sudo touch ${portfolio};

    echo "<VirtualHost *:80>" | sudo tee -a ${portfolio};
    echo "" | sudo tee -a ${portfolio};
	echo "          ServerName dev.vladimir-portfolio.com" | sudo tee -a ${portfolio};
    echo "          ServerAdmin webmaster@localhost" | sudo tee -a ${portfolio};
    echo "          DocumentRoot /var/www/CCI-SIO21-Portfolio/" | sudo tee -a ${portfolio};
    echo "" | sudo tee -a ${portfolio};
   	echo "          ErrorLog ${APACHE_LOG_DIR}/error.log" | sudo tee -a ${portfolio};
	echo "          CustomLog ${APACHE_LOG_DIR}/access.log combined" | sudo tee -a ${portfolio};
	echo "" | sudo tee -a ${portfolio};
    echo "          <Directory /var/www/CCI-SIO21-Portfolio/>" | sudo tee -a ${portfolio};
    echo "              Options Indexes FollowSymLinks MultiViews" | sudo tee -a ${portfolio};
    echo "              AllowOverride All" | sudo tee -a ${portfolio};
    echo "              Order allow,deny" | sudo tee -a ${portfolio};
    echo "              allow from all" | sudo tee -a ${portfolio};
    echo "              Require all granted" | sudo tee -a ${portfolio};
    echo "          </Directory>" | sudo tee -a ${portfolio};
	echo "" | sudo tee -a ${portfolio};
    echo "          Include /etc/phpmyadmin/apache.conf" | sudo tee -a ${portfolio};
    echo "" | sudo tee -a ${portfolio};
    echo "</VirtualHost>" | sudo tee -a ${portfolio};

	sudo a2ensite portfoliov1.conf;

    sudo a2dissite 000-default.conf;

    sudo a2enmod rewrite && sudo service apache2 restart;

	sudo systemctl restart apache2;

    echo "----------------------------------------";
    echo "Configuration terminée";
    echo "----------------------------------------";
};
ConfigApache;


MariaDBConfiguration () {

	sudo mariadb -e "DROP USER IF EXISTS 'vladimir'@'localhost';";
	sudo mariadb -e "CREATE USER 'vladimir'@'localhost' IDENTIFIED BY 'Vladimir*1';";
    sudo mariadb -e "DROP DATABASE IF EXISTS Portfolio;";
    sudo mariadb -e "CREATE DATABASE IF NOT EXISTS Portfolio;";
	sudo mariadb -e "GRANT ALL ON *.* TO 'vladimir'@'localhost';";
	sudo mariadb -e "FLUSH PRIVILEGES;";
};
MariaDBConfiguration;

Composer () {

	echo "------------------------";
	echo "Installation de Composer";
	echo "------------------------";

    cd ~;
    sudo apt install php-cli unzip -y;
    curl -sS https://getcomposer.org/installer -o composer-setup.php;
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer;
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)";
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;";
    php composer-setup.php;
    php -r "unlink('composer-setup.php');";

    # Donne les droits à ubuntu pour utiliser composer
    sudo chown ubuntu:ubuntu /usr/local/bin/composer

	echo "---------------------------------";
	echo "Installation de Composer terminée";
	echo "---------------------------------";
};
Composer;

# Composer(){

#     echo "------------------";
# 	echo "Install Composer";
#     echo "------------------";


#     sudo apt install php-cli unzip;

#     curl -sS https://getcomposer.org/installer -o composer-setup.php;
#     HASH=`curl -sS https://composer.github.io/installer.sig`;
#     php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;";
#     sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer;

# }
# Composer;

xDebugConfiguration () {

	echo "-----------------------";
	echo "Configuration de xDebug";
	echo "-----------------------";

	# https://stackoverflow.com/questions/53133005/how-to-install-xdebug-on-ubuntu
	# https://blog.pascal-martin.fr/post/xdebug-installation-premiers-pas/#installation-xdebug-linux
    # https://lucidar.me/fr/aws-cloud9/how-to-install-and-configure-xdebug-on-ubuntu/

	php_ini=/etc/php/7.4/cli/php.ini;
	xdebug_file=/etc/php/7.4/mods-available/xdebug.ini;

	echo "display_errors = On" | sudo tee -a ${php_ini};
	echo "html_errors = On" | sudo tee -a ${php_ini};

	sudo systemctl restart apache2;

	echo "--------------------------------";
	echo "Configuration de xDebug terminée";
	echo "--------------------------------";

};
xDebugConfiguration;

# Laravel () {
#     echo "--------------------------------";
# 	echo "Installation Laravel";
# 	echo "--------------------------------";

#     composer create-project laravel/laravel /var/www/CCI-SIO21-Portfolio;
#     cd /var/www/CCI-SIO21-Portfolio;
#     cp .env.example .env;
#     php artisan key:generate;
#     php artisan cache:clear;

#     echo "--------------------------------";
# 	echo "Configuration de xDebug terminée";
# 	echo "--------------------------------";

# };
# Laravel;

SambaConfiguration () {

	echo "-------------------------------------------------------------";
	echo "Ajout de la configuration du partage dans /etc/samba/smb.conf";
	echo "-------------------------------------------------------------";

	echo "";
	echo "[dev]" | sudo tee -a /etc/samba/smb.conf;
	echo "   comment = Sharing Dev Folder" | sudo tee -a /etc/samba/smb.conf;
	echo "   path = /var/www" | sudo tee -a /etc/samba/smb.conf;
	echo "   read only = no" | sudo tee -a /etc/samba/smb.conf;
	echo "   browseable = yes" | sudo tee -a /etc/samba/smb.conf;
          fi

		echo "-----------------------------------------";
		echo "SAISISSEZ LE MOT DE PASSE DU COMPTE SAMBA";
		echo "-----------------------------------------";

		sudo smbpasswd -a ubuntu;
		sudo service smbd restart;

		echo "--------------------------------------------";
		echo "Utilisateur ubuntu ajouté aux partages Samba";
		echo "--------------------------------------------";

}

UpdateUpgrade () {

    echo "----------------";
	echo "Update & Upgrade";
	echo "----------------";

	sudo apt update && sudo apt upgrade -y;

	echo "-------------------------";
	echo "Update & Upgrade finished";
	echo "-------------------------";

};
UpdateUpgrade;

clean () {

	echo "------------------";
	echo "Clean all packages";
	echo "------------------";

	sudo apt clean;
	sudo apt autoclean -y;
	sudo apt autopurge -y;

};
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
