#!/bin/bash

# Mettre le projet de Git dans la mchine de test et donner les droits à Apache

echo 'Clean de /var/www/CCI-SIO21-Portfolio';

sudo rm -rf /var/www/CCI-SIO21-Portfolio;
sudo mkdir /var/www/CCI-SIO21-Portfolio;

sudo chown -R ubuntu:ubuntu /var/www/CCI-SIO21-Portfolio;

echo 'Clone du projet dans /var/www/CCI-SIO21-Portfolio';

cd /var/www/CCI-SIO21-Portfolio;

git clone https://github.com/Vladimir9595/CCI-SIO21-Portfolio.git /var/www/CCI-SIO21-Portfolio;

sudo chown -R ubuntu:ubuntu /var/www/CCI-SIO21-Portfolio;

echo '------------------------------';
echo 'Mise à jour du projet en cours';
echo '------------------------------';

cd /var/www/CCI-SIO21-Portfolio;

echo 'Recherche des dernières modification sur Github';

git pull

echo 'Attribution des droits à Apache';
sudo chown -R www-data:www-data /var/www/CCI-SIO21-Portfolio;
sudo chown -R ubuntu:ubuntu /var/www/CCI-SIO21-Portfolio/.git;


echo 'Préparation des fichiers à transférer en production';

sudo rm -rf /var/www/Preprod;
sudo mkdir /var/www/Preprod;

sudo cp -R /var/www/CCI-SIO21-Portfolio/* /var/www/Preprod/;

sudo chown -R ubuntu:ubuntu /var/www/Preprod;

cd /var/www/Preprod;

sudo rm 'Charte graphique.md';