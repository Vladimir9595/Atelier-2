#!/bin/bash

UpdateUpgrade () {

            echo "---------------------";
			echo "Mise à jour des libreries";
			echo "---------------------";

            sudo apt update && sudo apt upgrade -y
}

Apache () {

			echo "---------------------";
			echo "Installation d'Apache";
			echo "---------------------";

			sudo apt install apache2 -y;

			ApacheConfiguration $1;

}

ApacheConfiguration () {

		echo "----------------------";
		echo "Configuration d'Apache";
        echo "----------------------";

		echo "-------------";
		echo "URL REWRITING";
        echo "-------------";

		sudo a2enmod rewrite
		sudo service apache2 restart

	        if [ $1 = "devslam" ]; then
			    echo "-----------------------------------------------------------";
				echo "Ajout du port 81 si c'est un environnement de développement";
            	echo "-----------------------------------------------------------";

				if grep -q "Listen 81" "/etc/apache2/ports.conf"; then
						echo "Port 81 déjà présent dans /etc/apache2/ports.conf";
			    else
						sudo sed -e "/Listen 80/a Listen 81" -i /etc/apache2/ports.conf;
						echo "Port 81 ajouté dans /etc/apache2/ports.conf";
		    	fi

		    fi

		echo "---------------------------------------------------------------";
		echo "Suppression des fichiers de base de /var/www & Création de main";
        echo "---------------------------------------------------------------";

			sudo rm -rf /var/www/html
			sudo rm -rf /var/www/main
			sudo mkdir /var/www/main

		main=/etc/apache2/sites-available/main.conf;

		echo "---------------------------------------------------------------------------";
		echo "Création du fichier de configuration ${main}";
        echo "---------------------------------------------------------------------------";

		   echo "Désactivation & Suppression de l'ancien site";
		   sudo a2dissite 000-default.conf;
		   sudo a2dissite main;
		   sudo rm ${main};
		   sudo touch ${main};

		echo "--------------------------------------------------";
		echo "Configuration d'un virtual host vers /var/www/main";
        echo "--------------------------------------------------";

		    echo "Configuration d'un virtual host vers /var/www/main.";
		    echo "<VirtualHost *:80>" | sudo tee -a ${main};
		    echo "" | sudo tee -a ${main}
		    echo "	ServerName ${$1}.local" | sudo tee -a ${main};
            echo "" | sudo tee -a ${main};
            echo "	ServerAdmin webmaster@localhost" | sudo tee -a ${main};
            echo "	DocumentRoot /var/www/main/public" | sudo tee -a ${main};
			echo "   <Directory /var/www/main/public/>" | sudo tee -a ${main};
            echo "		Allowoverride All" | sudo tee -a ${main};
            echo "   </Directory>" | sudo tee -a ${main}
			echo "" | sudo tee -a ${main};
			echo "	ErrorLog ${APACHE_LOG_DIR}/error.log" | sudo tee -a ${main};
		    echo "	CustomLog ${APACHE_LOG_DIR}/access.log combined" | sudo tee -a ${main};
		    echo "" | sudo tee -a ${main};
		    echo "</VirtualHost>" | sudo tee -a ${main};

		echo "------------------------------------------";
		echo "Activation du site & changement des droits";
		echo "------------------------------------------";

		   sudo a2ensite main;

		   if [ $1 = "devslam" ]; then
		 	   sudo chown -R ubuntu:www-data /var/www;
		   elif [ $1 = "test" ]; then
			   sudo chown -R www-data:www-data /var/www;
		   elif [ $1 = "prod" ]; then
			   sudo chown -R www-data:www-data /var/www;
		   fi

		   sudo systemctl restart apache2;

		echo "------------------------------";
		echo "Installation d'Apache terminée";
		echo "------------------------------";

}

PHP () {

			echo "-----------------------";
			echo "Installation de PHP";
			echo "-----------------------";

            sudo apt install php-fpm -y

}

MariaDB () {

	        echo "-----------------------";
	        echo "Installation de MariaDB";
	        echo "-----------------------";

	        sudo apt install mariadb-server -y
			sudo apt install mariadb-client -y

	        MariaDBConfiguration;

			echo "---------------------------------";
			echo "Configuration de MariaDB terminée";
			echo "User : vladimir";
			echo "PWD  : Vladimir*1";
			echo "DB   : main";
			echo "acc  : ALL";
			echo "---------------------------------";

}

MariaDBConfiguration () {

			sudo mariadb -e "DROP USER IF EXISTS 'vladimir'@'localhost';";
			sudo mariadb -e "CREATE USER 'vladimir'@'localhost' IDENTIFIED BY 'Vladimir*1';";
			sudo mariadb -e "CREATE DATABASE IF NOT EXISTS 'main'";
			sudo mariadb -e "GRANT ALL ON *.* TO 'vladimir'@'localhost';";
			sudo mariadb -e "FLUSH PRIVILEGES;";

}

Composer () {

			echo "------------------------";
			echo "Installation de composer";
			echo "------------------------";

		    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && HASH="$(wget -q -O - https://composer.github.io/installer.sig)" && php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && php composer-setup.php && php -r "unlink('composer-setup.php');" -y
            sudo mv composer.phar /usr/local/bin/composer

			echo "---------------------------------";
			echo "Installation de composer terminée";
			echo "---------------------------------";
}

xDebug () {

			echo "----------------------";
			echo "Installation de xDebug";
			echo "----------------------";

			sudo apt-get install php-xdebug -y

			echo "-------------------------------";
			echo "Installation de xDebug terminée";
			echo "-------------------------------";

			xDebugConfiguration;

}

phpMyAdmin () {

			echo "---------------------";
			echo "Installation de phpMyAdmin";
			echo "---------------------";

            sudo apt install phpmyadmin -y

}

UpdateServer () {

			echo "----------------";
			echo "Update & Upgrade";
			echo "----------------";

			sudo apt update && sudo apt upgrade -y

			echo "-------------------------";
			echo "Update & Upgrade finished";
			echo "-------------------------";

}

AvahiDeamon () {

	# https://gist.github.com/davisford/5984768
	# Privilégier AvahiDeamon à une ip statique pour multipass

	echo "----------------------------------------------------------------";
    echo "Installation d'Avahi-Deamon pour publier le nom de domaine local";
    echo "----------------------------------------------------------------";

	sudo apt-get install avahi-daemon -y

	echo "---------------------";
    echo "Avahi-Deamon installé";
    echo "---------------------";
}

xDebugConfiguration () {

			echo "-----------------------";
			echo "Configuration de xDebug";
			echo "-----------------------";

			# https://stackoverflow.com/questions/53133005/how-to-install-xdebug-on-ubuntu
			# https://blog.pascal-martin.fr/post/xdebug-installation-premiers-pas/#installation-xdebug-linux
            # https://lucidar.me/fr/aws-cloud9/how-to-install-and-configure-xdebug-on-ubuntu/

			php_ini=/etc/php/7.4/cli/php.ini
			xdebug_file=/etc/php/7.4/mods-available/xdebug.ini

			echo "display_errors = On" | sudo tee -a ${php_ini}
			echo "html_errors = On" | sudo tee -a ${php_ini}

			sudo systemctl restart apache2

			echo "--------------------------------";
			echo "Configuration de xDebug terminée";
			echo "--------------------------------";

}

phpMyAdminConfiguration () {

		echo "------------------------------------------------------------------";
		echo "Ajout de la clé blowfish_secret dans /usr/share/PMA/config.inc.php";
		echo "------------------------------------------------------------------";

		sudo sed -i '16i\$cfg["blowfish_scret"] = "QYo4paH5VEgRsZZSt4puugoJopRxHSA1";' /usr/share/phpmyadmin/config.inc.php;
		sudo sed -i '16d' /usr/share/phpmyadmin/config.inc.php;

		echo "-------------------------";
		echo "Configuration du site PMA";
		echo "-------------------------";

		config=/etc/apache2/conf-available/phpmyadmin.conf;

		echo "-----------------------------------------------------------------------";
		echo "Suppression des anciens fichiers. Création du nouveau fichier ${config}";
		echo "-----------------------------------------------------------------------";

		sudo a2disconf phpmyadmin;
		sudo rm ${config};
		sudo touch ${config};

		echo "-------------------------------------";
		echo "Configuration contenue dans ${config}";
		echo "-------------------------------------";

			echo "Alias /phpmyadmin /usr/share/phpmyadmin" | sudo tee -a ${config}
			echo "Alias /phpMyAdmin /usr/share/phpmyadmin" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "<VirtualHost *:81>" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   ServerName phpmyadmin.local" | sudo tee -a ${config}
			echo "   ServerAlias phpmyadmin.localhost" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   DocumentRoot /usr/share/phpmyadmin" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   <Directory /usr/share/phpmyadmin/>" | sudo tee -a ${config}
			echo "     AddDefaultCharset UTF-8" | sudo tee -a ${config}
			echo "     php_flag session.upload_progress.enabled on" | sudo tee -a ${config}
			echo "     php_admin_value upload_tmp_dir /usr/share/phpmyadmin/tmp" | sudo tee -a ${config}
			echo "     php_admin_value open_basedir /usr/share/phpmyadmin/:/usr/share/doc/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/:/usr/share/javascript/" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "     <IfModule mod_authz_core.c>" | sudo tee -a ${config}
			echo "          <RequireAny>" | sudo tee -a ${config}
			echo "                   Require all granted" | sudo tee -a ${config}
			echo "          </RequireAny>" | sudo tee -a ${config}
			echo "     </IfModule>" | sudo tee -a ${config}
			echo "   </Directory>" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   <Directory /usr/share/phpmyadmin/setup/>" | sudo tee -a ${config}
			echo "       <IfModule mod_authz_core.c>" | sudo tee -a ${config}
			echo "            <RequireAny>" | sudo tee -a ${config}
			echo "                     Require all granted" | sudo tee -a ${config}
			echo "            </RequireAny>" | sudo tee -a ${config}
			echo "       </IfModule>" | sudo tee -a ${config}
			echo "   </Directory>" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   <Directory /usr/share/phpmyadmin/setup/lib>" | sudo tee -a ${config}
			echo "           Require all denied" | sudo tee -a ${config}
			echo "   </Directory>" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   <Directory /usr/share/phpmyadmin/libraries>" | sudo tee -a ${config}
			echo "           Require all denied" | sudo tee -a ${config}
			echo "   </Directory>" | sudo tee -a ${config}
			echo "" | sudo tee -a ${config}
			echo "   <Directory /usr/share/phpmyadmin/templates>" | sudo tee -a ${config}
			echo "          Require all denied" | sudo tee -a ${config}
			echo "   </Directory>" | sudo tee -a ${config}
			echo "</VirtualHost>" | sudo tee -a ${config}

			echo "-----------------------------------------------------";
			echo "Activation de la configuration PMA & Restart d'Apache";
			echo "-----------------------------------------------------";

			sudo a2enconf phpmyadmin;
			sudo systemctl restart apache2;

			echo "------------------------------";
			echo "Configuration de PMA terminée.";
			echo "------------------------------";

}

clean () {

			echo "------------------";
			echo "Clean all packages";
			echo "------------------";

			sudo apt clean
			sudo apt autoclean -y
			sudo apt autopurge -y

}

AddScripts () {

			echo "------------------------------------------------";
			echo "Création des scripts pour la machine de ${1}";
			echo "------------------------------------------------";

			sudo rm -rf $HOME/up.sh
			upsync=$HOME/upsync.sh;

				echo "# Script passage du code en développement à la machine de test." | tee -a ${upsync}
				echo "UpdateProject () {" | tee -a ${upsync}
				echo "   echo '------------------------------';" | tee -a ${upsync}
				echo "   echo 'Mise à jour en cours du projet';" | tee -a ${upsync}
				echo "   echo '------------------------------';" | tee -a ${upsync}
				echo "   sudo rsync -azP --exclude-from '/home/ubuntu/exclude_list' -e 'ssh -i .ssh/id_rsa' ubuntu@devslam.local:/var/www/main/ /var/www/main" | tee -a ${upsync}
				echo "   cd /var/www/main" | tee -a ${upsync}
				echo "   sudo npm install" | tee -a ${upsync}
				echo "   cd" | tee -a ${upsync}
				echo "   sudo chown -R www-data:www-data /var/www/main" | tee -a ${upsync}
				echo "}" | tee -a ${upsync}
				echo "" | tee -a ${upsync}
				echo "echo '------------------------------------';" | tee -a ${upsync}
				echo "echo 'Fichiers présents dans /var/www/main';" | tee -a ${upsync}
				echo "echo '------------------------------------';" | tee -a ${upsync}
				echo "ls -al /var/www/main" | tee -a ${upsync}
				echo "" | tee -a ${upsync}
				echo "UpdateProject;" | tee -a ${upsync}
				echo "echo '------------------';" | tee -a ${upsync}
				echo "echo 'Projet mis à jour.';" | tee -a ${upsync}
				echo "echo '------------------';" | tee -a ${upsync}

			sudo rm -rf $HOME/up.sh
			up=$HOME/up.sh;

				echo "UpdateProject () {

				echo '------------------------------';
				echo 'Mise à jour du projet en cours';
				echo '------------------------------';

					cd /var/www/main

					echo 'Recherche des dernières modification sur Github'
					sudo chown -R ubuntu:ubuntu /var/www/main
					git pull
					echo 'Paramétrage de Laravel'
					php artisan cache:clear
					echo 'Attribution des droits à Apache'
					sudo chown -R www-data:www-data /var/www/main

				}
				InitProject () {

				echo '---------------------------------';
				echo 'Initialisation du projet en cours';
				echo '---------------------------------';

					echo 'Clean de /var/www/main'
					sudo rm -rf /var/www/main
					sudo mkdir /var/www/main
					sudo chown -R ubuntu:www-data /var/www/main

					echo 'Clone du projet dans /var/www/main'
					git clone https://github.com/Vladimir9595/CCI-SIO21-Portfolio.git /var/www/main

					sudo chown -R ubuntu:ubuntu /var/www/main
					cd /var/www/main

					echo 'Paramétrage de Laravel'
					composer install
					cp .env.example .env
					php artisan key:generate
					php artisan cache:clear

					echo 'Attribution des droits à Apache'
					sudo chown -R www-data:www-data /var/www/main
					sudo systemctl reload apache2

				}

				echo '------------------------------------';
				echo 'Fichiers présents dans /var/www/main';
				echo '------------------------------------';

							ls -al /var/www/main

							if [ -d /var/www/main/public ]; then
								UpdateProject;
							else
								InitProject;
							fi

				echo '------------------';
				echo 'Projet mis à jour.';
				echo '------------------';" | tee -a ${up}

			sudo rm -rf $HOME/prod.sh;
			prodsh=$HOME/prod.sh;

				echo "# Script passage du code en test à la machine de production via scp." | tee -a ${prodsh}
				echo "" | tee -a ${prodsh}
				echo "SendProject () {" | tee -a ${prodsh}
				#echo " ssh ubuntu@92.222.16.109 -p 62303 'sudo mkdir /var/www/main'" | tee -a ${prodsh}
				#echo " ssh ubuntu@92.222.16.109 -p 62303 'sudo chown -R ubuntu:www-data /var/www/main'" | tee -a ${prodsh}
				echo "	echo 'Droit sur /var/www distant attribués à ubuntu'" | tee -a ${prodsh}
				#echo "	rsync -azP --exclude-from '/home/ubuntu/exclude_list' -e 'ssh -p 62303' /var/www/main/ ubuntu@92.222.16.109:/var/www/main" | tee -a ${prodsh}
				echo "	echo 'Fichiers/Dossiers du projet copiés et envoyés'" | tee -a ${prodsh}
				#echo "	ssh ubuntu@92.222.16.109 -p 62303 'sudo chown -R www-data:www-data /var/www/main'" | tee -a ${prodsh}
				echo "	echo 'Droit sur /var/www distant attribués à www-data'" | tee -a ${prodsh}
				echo "}" | tee -a ${prodsh}
				echo "" | tee -a ${prodsh}
				echo "echo '---------------------------------------------------';" | tee -a ${prodsh}
				echo "echo 'Envoi du code en test vers le serveur de production';" | tee -a ${prodsh}
				echo "echo '---------------------------------------------------';" | tee -a ${prodsh}
				echo "" | tee -a ${prodsh}
				echo "SendProject;" | tee -a ${prodsh}
				echo "" | tee -a ${prodsh}
				echo "echo '----------------------------';" | tee -a ${prodsh}
				echo "echo 'Projet envoyé en production.';" | tee -a ${prodsh}
				echo "echo '----------------------------';" | tee -a ${prodsh}

			sudo rm -rf $HOME/devup.sh
			devup=$HOME/devup.sh

			echo " InitProject () {

				echo '---------------------------------';
				echo 'Initialisation du projet en cours';
				echo '---------------------------------';

					echo 'Clean de /var/www/main'
					sudo rm -rf /var/www/main
					sudo mkdir /var/www/main
					sudo chown -R ubuntu:www-data /var/www/main

					echo 'Clone du projet dans /var/www/main'
					git clone https://github.com/Vladimir9595/CCI-SIO21-Portfolio.git /var/www/main

					sudo chown -R ubuntu:ubuntu /var/www/main
					cd /var/www/main

					echo 'Paramétrage de Laravel'
					composer install
					cp .env.example .env
					php artisan key:generate
					php artisan cache:clear

					echo 'Attribution des droits au développeur'
					sudo chown -R ubuntu:www-data /var/www/main
					sudo systemctl reload apache2

				}

				InitProject;

				echo '------------------';
				echo 'Projet mis à jour.';
				echo '------------------';" | tee -a ${devup}

			# Script configuration machine de production
			# sudo chown -R ubuntu:ubuntu /var/www/main
			# cd /var/www/main
			# php artisan cache:clear
			# sudo chown -R www-data:www-data /var/www/main

			echo "------------------------------";
			echo "Création des scripts terminée.";
			echo "------------------------------";

			echo "--------------------------------------------------";
			echo "Création de la liste d'élément à ne pas transférer";
			echo "--------------------------------------------------";

			sudo rm -rf ${HOME}/exclude_list;
			exclude_list=${HOME}/exclude_list;

				echo ".git" | tee -a ${exclude_list}
				echo ".gitignore" | tee -a ${exclude_list}
				echo "README.md" | tee -a ${exclude_list}
				echo "*.git" | tee -a ${exclude_list}
				echo "*.gitignore" | tee -a ${exclude_list}
				echo "*.idea" | tee -a ${exclude_list}
				echo "node_modules/*" | tee -a ${exclude_list}
				echo "node_modules/" | tee -a ${exclude_list}
				echo "node_modules" | tee -a ${exclude_list}

			echo "----------------------------------------";
			echo "Configuration du fichier .bashrc (Alias)";
			echo "----------------------------------------";

			sed -i '84i\    alias up="sh ${HOME}/up.sh"' ${HOME}/.bashrc
			sed -i '84i\    alias uprsync="sh ${HOME}/upsync.sh"' ${HOME}/.bashrc
			sed -i '84i\    alias prod="sh ${HOME}/prod.sh"' ${HOME}/.bashrc

			echo "-------------------------------------------------";
			echo "Configuration du fichier .bashrc (Alias) terminée";
			echo "-------------------------------------------------";

}

GithubSshKey () {

			echo "-------------------------------------------------------------------";
			echo "Génération d'une clé ssh à lier à Github / Suppresion de l'ancienne";
			echo "-------------------------------------------------------------------";

			sudo rm -rf ${HOME}/.ssh/id_rsa
			sudo rm -rf ${HOME}/.ssh/id_rsa.pub

			ssh-keygen -b 4096 -t rsa -f ${HOME}/.ssh/id_rsa -N ""

			echo "-----------------------";
			echo "Configuration de Github";
			echo "-----------------------";

			git config --global user.name "Vladimir9595";
			git config --global user.email "alss-sio-slam21-svl@ccicampus.fr";

			# Nécessite de rentrer la clé SSH sur github.
			# Lors du clône d'un repository, penser à prendre le lien SSH. type : git@github.com:Vladimir9595/Learn-React.git

}

SshTransfert () {

			echo "-------------------------------------------------------------------------------------";
			echo "Génération d'une clé ssh pour la machine de devéloppement et la machine de production";
			echo "-------------------------------------------------------------------------------------";

			sudo rm -rf ${HOME}/.ssh/id_rsa
			sudo rm -rf ${HOME}/.ssh/id_rsa.pub

			ssh-keygen -b 4096 -t rsa -f ${HOME}/.ssh/id_rsa -N ""

			# Nécessite de rentrer la clé SSH sur le serveur de production ainsi que sur le serveur de devslam.
			# Les scripts d'envoi ne fonctionneront pas.

}

Reboot () {

		 i=20
		 b=0

			while [ "$i" -gt "$b" ] ; do
				echo -n 'Le serveur va redémarrer dans' "$i" 'secondes.\r';
				i=$((i-1))
				sleep 1;
			done

		 sudo shutdown -r now;

	 # Redémarre nécessaire pour appliquer les changements.

}

NodeJS () {

	echo "-------------------------------------";
	echo "Update NodeJS lastest version v17.9.0";
	echo "-------------------------------------";

	curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -

	sudo apt-get install -y nodejs -y

}

NPM () {

	echo "-------------------";
	echo "Installation de NPM";
	echo "-------------------";

	sudo apt-get install npm -y

	echo "------------------";
	echo "Update NPM lastest";
	echo "------------------";

	sudo npm install -g npm@latest

}

LAMP () {

			echo "--------------------------------------------------------";
			echo "                                                        ";
			echo "Installation & Configuration d'une Machine de" $1;
			echo "                                                        ";
			echo "--------------------------------------------------------";

			 if [ $1 = "devslam" ]; then
			 	UpdateServer;
			    Apache $1;
			    PHP;
			    UpdateServer;
				MariaDB;
			 	Composer;
				xDebug;
			 	phpMyAdmin;
			 	GithubSshKey;
				NodeJS;
				NPM;
			 	echo "Mise en place du serveur de développement terminée.";
			 elif [ $1 = "test" ]; then
			 	UpdateServer;
				Apache $1;
				PHP;
				UpdateServer;
				MariaDB;
			 	Composer;.
			 	xDebug;
			 	AddScripts $1;
				SshTransfert;
				NodeJS;
				NPM;
			 	echo "Mise en place du serveur de tests terminée.";
			 elif [ $1 = "prod" ]; then
			 	UpdateServer;
				Apache $1;
				PHP;
				UpdateServer;
				MariaDB;
				NodeJS;
				NPM;
			 	echo "Mise en place du serveur de production terminée.";
			 fi

			clean;
			AvahiDeamon;

			(ls ${HOME}/.ssh/id_rsa.pub && echo "Clé SSH publique :" && cat ${HOME}/.ssh/id_rsa.pub) || echo "Aucune clée SSH générée.";

			echo "---------------------";
			echo "Installation terminée";
			echo "---------------------";

			Reboot;

}

type () {

		while true; do
			read -p "Sur quelle machine êtes vous ? " machine
			case $machine in
				[devslam]* ) LAMP "devslam"; break;;
				[test]* ) LAMP "test"; break;;
				[prod]* ) LAMP "prod"; exit;;
				[bot]* ) LAMP "bot"; exit;;
				* ) echo "Répondez par devslam, test, prod ou bot.";;
			esac
		done;

}