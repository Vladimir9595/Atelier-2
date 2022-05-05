UpdateUpgrade () {
            echo "----------------------------------------";
            echo "Exécution : Net-tools ; Update & Epgrade";
            echo "----------------------------------------";

            sudo apt update && sudo apt upgrade -y

            echo "----------------------------------------------";
            echo "FIN - Exécution : Net-tools ; Update & Epgrade";
            echo "----------------------------------------------";
}
UpdateUpgrade


InstallationPhpApach2MariaDBCliServ () {
            echo "----------------------------------------";
            echo "Installation : Apache2 MariaDB Server&Cli";
            echo "----------------------------------------";

            sudo apt install php-fpm apache2 mariadb-server mariadb-client -y

            sudo a2enmod proxy_fcgi setenvif

            sudo a2enconf php7.4-fpm

            sudo systemctl restart apache2

            echo "----------------------------------------";
            echo "FIN - Installation : Apache2";
            echo "----------------------------------------";
}
InstallationPhpApach2MariaDBCliServ

ConfigApache2 () {
            echo "----------------------------------------";
            echo "Config : Apache2 (pour que apache serve phpmyadmin)";
            echo "----------------------------------------";

            default=/etc/apache2/sites-available/000-default.conf;

            sudo sed -i '29i\ ' ${default};

            sudo sed -i '29i\        Include /etc/phpmyadmin/apache.conf' ${default};

            sudo systemctl restart apache2

            echo "----------------------------------------";
            echo "Config : Apache2";
            echo "----------------------------------------";
}
ConfigApache2



ConfigurationMaraDB () {

            echo "----------------------------------------";
            echo "Configuration : MariaDB";
            echo "----------------------------------------";

            sudo mariadb -e "CREATE USER 'Victor'@'localhost' IDENTIFIED BY 'p@ssw0rd';"

            sudo mariadb -e "GRANT ALL PRIVILEGES ON *.* TO 'Victor'@'localhost' WITH GRANT OPTION;";
            sudo mariadb -e "FLUSH PRIVILEGES;";

            sudo systemctl restart mariadb

            echo "----------------------------------------";
            echo "FIN - Configuration : MariaDB";
            echo "----------------------------------------";
}
ConfigurationMaraDB


PHPMyadminXdebug () {
            echo "-------------------------------------------";
            echo "Installation XDebug"
            echo "-------------------------------------------";

            sudo apt install phpmyadmin php-xdebug -y

            echo "-------------------------------------------";
            echo "FIN - Installation XDebug"
            echo "-------------------------------------------";
}
PHPMyadminXdebug

PHPXdebugParametre () {

            echo "-------------------------------------------";
            echo "Paragmètrage XDebug"
            echo "-------------------------------------------";

            phpini=/etc/php/7.4/fpm/php.ini;


            sudo sed -i '1920i\[Xdebug]' ${phpini};
            sudo sed -i '1921i\;zend_extention = "/usr/lib/php/20210902/xdebug.so"' ${phpini};
            sudo sed -i '1922i\;xdebug.remote_enable = 1]' ${phpini};
            sudo sed -i '1923i\;xdebug.remote_handler = dbgp' ${phpini};
            sudo sed -i '1924i\;xdebug.remote_mode = req' ${phpini};
            sudo sed -i '1925i\;xdebug.remote_host = 127.0.0.1' ${phpini};
            sudo sed -i '1926i\;xdebug.remote_port = 9000' ${phpini};
            sudo sed -i '1927i\;xdebug.max_nesting_level = 300' ${phpini};
            sudo sed -i '1928i\ ' ${phpini};


            echo "-------------------------------------------";
            echo "FIN - Paragmètrage XDebug"
            echo "-------------------------------------------";

}
PHPXdebugParametre

AjoutUtilisateurdansUbuntu () {
            echo "-------------------------------------------";
            echo "Ajout utilisateur Ubuntu"
            echo "-------------------------------------------";

            sudo adduser ubuntu adm

            sudo chown root:adm  -R /var/www

            sudo chmod 2775 .




            echo "-------------------------------------------";
            echo "Ajout utilisateur Ubuntu"
            echo "-------------------------------------------";
}
AjoutUtilisateurdansUbuntu


Composer () {

            echo "-----------------------------------------";
            echo "Installation Composer":
            echo "-----------------------------------------";

            sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            sudo php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
            sudo php composer-setup.php
            sudo php -r "unlink('composer-setup.php');"

            sudo mv composer.phar /usr/local/bin/composer


            echo "-----------------------------------------";
            echo "Fin - Installation Composer":
            echo "-----------------------------------------";
}
Composer


sudo apt update && sudo apt upgrade
