#!/bin/bash

echo "----------------------";
echo "Création d'une clé SSH";
echo "----------------------";

ssh-keygen -b 4096 -t rsa;
# ssh-keygen -t ed25519;

UpdateUpgrade () {

    echo "-------------------------";
	echo "Mise à jour des libreries";
	echo "-------------------------";

    sudo apt update && sudo apt upgrade -y;
};
UpdateUpgrade;

AddUser () {

    echo "--------------------------";
	echo "Ajout de l'user sauvegarde";
	echo "--------------------------";

    sudo adduser sauvegarde;
};
AddUser;

Install () {

	echo "-----------------------------------------------------------";
	echo "Installation d'Apache - PHP - MariaDB - phpMyAdmin - xdebug";
	echo "-----------------------------------------------------------";

	sudo apt install software-properties-common -y;
    sudo add-apt-repository ppa:ondrej/php -y;
    sudo apt update -y;

    sudo apt install apache2 -y php8.2 -y php8.2-fpm -y php8.2-xml -y php8.2-curl -y php8.2-xdebug -y mariadb-server -y mariadb-client -y samba -y;
    sudo apt install php8.2-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,redis,intl,bcmath,fpm,ldap,bz2,pgsql,cgi} -y;

    sudo a2enmod proxy_fcgi setenvif;
    sudo a2enconf php8.2-fpm;

    sudo systemctl restart apache2;

};
Install;

phpMyAdmin () {

	echo "--------------------------------";
	echo "Installation de phpMyAdmin 5.1.3";
	echo "--------------------------------";

	echo "--------------------------------";
	echo "Suppresion des anciens fichiers.";
	echo "--------------------------------";

	sudo rm -rf /usr/share/phpmyadmin;
	sudo rm -rf /var/lib/phpmyadmin/tmp;

	echo "------------------------------------------------------------------------";
	echo "Récupération de la denière version de PMA, tar du dossier & suppression.";
	echo "------------------------------------------------------------------------";

	sudo wget https://files.phpmyadmin.net/phpMyAdmin/5.1.3/phpMyAdmin-5.1.3-english.tar.gz;
	sudo tar -xf phpMyAdmin-5.1.3-english.tar.gz;
	rm -rf phpMyAdmin-5.1.3-english.tar.gz;

	echo "---------------------------------------------------------------------------------";
	echo "Récupération de la denière version de PMA, tar du dossier & suppression terminés.";
	echo "---------------------------------------------------------------------------------";

	echo "----------------------------------------------------------------------";
	echo "Création & déplacement de tous les fichiers dans /usr/share/phpmyadmin";
	echo "----------------------------------------------------------------------";

	sudo mkdir /usr/share/phpmyadmin;
    sudo mv phpMyAdmin-5.1.3-english/* /usr/share/phpmyadmin/;

	echo "----------------------------------------------------------------";
	echo "Création des dossiers et changement des droits PMA dans /var/lib";
	echo "----------------------------------------------------------------";

	sudo mkdir -p /var/lib/phpmyadmin/tmp;
	sudo chown -R www-data:www-data /var/lib/phpmyadmin;

	echo "----------------------------------";
	echo "Création du fichier config.inc.php";
	echo "----------------------------------";

	sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php;

	echo "-----------------------------------------------------------------";
	echo "Suppression de l'ancien dossier et lancement de la configuration.";
	echo "-----------------------------------------------------------------";

	sudo rm -rf phpMyAdmin-5.1.3-english;

	echo "-----------------------------------------";
	echo "Installation de phpMyAdmin 5.1.3 terminée";
	echo "-----------------------------------------";

}
phpMyAdmin;

ConfigphpMyAdmin () {

    echo "----------------------------------------";
    echo "Configuration du fichier phpmyadmin.conf";
    echo "----------------------------------------";

    conf=/etc/apache2/conf-available/phpmyadmin.conf;

    sudo touch ${conf};

    echo "Alias /phpmyadmin /usr/share/phpmyadmin" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "<Directory /usr/share/phpmyadmin>" | sudo tee -a ${conf};
    echo "    Options Indexes FollowSymLinks" | sudo tee -a ${conf};
    echo "    DirectoryIndex index.php" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "    <IfModule mod_php5.c>" | sudo tee -a ${conf};
    echo "        AddType application/x-httpd-php .php" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "        php_flag magic_quotes_gpc Off" | sudo tee -a ${conf};
    echo "        php_flag track_vars On" | sudo tee -a ${conf};
    echo "        php_flag register_globals Off" | sudo tee -a ${conf};
    echo "        php_value include_path ." | sudo tee -a ${conf};
    echo "    </IfModule>" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "</Directory>" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "# Authorize for setup" | sudo tee -a ${conf};
    echo "<Directory /usr/share/phpmyadmin/setup>" | sudo tee -a ${conf};
    echo "    <IfModule mod_authn_file.c>" | sudo tee -a ${conf};
    echo "    AuthType Basic" | sudo tee -a ${conf};
    echo "    AuthName \"phpMyAdmin Setup\"" | sudo tee -a ${conf};
    echo "    AuthUserFile /etc/phpmyadmin/htpasswd.setup" | sudo tee -a ${conf};
    echo "    </IfModule>" | sudo tee -a ${conf};
    echo "    Require valid-user" | sudo tee -a ${conf};
    echo "</Directory>" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "# Disallow web access to directories that don't need it" | sudo tee -a ${conf};
    echo "<Directory /usr/share/phpmyadmin/libraries>" | sudo tee -a ${conf};
    echo "    Order Deny,Allow" | sudo tee -a ${conf};
    echo "    Deny from All" | sudo tee -a ${conf};
    echo "</Directory>" | sudo tee -a ${conf};
    echo "" | sudo tee -a ${conf};
    echo "<Directory /usr/share/phpmyadmin/setup/lib>" | sudo tee -a ${conf};
    echo "    Order Deny,Allow" | sudo tee -a ${conf};
    echo "    Deny from All" | sudo tee -a ${conf};
    echo "</Directory>" | sudo tee -a ${conf};

    sudo a2enconf phpmyadmin;

    echo "----------------------";
    echo "Configuration terminée";
    echo "----------------------";
};
ConfigphpMyAdmin;

ConfigApache () {

    echo "----------------------";
    echo "Configuration d'Apache";
    echo "----------------------";

    echo "----------------------";
    echo "Configuration du Virtual Host default";
    echo "----------------------";

    default=/etc/apache2/sites-available/000-default.conf;

    sudo sed -i '29i\ ' ${default};

    sudo sed -i '30i\        Include /etc/apache2/conf-available/phpmyadmin.conf' ${default};

    sudo systemctl restart apache2;

    echo "--------------------------------------------------";
    echo "Configuration d'un virtual host vers /var/www/[your_folder]";
    echo "--------------------------------------------------";

    sudo rm -rf /var/www/[your_folder];

    projet=/etc/apache2/sites-available/projetv1.conf;

    sudo touch ${projet};

    echo "<VirtualHost *:80>" | sudo tee -a ${projet};
    echo "" | sudo tee -a ${projet};
	echo "        ServerName dev.vladimir-projet.com" | sudo tee -a ${projet};
    echo "        ServerAdmin webmaster@localhost" | sudo tee -a ${projet};
    echo "        DocumentRoot /var/www/[your_folder]/public/" | sudo tee -a ${projet};
    echo "" | sudo tee -a ${projet};
   	echo "        ErrorLog \${APACHE_LOG_DIR}/error.log" | sudo tee -a ${projet};
	echo "        CustomLog \${APACHE_LOG_DIR}/access.log combined" | sudo tee -a ${projet};
	echo "" | sudo tee -a ${projet};
    echo "        <Directory /var/www/[your_folder]/>" | sudo tee -a ${projet};
    echo "              Options Indexes FollowSymLinks MultiViews" | sudo tee -a ${projet};
    echo "              AllowOverride All" | sudo tee -a ${projet};
    echo "              Order allow,deny" | sudo tee -a ${projet};
    echo "              allow from all" | sudo tee -a ${projet};
    echo "              Require all granted" | sudo tee -a ${projet};
    echo "        </Directory>" | sudo tee -a ${projet};
	echo "" | sudo tee -a ${projet};
    echo "        Include /etc/apache2/conf-available/phpmyadmin.conf" | sudo tee -a ${projet};
    echo "" | sudo tee -a ${projet};
    echo "</VirtualHost>" | sudo tee -a ${projet};

	sudo a2ensite projetv1.conf;

    sudo a2dissite 000-default.conf;

    sudo a2enmod rewrite && sudo service apache2 restart;

	sudo systemctl restart apache2;

    sudo chown -R ubuntu:ubuntu /var/www/;

    echo "----------------------------------------";
    echo "Configuration terminée";
    echo "----------------------------------------";
};
ConfigApache;

MariaDBConfiguration () {

	sudo mariadb -e "DROP USER IF EXISTS '[pseudo]'@'localhost';";
	sudo mariadb -e "CREATE USER '[pseudo]'@'localhost' IDENTIFIED BY '[your_password]';";
    sudo mariadb -e "GRANT ALL ON *.* TO '[pseudo]'@'localhost';";
    sudo mariadb -e "DROP USER IF EXISTS 'sauvegarde'@'localhost';";
    sudo mariadb -e "CREATE USER 'sauvegarde'@'localhost' IDENTIFIED VIA unix_socket USING '***';";
    sudo mariadb -e "GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* TO 'sauvegarde'@'localhost';";
    sudo mariadb -e "DROP DATABASE IF EXISTS projet;";
    sudo mariadb -e "CREATE DATABASE IF NOT EXISTS projet;";
    sudo mariadb -e "FLUSH PRIVILEGES;";

};
MariaDBConfiguration;


# Voir fiche NVM https://linuxize.com/post/how-to-install-node-js-on-ubuntu-22-04/
# Utilisation nvm ( Node Version Manager ).
# Permet d'installer plusieurs versions de Node.js sur la même machine.

Nodejs () {

	echo "-------------------------------------";
	echo "Update NodeJS lastest version v17.9.0";
	echo "-------------------------------------";

	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -;

	sudo apt-get install nodejs -y;
    # Compiler des modules complémentaires natifs à partir de npm
    sudo apt install build-essential -y;

};
Nodejs;

NPM () {
	echo "------------------";
	echo "Update NPM lastest";
	echo "------------------";

	sudo npm install -g npm@latest;

};
NPM;

# Installation de Node.js et npm à l'aide de NVM
NodejsNPM (){
    echo "----------------------------------------------";
	echo "Installation de Node.js et npm à l'aide de NVM";
	echo "----------------------------------------------";

    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    # Close and reopen your terminal to start using nvm or run the following to use it now:

    export NVM_DIR="$HOME/.nvm";
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh";  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion";  # This loads nvm bash_completion

    nvm install node;

    echo "--------------------------------------------------------";
	echo "Installons deux autres versions, la dernière version LTS";
	echo "--------------------------------------------------------";

    nvm install --lts;
    nvm install 14.19.3;

    # echo "---------------------------------";
    # echo "Affichons les versions installées";
    # echo "---------------------------------";

    # nvm ls

    # echo "---------------------------------------";
    # echo "Modifier la version actuellement active";
    # echo "---------------------------------------";

    # nvm use [version];

}
NodejsNPM;

InstallComposer () {

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
InstallComposer;

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

	php_ini=/etc/php/8.2/cli/php.ini;
	xdebug_file=/etc/php/8.2/mods-available/xdebug.ini;

	sudo sed -i '503i\display_errors = On' | sudo tee -a ${php_ini};
	sudo sed -i '556i\html_errors = On' | sudo tee -a ${php_ini};

	sudo systemctl restart apache2;

	echo "--------------------------------";
	echo "Configuration de xDebug terminée";
	echo "--------------------------------";

};
xDebugConfiguration;

SambaConfiguration () {

	echo "-------------------------------------------------------------";
	echo "Ajout de la configuration du partage dans /etc/samba/smb.conf";
	echo "-------------------------------------------------------------";

    smbconf=/etc/samba/smb.conf;

	echo '[Projet]' | sudo tee -a ${smbconf};
	echo '   comment = Partage Projet' | sudo tee -a ${smbconf};
	echo '   path = /var/www/[your_folder]/' | sudo tee -a ${smbconf};
	echo '   read only = no' | sudo tee -a ${smbconf};
	echo '   browseable = yes' | sudo tee -a ${smbconf};

    echo "-----------------------------------------";
	echo "SAISISSEZ LE MOT DE PASSE DU COMPTE SAMBA";
	echo "-----------------------------------------";

	sudo smbpasswd -a ubuntu; # ajouter l'user : définir mdp
	sudo service smbd restart;
    # supprimer l'user : sudo smbpasswd -x [nom_user];

	echo "----------------------------------------------";
	echo "Utilisateur ubuntu ajouté aux partages Samba";
	echo "----------------------------------------------";

};
SambaConfiguration;

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

# ---------------------------------------------------------------------------------------
# Commandes pour Laravel
# Laravel () {
#     echo "--------------------------------";
#     echo "Installation Laravel";
# 	  echo "--------------------------------";

#     1st option => Créer un projet de 0

#     echo "--------------------------------";
#     echo "Créer un projet de 0";
# 	  echo "--------------------------------";

#     cd /var/www;
#     composer create-project laravel/laravel [your_folder];
#     sudo chown -R ubuntu:ubuntu /var/www/[your_folder];
#     cd /var/www/[your_folder];

#     2nd option
#     echo "-----------------------";
#     echo "Cloner le projet depuis github";
#     echo "-----------------------";

#     cd /var/www;
#     git clone [lien_git_http];
#     sudo chown -R ubuntu:ubuntu /var/www/[your_folder];
#     cd /var/www/[your_folder];

#     Si vous pouvez, cloner le projet depuis une seule branche;
#     git clone --single-branch --branch [nom_branche] [lien_git_http];
#     cd /var/www/[your_folder];


# -- Après avoir installé ou cloné le projet
#     composer install;
#     npm install;
# -- Si severity vulnerability
#     npm audit fix

#     cp .env.example .env;
#     nano .env (mettre les infos de la BDD - mail);
#     php artisan key:generate;
#     php artisan cache:clear;



# -- Mettre à jour la base de données
#     php artisan migrate;
#     php artisan migrate:refresh;

# -- Si Msg d'erreur après composer install modifier dans le fichier composer.json le :
# "autoload": {
#        "psr-4": {
#            "App\\": "app/",
#            "Database\\Factories\\": "database/factories/",
#            "Database\\Seeders\\": "database/seeders/"
#        }
#    }


#    sudo chown -R ubuntu:www-data /var/www/[your_folder]/bootstrap/
#    sudo chown -R ubuntu:www-data /var/www/[your_folder]/public/
#    sudo chown -R www-data:www-data /var/www/[your_folder]/storage/

# };
# Laravel;