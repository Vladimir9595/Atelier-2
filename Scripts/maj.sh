#!/bin/bash

# Mettre le projet de Git dans la mchine de test et donner les droits à Apache

echo '-------------------------------------------------------';
echo 'Droit à ubuntu sur /var/www/CCI-SIO21-Portfolio';
echo '-------------------------------------------------------';

sudo chown -R ubuntu:ubuntu /var/www/CCI-SIO21-Portfolio;

echo '-------------------------------------------------------';
echo 'Recherche des dernières modification sur Github';
echo '-------------------------------------------------------';

cd /var/www/CCI-SIO21-Portfolio;

git pull;

cp .env_my_project .env;

echo '-------------------------------------------------------';
echo 'Changer les paramètres pour le fichier .env';
echo '-------------------------------------------------------';

change=/var/www/CCI-SIO21-Portfolio/.env;

sed -i '14i\DB_DATABASE=(nom de ma BDD)' ${change};
sed -i '15i\DB_USERNAME=(nom de mon utilisateur)' ${change};
sed -i '16i\DB_PASSWORD=(mon mot de passe)' ${change};

composer update --no-dev;
composer install;
composer fund;
npm install;
php artisan key:generate;

echo '-------------------------------------------------------';
echo 'Mise à jour du projet en cours';
echo '-------------------------------------------------------';

echo '-------------------------------------------------------';
echo 'Attribution des droits à Apache sur les dossiers Laravel';
echo '-------------------------------------------------------';

sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio/storage/;
sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio/public/;
sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio/bootstrap/;


echo '-------------------------------------------------------';
echo 'Préparation des fichiers à transférer en production';
echo '-------------------------------------------------------';

sudo rm -rf /var/www/Preprod/;
sudo mkdir /var/www/Preprod/;
sudo chown -R ubuntu:ubuntu /var/www/Preprod/;
cp -r /var/www/CCI-SIO21-Portfolio/* /var/www/Preprod/;
cp -r /var/www/CCI-SIO21-Portfolio/.env /var/www/Preprod/;
cp -r /var/www/CCI-SIO21-Portfolio/.styleci.yml /var/www/Preprod/;
rm -f /var/www/Preprod/README.md;

echo '-------------------------------------------------------';
echo 'Bonne attribution des droits';
echo '-------------------------------------------------------';

sudo chown -R www-data:www-data /var/www/Preprod/storage/;
sudo chown -R ubuntu:www-data /var/www/Preprod/public/;
sudo chown -R ubuntu:www-data /var/www/Preprod/bootstrap/;
