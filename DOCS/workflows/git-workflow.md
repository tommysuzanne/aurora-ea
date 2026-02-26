# Git workflow (local-first) + règles repo

## Objectif

Standardiser l’usage de Git pour :
- produire des **diffs propres** (EOL stables, pas de datasets),
- avoir un historique exploitable (Conventional Commits),
- préparer des releases reproductibles (tags + changelog auto).

## Sources

- `.gitattributes` (EOL + diff)
- `.gitignore` (datasets/artefacts)
- `.githooks/` (garde-fous locaux)
- `CONTRIBUTING.md`
- `DOCS/style-guide.md`

## Setup local (une fois)

1) Activer les hooks versionnés

```sh
git config core.hooksPath .githooks
```

2) (Optionnel) Activer `pre-commit`

TODO(verify): utiliser `pre-commit` en local — Comment obtenir: installer `pre-commit`, puis exécuter `pre-commit install` et vérifier que les hooks tournent.

## Règles “données & artefacts”

- `TICKS/` :
  - datasets ticks locaux (multi-GB) → **ne pas committer** (sauf `TICKS/README.md`).
  - voir `TICKS/README.md`.
- `REPORTS/` :
  - committer uniquement les livrables “curated” (ex: `.md`, `.json`, `.txt`),
  - `REPORTS/**/data/**` est considéré dérivé/reproductible → ignoré.

## Workflow quotidien (GitHub flow)

1) Créer une branche

```sh
git switch -c feat/<slug>
```

2) Commiter (Conventional Commits)

Exemples :
- `feat(mql5): ...`
- `fix(mql5): ...`
- `docs: ...`

3) Ouvrir une PR (GitHub)

TODO(verify): configurer les protections GitHub sur `main` — Comment obtenir: activer “Require pull request” + “Require status checks” dans les settings du repo.

## Notes (diffs/EOL)

Les fichiers MQL5 (`MQL5/**/*.mq5`, `MQL5/**/*.mqh`) sont stabilisés en CRLF côté working tree via `.gitattributes` pour éviter les diffs bruyants.

TODO(verify): GitHub Linguist / coloration MQL5 — Comment obtenir: pousser le repo sur GitHub, vérifier le rendu, puis ajuster `.gitattributes` si nécessaire.

## See also

- Release workflow : `release.md`
- Doc DoD : `../maintenance/doc-dod.md`

## Last verified
Last verified: 2026-02-25 — Méthode: vérification des fichiers `.gitattributes`, `.gitignore`, `.githooks/` et exécution locale de `python scripts/ci/check_docs_links.py`.

