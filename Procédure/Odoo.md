# Procédure sur l'installation d'ODOO et sa configuration

## Information sur le Compte par Défaut d'Odoo
Lors de l'installation d'Odoo, un utilisateur nommé **admin** est automatiquement créé avec le mot de passe **admin**.
```yaml
Utilisateur : admin
Mot de pase : admin
```

Pour créer de nouveaux utilisateurs, veuillez vous référer à la procédure suivante : [Procédure sur la Création de Nouveaux Utilisateurs](./Nouvel-utilisateur.md).

## Installation d'odoo

1. **Exécution du Script d'Installation :**
    - Lorsque le script détecte que le nom de la machine est `odoo`, il procède automatiquement à l'installation et à la configuration d'Odoo.
    ```bash
    login@virtu$ ./deploy.sh
    ```

2. **Exécution du Script de Configuration :**
    - Le script d'installation d'Odoo `odoo.sh` sera exécuté automatiquement sur la machine virtuelle.
    - Ce script installera Docker et Docker Compose, créera un réseau Docker nommé web-odoo, et lancera Odoo en utilisant le fichier docker-compose.yml.
    ```bash
    sudo -S apt-get install -y docker docker-compose
    sleep 2
    sudo -S docker network create web-odoo
    sleep 2
    cd odoo
    sudo -S docker-compose up -d
    ```

3. **Configuration de Traefik pour Odoo :**
    - La configuration de Traefik pour rediriger le trafic vers Odoo sera également prise en charge automatiquement.
    ```yaml
    labels:
      - traefik.http.routers.odoo_test.rule=Host(`odoo.localhost`)
      - traefik.port=80
    ```
    Pour plus de detail rergarder la fichier [docker-compose.yml](../Scprit/odoo/docker-compose.yml)

4. **Configuration d'Odoo :**
    - Un script de configuration `config-odoo.sh` sera exécuté automatiquement pour créer le fichier de configuration avec les paramètres nécessaires, y compris l'adresse IP de la machine où se trouve PostgreSQL.
    ```bash
    printf "Quelle est l'adresse de la machine où se trouve postgres ?"
    read IP_PSQL

    printf "[options]\n\naddons_path = /mnt/extra-addons\ndata_dir = /var/lib/odoo\nlogfile = /var/log/odoo/odoo-server.log\n\nadmin_passwd = admin\ndb_host = $IP_PSQL\ndb_port = 5432\ndb_user = admin\ndb_password = admin\ndb_maxconn = 64\ndb_name = admin\nwithout_demo = true" > odoo/config/odoo.conf
    ```

5. **Démarrage d'Odoo :**
    - Une fois l'installation et la configuration terminées, Odoo sera prêt à être utilisé.
    - Vous pourrez accéder à Odoo via votre navigateur en utilisant l'adresse IP de la machine virtuelle et le port 8069
    >exemple : odoo.localhost:8069

Avec cette procédure, l'installation et la configuration d'Odoo seront effectuées dès que le programme reconnaîtra le nom de la machine comme étant "odoo".