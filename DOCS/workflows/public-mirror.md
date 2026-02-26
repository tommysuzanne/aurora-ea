# Miroir public GitHub (`tommysuzanne/aurora-ea`)

## Objectif

Publier un dépôt GitHub **public** contenant uniquement :

- `DOCS/`
- `MQL5/`
- `README.md`
- `LICENSE`
- `COMMERCIAL.md`
- `SECURITY.md`
- `SUPPORT.md`
- `CONTRIBUTING.md`
- `DOCS/CHANGELOG.md`
- `.gitattributes` (template miroir)
- `.gitignore` (template miroir)

Ce dépôt public sert de distribution “read-only” : **pas de développement direct** dedans (sauf hotfix exceptionnel).

Note : la publication du miroir s’effectue depuis le **repo de développement** (celui-ci), via un script mainteneur.
Le repo public ne contient pas `scripts/`.

## Sources

- `scripts/publish_public_mirror.py`
- `scripts/public_mirror/.gitignore`
- `scripts/public_mirror/.gitattributes`
- `DOCS/workflows/release.md`

## Cadence

Le miroir public est mis à jour **au moment des releases taggées** (`vX.YYY`).

Règle : le repo public reçoit **le même tag** `vX.YYY` que la release.

Note : des mises à jour “docs/meta” peuvent être publiées sans nouveau tag (exception).

## Contact

- Commercial / support / sécurité : `hello@tommysuzanne.com`

## Procédure (mainteneur)

Pré-requis :

- accès GitHub (SSH) au repo public : `git@github.com:tommysuzanne/aurora-ea.git`
- un clone local (ou un dossier vide) pour le repo public

Dry-run (recommandé) :

```sh
python scripts/publish_public_mirror.py --public-path /path/to/aurora-ea --tag v3.432 --dry-run
```

Publication :

```sh
python scripts/publish_public_mirror.py --public-path /path/to/aurora-ea --tag v3.432
```

Via la release (intégré) :

```sh
python scripts/release.py --version 3.432 --publish-public --public-path /path/to/aurora-ea
```

## Notes

- Le miroir utilise une **allowlist** : tout fichier hors périmètre est supprimé côté repo public.
- Les artefacts MetaTrader (`*.ex5`, `*.ex4`, `*.log`) ne doivent pas être publiés.

## Last verified

Last verified: 2026-02-26 — Méthode: ajout du workflow + définition de l’allowlist miroir.
