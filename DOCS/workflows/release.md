# Release (version + changelog + tag + GitHub Release)

## Objectif

Sortir une version `vX.YYY` (ex: `v3.432`) de façon reproductible :
- bump de `AURORA_VERSION`,
- mise à jour `README.md`,
- génération `CHANGELOG.md` (git-cliff),
- commit + tag,
- (optionnel) push + GitHub Release,
- backup (miroir + bundle).

## Sources

- Version source-of-truth : `MQL5/Experts/Aurora.mq5` (`AURORA_VERSION`)
- Release helper : `scripts/release.py`
- Changelog : `cliff.toml`, `CHANGELOG.md`
- Conventions : `CONTRIBUTING.md`

## Pré-requis

TODO(verify): installer `git-cliff` — Comment obtenir: installer `git-cliff` (ex: Homebrew/cargo) puis exécuter `git-cliff --version`.

## Procédure (local)

1) Vérifier un working tree clean

```sh
git status --porcelain
```

2) Lancer la release (sans push)

```sh
python scripts/release.py --version 3.432
```

3) (Optionnel) Push (si `origin` configuré)

```sh
python scripts/release.py --version 3.432 --push
```

## GitHub Release (CI)

Le workflow `.github/workflows/release.yml` crée une GitHub Release quand un tag `v*` est poussé.

TODO(verify): remplacer `generate_release_notes` par des notes générées via `git-cliff` — Comment obtenir: installer `git-cliff` dans le job et générer un fichier `RELEASE_NOTES.md` pour le tag courant.

## Backups

### Miroir local bare (recommandé hors iCloud)

TODO(verify): choisir un chemin de backup hors iCloud — Comment obtenir: créer un dossier de backup (disque externe recommandé) et y stocker un repo bare.

Exemple :

```sh
git clone --mirror . /path/to/backups/AURORA.git
git remote add backup /path/to/backups/AURORA.git
git push backup --mirror
```

### Bundle “air-gapped”

```sh
git bundle create AURORA-YYYYMMDD.bundle --all
```

## See also

- Git workflow : `git-workflow.md`

## Last verified
Last verified: 2026-02-25 — Méthode: revue de `scripts/release.py` + vérification des liens locaux via `python scripts/ci/check_docs_links.py`.

