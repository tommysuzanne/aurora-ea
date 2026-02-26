# Codex permissions & Git

## Objectif

Permettre à l’agent d’exécuter les opérations Git (ex: `git add`, `git commit`, `git tag`, `git push`) **sans sollicitations répétées**, tout en gardant un périmètre **scopé** à ce repo.

## Sources

- `AGENTS.md`
- `DOCS/style-guide.md`
- `DOCS/workflows/git-workflow.md`

## Constat (ce que le repo ne peut pas imposer)

- Les “approvals”/permissions d’exécution dans Codex sont **des réglages de l’app** (par workspace), pas un mécanisme versionnable dans ce repo.
- Certaines actions Git ont des prérequis d’environnement :
  - `git commit` / `git tag` nécessitent l’écriture dans `.git/`.
  - `git push` / `git pull` / `git fetch` nécessitent un **remote** configuré + un **accès réseau**.

## Checklist (approvals persistantes, scopées)

### 1) Écriture dans le repo (incluant `.git/`)

- Ouvrir ce repo comme workspace dans Codex.
- Vérifier que la sandbox autorise l’écriture dans le workspace, y compris `.git/`.

TODO(verify): Où se règle exactement l’accès en écriture dans Codex — Comment obtenir: ouvrir les réglages de l’app Codex et chercher “Permissions”, “Sandbox”, “Workspace write access”, puis valider que `.git/` est modifiable.

### 2) Allowlist/prefix pour commandes Git

- Configurer des approvals persistantes **scopées** via une allowlist de commandes (idéalement un prefix `git`).

TODO(verify): Comment définir une allowlist/prefix de commandes dans Codex — Comment obtenir: ouvrir les réglages “Approvals”/“Command allowlist” du workspace, puis ajouter le prefix `git` (et éventuellement `gh` si utilisé).

### 3) Réseau + remote pour `push/pull`

- Configurer un remote (ex: `origin`) puis vérifier la connectivité.

TODO(verify): Si Codex autorise les opérations réseau sortantes (GitHub/Git) — Comment obtenir: tenter `git ls-remote <url>` depuis le terminal Codex et confirmer l’absence de blocage réseau.

## Smoke test (vérif minimale)

- Vérifier l’état : `git status`
- Vérifier la capacité à committer/tagger (sur une branche jetable) :
  - `git checkout -b chore/codex-permissions-smoke`
  - Modifier un fichier non critique (ex: une doc), puis `git add -A && git commit -m "chore: smoke test codex git"`
  - (Optionnel) `git tag codex-smoke-<date>`
- Vérifier `push` (si remote + réseau) : `git push -u origin chore/codex-permissions-smoke --follow-tags`

## See also

- `DOCS/workflows/git-workflow.md`
- `DOCS/workflows/release.md`
- `CONTRIBUTING.md`

## Last verified

Last verified: 2026-02-25 — Méthode: `git status` exécuté via terminal Codex dans ce workspace.
