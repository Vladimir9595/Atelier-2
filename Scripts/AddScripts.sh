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
					git clone https://github.com/AlxisHenry/CCI-2021-PORTFOLIO.git /var/www/main

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
				echo " ssh ubuntu@92.222.16.109 -p 62303 'sudo mkdir /var/www/main'" | tee -a ${prodsh}
				echo " ssh ubuntu@92.222.16.109 -p 62303 'sudo chown -R ubuntu:www-data /var/www/main'" | tee -a ${prodsh}
				echo "	echo 'Droit sur /var/www distant attribués à ubuntu'" | tee -a ${prodsh}
				echo "	rsync -azP --exclude-from '/home/ubuntu/exclude_list' -e 'ssh -p 62303' /var/www/main/ ubuntu@92.222.16.109:/var/www/main" | tee -a ${prodsh}
				echo "	echo 'Fichiers/Dossiers du projet copiés et envoyés'" | tee -a ${prodsh}
				echo "	ssh ubuntu@92.222.16.109 -p 62303 'sudo chown -R www-data:www-data /var/www/main'" | tee -a ${prodsh}
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