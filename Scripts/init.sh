#!/bin/bash

InitProject () {
    echo '---------------------------------';
    echo 'Initialisation du projet en cours';
    echo '---------------------------------';

    echo 'Clean de /var/www/CCI-SIO21-Portfolio'
    sudo rm -rf /var/www/CCI-SIO21-Portfolio
    sudo mkdir /var/www/CCI-SIO21-Portfolio
    sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio

    echo 'Clone du projet dans /var/www/CCI-SIO21-Portfolio'
    git clone https://github.com/Vladimir9595/CCI-SIO21-Portfolio.git /var/www/CCI-SIO21-Portfolio


    echo 'Attribution des droits à Apache'
    sudo chown -R www-data:www-data /var/www/CCI-SIO21-Portfolio
}

InitProject