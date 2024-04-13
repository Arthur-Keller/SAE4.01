# Procédure sur la sauvegarde de la base de données

## Création de la machine "save"
Pour créer la machine `save`, suivez ces étapes simples :

1. **Exécution du Script de Déploiement :**
   - Pour créer la machine virtuelle, exécutez le script `deploy.sh` en utilisant la commande suivante :
     ```bash
     login@virtu$ ./deploy.sh
     ```

2. **Attribution du Nom et de l'Adresse IP :**
   - Lorsque le script vous demande le nom de la machine à attribuer, spécifiez `save`. Sinon, la suite de l'installation ne sera pas exécutée.
   - Ensuite, entrez l'adresse IP que vous avez décidé de lui attribuer.

3. **Création de la Machine Virtuelle :**
   - Une fois les informations saisies, la machine virtuelle sera créée et configurée avec les paramètres par défaut.
   - Lorsque le script identifie le nom de machine `save`, il effectue les installations spécifiques à cette machine :
   ```bash
   scp postgres/restaurer.sh user@$STATIC_IP:~
   ssh user@$STATIC_IP "chmod u+x restaurer.sh"
   ssh user@$STATIC_IP "sudo -S apt install rsync -y"
   ```
   - Ici, il envoie le script `restaurer.sh` sur la machine `save`, il change les droits du script pour qu'il puisse être exécuté et installe `rsync` sur la machine.

4. **Utilisation des scripts :**
   - Pour utiliser les scripts, il vous suffit de vous placer dans le même répertoire que les scripts et de faire la commande :
   ```bash
   ./'nom_du_script'
   ```
   - Exemple :
   ```bash
   ./save.sh
   ```

5. **Explication du script save :**
   - Le script save se trouve sur votre machine `psql`.
   - Ce script vous permet de réaliser une sauvegarde de votre base de données et de l'envoyer sur votre machine `save`.
   - Quand vous allez lancer le script, il vous demandera l'adresse IP de votre machine `save` :
   ```bash
   printf "Quelle est l'adresse IP de votre serveur de sauvegarde ?\n"
   read save
   ```
   - Ensuite, le script va réaliser une sauvegarde et l'envoyer sur votre machine `save` :
   ```bash
   sudo su postgres -c "pg_dumpall -f /var/lib/postgresql/save.sql"
   sudo mv /var/lib/postgresql/save.sql /var/lib/postgresql/backups/save.sql
   rsync -a /var/lib/postgresql/backups user@$save:~
   ```

6. **Explication du script restaurer :**
   - Le script restaurer se trouve sur votre machine `save`.
   - Ce script vous permet de restaurer une sauvegarde sur votre base de données `psql`.
   - Quand vous allez lancer le script, il vous demandera l'adresse IP de votre machine `psql` :
   ```bash
   printf "Quelle est l'adresse IP de votre serveur postgres ?\n"
   read psql
   ```
   - Ensuite, le script va réaliser la restauration de votre sauvegarde sur votre base de données :
   ```bash
   rsync -e ssh -avz backups/save.sql user@$psql:/home/user/
   ssh user@$psql "sudo -S mv /home/user/save.sql /var/lib/postgresql/backups"
   ssh user@$psql "sudo -S su - postgres -c 'psql -f backups/save.sql'"
   ```