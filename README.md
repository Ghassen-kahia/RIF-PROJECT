# Test de sélection DevOps — RIF SAS

Stack Odoo 17 + PostgreSQL 15 conteneurisée avec Docker Compose, exposée via un reverse
proxy Nginx, avec script de sauvegarde automatisé et procédure de restauration testée.

## Prérequis

| Élément | Minimum |
|---|---|
| OS | Ubuntu 20.04+ ou WSL2 |
| Docker Engine | v24+ |
| Docker Compose | v2+ |
| Git | v2+ |
| RAM disponible | 4 Go |
| Disque libre | 5 Go |

## Démarrage (5 commandes)

```bash
git clone https://github.com/Ghassen-kahia/RIF-PROJECT.git
cd RIF-PROJECT/apps
cp .env.example .env    # puis éditer .env avec un vrai mot de passe
echo "127.0.0.1 erp.local" | sudo tee -a /etc/hosts
docker compose up -d
```

Odoo est accessible sur :
- `http://localhost:8069` (accès direct)
- `http://erp.local` (via le reverse proxy Nginx)

## Architecture

- **db** : PostgreSQL 15, isolé sur le réseau interne `odoo-net`, aucun port publié sur l'hôte.
- **odoo** : Odoo 17, exposé sur le port 8069.
- **nginx** : reverse proxy exposant Odoo sur le port 80 via `erp.local` (config dans `apps/nginx/odoo.conf`).

Les données persistent dans deux volumes Docker nommés : `postgres-data` et `odoo-filestore`.

## Sauvegarde

Le script `apps/backup.sh` réalise, sans arrêter les conteneurs :
1. Un `pg_dump` de la base Odoo.
2. Une archive du filestore Odoo.
3. Une archive `.tar.gz` horodatée dans `/backup/`, journalisée dans `/var/log/backup.log`.

Exécution manuelle :
```bash
cd apps
./backup.sh
```

Une entrée cron exécute le backup chaque nuit à 02h00 :
0 2 * * * /chemin/vers/apps/backup.sh

## Restauration

Procédure complète, testée avec un scénario de perte totale (conteneurs + volumes) :
voir [`docs/restauration.md`](docs/restauration.md).

Résumé rapide :
```bash
tar -xzf /backup/backup_YYYYMMDD_HHMMSS.tar.gz -C /tmp/restore
docker compose up -d
cat /tmp/restore/db_dump.sql | docker exec -i apps-db-1 psql -U odoo -d odoo
docker cp /tmp/restore/odoo-filestore/. apps-odoo-1:/var/lib/odoo/
docker exec -u root apps-odoo-1 chown -R odoo:odoo /var/lib/odoo
docker compose restart odoo
```

## Structure du dépôt
apps/
├── docker-compose.yml   # Stack complète (db, odoo, nginx)
├── .env.example          # Variables attendues (le vrai .env n'est jamais commité)
├── backup.sh              # Script de sauvegarde
└── nginx/
└── odoo.conf          # Config reverse proxy
docs/
├── restauration.md        # Runbook de restauration
├── journal-ia.md          # Journal d'utilisation de l'IA
└── screenshots/           # Preuves visuelles des différentes étapes

## Notes

- Le mot de passe PostgreSQL est généré aléatoirement lors de l'installation (`openssl rand -base64 24`), jamais commité.
- Voir [`docs/journal-ia.md`](docs/journal-ia.md) pour le détail des prompts IA utilisés durant ce test.

