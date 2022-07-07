#!/bin/bash

# Script passage du code en test à la machine de production via rsync.

echo '-------------------------------------------------------';
echo "Connexion au serveur et création du répertoire";
echo '-------------------------------------------------------';

ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo rm -rf /var/www/CCI-SIO21-Portfolio';

ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo mkdir -p /var/www/CCI-SIO21-Portfolio';

ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo chown -R ubuntu:ubuntu /var/www/CCI-SIO21-Portfolio';

echo '-------------------------------------------------------';
echo "Droit sur /var/www distant attribués à ubuntu";
echo '-------------------------------------------------------';

rsync -azP -e 'ssh -p 1128' /var/www/Preprod/ ubuntu@ip236.ip-178-33-64.eu:/var/www/CCI-SIO21-Portfolio;

echo '-------------------------------------------------------';
echo "Fichiers/Dossiers du projet copiés et envoyés";
echo '-------------------------------------------------------';

ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo chown -R www-data:www-data /var/www/CCI-SIO21-Portfolio/storage/';
ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio/public/';
ssh ip236.ip-178-33-64.eu -l ubuntu -p 1128 -t 'sudo chown -R ubuntu:www-data /var/www/CCI-SIO21-Portfolio/bootstrap/';

echo '-------------------------------------------------------';
echo "Droit sur dossier distant attribués à www-data";
echo '-------------------------------------------------------';

echo '-------------------------------------------------------';
echo "Projet envoyé en production.";
echo '-------------------------------------------------------';
