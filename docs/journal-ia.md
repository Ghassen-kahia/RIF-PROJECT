# Journal IA — Test de sélection DevOps RIF SAS

## Prompt 1 — Rédaction du docker-compose.yml (Tâche 1.1)
**Contexte** : besoin d'une stack Odoo + Postgres avec Postgres isolé du réseau hôte et secrets externalisés.
**Ce que l'IA a généré** : docker-compose.yml avec 2 services, réseau dédié, volumes nommés, healthcheck sur Postgres.
**Ce que j'ai vérifié/modifié** : confirmé qu'aucun `ports:` n'était présent sur le service `db` (isolation), testé le démarrage avec `docker compose ps`.
**Ce que j'ai appris** : `depends_on: condition: service_healthy` évite qu'Odoo démarre avant que Postgres soit prêt.

## Prompt 2 — Validation persistance (Tâche 1.2)
**Contexte** : vérifier que les volumes nommés survivent à un `docker compose down` sans `-v`.
**Ce que j'ai fait** : installé le module Ventes, créé une commande, redémarré la stack, confirmé que la donnée était toujours là.
**Ce que j'ai appris** : `down` seul supprime containers et réseau mais jamais les volumes ; seul `-v` les détruit.

## Prompt 3 — Reverse proxy Nginx (Tâche 1.3)
**Contexte** : exposer Odoo via erp.local en passant par un service nginx plutôt que directement sur le port 8069.
**Ce que l'IA a généré** : config nginx avec proxy_pass vers odoo:8069, headers X-Forwarded-* pour éviter les liens cassés, et un bloc websocket séparé.
**Ce que j'ai appris** : sans les headers X-Forwarded-Proto/Host, Odoo peut générer des redirections incorrectes car il ignore qu'il est derrière un proxy.

## Prompt 4 — Script de sauvegarde (Tâche 2.1)
**Contexte** : automatiser un backup complet (dump SQL + filestore) sans arrêter les conteneurs.
**Ce que l'IA a généré** : script bash avec pg_dump via docker exec, copie du filestore via docker cp, archive tar.gz horodatée, logging dans un fichier.
**Ce que j'ai vérifié** : que le nom de la base dans DB_NAME correspondait bien à la base réellement utilisée par Odoo (odoo), pas une hypothèse de nommage.

## Prompt 5 — Debug restauration filestore (Tâche 2.2)
**Contexte** : après restauration du filestore via docker cp, Odoo plantait avec une erreur de permissions sur /var/lib/odoo/sessions.
**Diagnostic** : docker cp copie les fichiers en tant que root, écrasant la propriété attendue par le processus Odoo (UID 101).
**Ce que j'ai appris** : toujours vérifier/corriger les permissions après une restauration de volume via docker cp, avant de redémarrer le service qui dépend de ce volume.
