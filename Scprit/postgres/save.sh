#!/bin/bash

printf"Quelle est l'adresse ip de votre machine de sauvegarde ?\n"
read save

sudo su postgres -c "pg_dumpall -f /var/lib/postgresql/save.sql"
sudo mv /var/lib/postgresql/save.sql /var/lib/postgresql/backups/save.sql
rsync -a /var/lib/postgresql/backups user@$save:~
