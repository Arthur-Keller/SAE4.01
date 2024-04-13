# Procédure sur l'utilisation et l'explication du script de nouvel utilisateur

## Information sur ce script
Malheureusement, ce script ne fonctionne pas complètement. Nous avons rencontré un problème lors du déploiement des instances Odoo, surtout avec les volumes de configuration. Actuellement, il utilise uniquement le fichier de configuration de l'utilisateur *admin*. Nous avons essayé de modifier les chemins dans le `docker-compose.yml`, mais cela n'a pas résolu notre problème. Donc, la création de l'utilisateur ne se fait pas correctement.

## L'utilisation du script
1. **Exécution du Script de Création d'Utilisateur :**
    - Exécutez le script et suivez les instructions pour fournir les informations nécessaires.
    ```bash
    # Première option
    login@virtu$ new-user/new-user.sh

    # Deuxième option
    login@virtu$ cd new-user
    login@virtu$ ./new-user.sh
    ```

2. **Fournir les Informations Requises :**
    - Le script demandera l'adresse IP du serveur PostgreSQL, l'adresse IP du serveur Odoo, le nom d'utilisateur souhaité et le port à utiliser.
    - Le nom d'utilisateur que vous attribuez sera aussi le mot de passe pour sa base de données PostgreSQL et Odoo.
    ```bash
    printf "Quelle est l'adresse IP de votre serveur POSTGRES ?\n"
    read IP_PSQL

    printf "Quelle est l'adresse IP de votre serveur ODOO ?\n"
    read IP_ODOO

    printf "Quel est le nom d'utilisateur que vous souhaitez ?\n"
    read USER_NAME

    printf "Quel est le port que vous souhaitez utiliser ?\n"
    read PORT
    ```

3. **Création du Nouvel Utilisateur :**
    - Le script créera un répertoire pour le nouvel utilisateur et y copiera les fichiers de configuration nécessaires.
    - Il générera également un fichier SQL pour créer l'utilisateur et la base de données associée.
    - Ce fichier SQL sera envoyé au serveur PostgreSQL.
    ```bash
    mkdir user-$USER_NAME
    cp -r config user-$USER_NAME
    cp docker-compose.yml user-$USER_NAME

    printf "CREATE USER $USER_NAME WITH PASSWORD '$USER_NAME';\nCREATE DATABASE odoo_$USER_NAME WITH OWNER=$USER_NAME;\nGRANT ALL PRIVILEGES ON DATABASE odoo_$USER_NAME TO $USER_NAME;\n" > user-$USER_NAME/new-$USER_NAME.sql
    ```

4. **Configuration de Docker Compose pour Odoo :**
    - Le script mettra à jour le fichier `docker-compose.yml` du nouvel utilisateur avec le nom d'utilisateur et le port fournis.
    - Il ajustera également le fichier de configuration d'Odoo `odoo.conf` avec le nom d'utilisateur et l'adresse IP du serveur PostgreSQL.
    ```bash
    sed -i -e "s/NAME/$USER_NAME/g" -e "s/PORT/$PORT/g" user-$USER_NAME/docker-compose.yml
    sed -i -e "s/NAME/$USER_NAME/g" -e "s/IP_PSQL/$IP_PSQL/g" user-$USER_NAME/config/odoo.conf
    ```

5. **Transfert des Fichiers au Serveur Odoo et PostgreSQL:**
    - Le répertoire du nouvel utilisateur, ainsi que ses fichiers de configuration, seront transférés vers le serveur Odoo.
    - Le fichier SQL sera transféré vers la machine où se trouve PostgreSQL.
    ```bash
    scp user-$USER_NAME/new-$USER_NAME.sql user@$IP_PSQL:/tmp

    ssh user@$IP_ODOO "mkdir user-$USER_NAME"
    scp user-$USER_NAME/docker-compose.yml user@$IP_ODOO:~/user-$USER_NAME
    scp -r user-$USER_NAME/config user@$IP_ODOO:~/user-$USER_NAME
    ```

6. **Démarrage d'Odoo pour le Nouvel Utilisateur :**
    - Le script de création de base de données `create-user.sh` sera envoyé et exécuté sur la machine PostgreSQL pour le nouvel utilisateur.
    - Le script de démarrage d'Odoo `start-odoo.sh` sera envoyé et exécuté sur le serveur Odoo pour le nouvel utilisateur.
    - Ce script démarrera Odoo en utilisant les paramètres spécifiés.
    ```bash
    scp create-user.sh user@$IP_PSQL:~
    ssh user@$IP_PSQL "chmod u+x create-user.sh"
    ssh user@$IP_PSQL "./create-user.sh $USER_NAME"

    scp start-odoo.sh user@$IP_ODOO:user-$USER_NAME
    ssh user@$IP_ODOO "chmod u+x user-$USER_NAME/start-odoo.sh"
    ssh user@$IP_ODOO "./user-$USER_NAME/start-odoo.sh $USER_NAME"
    ```

Cette procédure vous guidera à travers le processus de création d'un nouvel utilisateur pour Odoo, en configurant automatiquement les paramètres nécessaires et en démarrant le service Odoo.