# Journal IA — Test de sélection DevOps RIF SAS

## Prompt 1 — Rédaction du docker-compose.yml (Tâche 1.1)
**Contexte** : besoin d'une stack Odoo + Postgres avec Postgres isolé du réseau hôte et secrets externalisés.
**Ce que l'IA a généré** : docker-compose.yml avec 2 services, réseau dédié, volumes nommés, healthcheck sur Postgres.
**Ce que j'ai vérifié/modifié** : confirmé qu'aucun `ports:` n'était présent sur le service `db` (isolation), testé le démarrage avec `docker compose ps`.
**Ce que j'ai appris** : `depends_on: condition: service_healthy` évite qu'Odoo démarre avant que Postgres soit prêt.
