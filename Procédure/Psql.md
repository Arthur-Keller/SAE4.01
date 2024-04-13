# Procédure sur la création de la machine virtuelle PSQL et sa configuration

## Création de la machine psql
Pour créer la machine `psql`, suivez ces étapes simples :

1. **Exécution du Script de Déploiement :**
   - Pour créer la machine virtuelle, exécutez le script `deploy.sh` en utilisant la commande suivante :
     ```bash
     login@virtu$ ./deploy.sh
     ```

2. **Attribution du Nom et de l'Adresse IP :**
   - Lorsque le script vous demande le nom de la machine à attribuer, spécifiez `psql`. Sinon, la suite de l'installation ne sera pas exécutée.
   - Ensuite, entrez l'adresse IP que vous avez décidé de lui attribuer.

3. **Création de la Machine Virtuelle :**
   - Une fois les informations saisies, la machine virtuelle sera créée et configurée avec les paramètres par défaut.

4. **Installation de PostgreSQL :**
   - Lorsque le script identifie `psql`, il passe à l'installation et à la configuration de PostgreSQL.
   - Vous serez invité à fournir l'adresse IP attribuée ou à attribuer à `odoo`.

   ```bash
   printf "Pour une bonne installation, nous vous demandons l'adresse IP que vous allez ou que vous avez attibué pour la machine 'odoo'.\nEntré l'adresse juste ici:"
   read IP_ODOO
   ```

5. **Configuration de PostgreSQL :**
   - PostgreSQL sera installé avec succès.
   - Un utilisateur nommé `admin` sera ajouté avec le mot de passe `admin` et les privilèges de superutilisateur.
   - Une base de données nommée `admin`, dont `admin` est le propriétaire, sera créée.
   ```bash
   sudo -S apt install postgresql -y
   sudo -S apt install rsync -y

   sudo -S mkdir -p /var/lib/postgresql/backups
   systemctl enable postgresql
   systemctl start postgresql

   sudo -S -i -u postgres psql -c "create user admin with password 'admin' superuser"
   sudo -S -i -u postgres createdb --encoding=UTF8 --locale=C --template=template0 --owner=admin admin
   ```

6. **Configuration de pg_hba.conf :**
   - Le fichier `pg_hba.conf` sera édité pour autoriser l'accès de la machine `odoo` à PostgreSQL.
   ```bash
   sudo -S sed -i -e "/host    all             all             127.0.0.1\/32            scram-sha-256/a host\tall\t\tall\t\t$IP_ODOO\/32\t\ttrust" /etc/postgresql/15/main/pg_hba.conf

   sudo -S sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/15/main/postgresql.conf
   ```

7. **Modification des Privilèges :**
   - Les privilèges de l'utilisateur `admin` seront modifiés pour lui permettre de créer des bases de données et des rôles.
   ```bash
   sudo -S -i -u postgres psql -c "alter user admin with createdb createrole;"
   ```

8. **Redémarrage de PostgreSQL :**
   - Enfin, PostgreSQL sera redémarré pour appliquer les modifications.
   ```bash
   sudo -S systemctl restart postgresql
   ```

Une fois ces étapes terminées, l'installation et la configuration de PostgreSQL pour la machine virtuelle `psql` seront terminées.