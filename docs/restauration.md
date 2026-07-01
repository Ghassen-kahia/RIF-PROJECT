
## Piège rencontré : permissions après restauration du filestore
`docker cp` copie les fichiers en tant que root, quel que soit l'utilisateur du processus
dans le conteneur cible. Après avoir restauré `odoo-filestore`, il faut impérativement
redonner la propriété à l'utilisateur `odoo` (UID 101) avant de redémarrer Odoo :

```bash
docker exec -u root apps-odoo-1 chown -R odoo:odoo /var/lib/odoo
```

Sans cette étape, Odoo échoue avec `AssertionError: /var/lib/odoo/sessions: directory is not writable`.
