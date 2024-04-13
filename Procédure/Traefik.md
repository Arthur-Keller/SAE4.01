# Procédure d'Installation et Configuration de Traefik

## Informations sur l'Environnement
**Traefik** est installé sur la machine où se trouve **odoo** avec Docker déjà configuré.

## Installation de Traefik

1. **Exécution du Script d'Installation :**
    - Lorsque le script détecte que le nom de la machine est `odoo`, il lance automatiquement l'installation et la configuration de Traefik.
    ```bash
    login@virtu$ ./deploy.sh
    ```
2. **Exécution du Script de Configuration :**
    - Le script d'installation de Traefik `traefik.sh` sera exécuté automatiquement sur la machine virtuelle.
    - Ce script utilise le fichier [docker-compose.yml](../Scprit/traefik/docker-compose.yml) pour lancer Traefik..
    ```bash
    cd traefik

    sudo -S docker-compose up -d
    ```

3. **Configuration de Traefik**
    - La configuration de Traefik se fait principalement via Docker Compose.
    - Traefik est configuré pour écouter sur les ports 80 et 8080.
    - Les fichiers [traefik.toml](../Scprit/traefik/traefik.toml) et [traefik_dynamic.toml](../Scprit/traefik/traefik_dynamic.toml) sont utilisés pour sa configuration.
    ```yaml
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /home/user/traefik/traefik.toml:/traefik.toml
      - /home/user/traefik/traefik_dynamic.toml:/traefik_dynamic.toml
    ```

4. **Configuration Dynamique de Traefik**
    - Le fichier [traefik_dynamic.toml](../Scprit/traefik/traefik_dynamic.toml) contient une configuration dynamique pour Traefik.
    - Il définit un routeur pour l'API Traefik accessible via l'adresse `monitor.localhost`.
    ```toml
    [http.routers.api]
        ruel = "Host(`monitor.localhost`)"
        entrypoints = ["web-odoo"]
        services = "api@internal"
    ```

5. **Configuration Statique de Traefik**
    - Le fichier [traefik.toml](../Scprit/traefik/traefik.toml) contient une configuration statique pour Traefik.
    - Il définit l'entrée pour le point d'accès web-odoo sur le port 80.
    ```toml
    [entryPoints]
        [entryPoints.web-odoo]
                address = ":80"

    [api]
        dashboard = true
        insecure = true

    [providers.docker]
        watch = true
        network = "web-odoo"

    [providers.file]
        filename = "traefik_dynamic.toml"
    ```

6. **Démarrage d'Odoo :**
    -  Une fois l'installation et la configuration terminées, Traefik est prêt à être utilisé.
    - Vous pouvez accéder à l'interface de Traefik via votre navigateur en utilisant l'adresse de votre machine et le port 8080.
    >[localhost:8080](localhost:8080)

Cette procédure détaille l'installation et la configuration de base de Traefik, vous permettant ainsi de gérer efficacement les services web.