# Référence v3.431 (état actuel)

## Objectif

Centraliser une référence courte et maintenable de l’état actuel d’Aurora en **v3.431**.

> Note : le repo ne contient pas de dossier `BACKUPS` (supprimé) ni de versions supérieures à `3.431`. La source-of-truth est `MQL5/`.

## Sources

- EA : `MQL5/Experts/Aurora.mq5` (`AURORA_VERSION`)
- Modules runtime : `MQL5/Include/Aurora/*`
- Indicateurs internes : `MQL5/Indicators/Aurora/*`
- Docs (index) : `DOCS/index.md`

## Points clés (v3.431)

- Deux cores runtime :
  - SuperTrend (ZLSMA + Chandelier Exit)
  - Momentum (Keltner-KAMA + Smart Momentum v2 optionnel)
- Deux exécutions :
  - Reactive
  - Predictive (ordres en attente gérés)
- Exécution asynchrone + observabilité :
  - gestion des retcodes dans `OnTradeTransaction`
  - catégories de logs `InpLog_*` (voir `DOCS/inputs/4-2-logs.md`)

## Où regarder dans le code

- Entrypoint EA : `MQL5/Experts/Aurora.mq5`
- Logger : `MQL5/Include/Aurora/aurora_logger.mqh`
- Async / persistance : `MQL5/Include/Aurora/aurora_async_manager.mqh`, `MQL5/Include/Aurora/aurora_state_manager.mqh`
- Indicateurs : `MQL5/Indicators/Aurora/*`

## TODO(verify)

- TODO(verify): compiler `MQL5/Indicators/Aurora/*` puis `MQL5/Experts/Aurora.mq5` dans MetaEditor — Comment obtenir: suivre `DOCS/getting-started/install-compile.md` et vérifier zéro erreur bloquante.
- TODO(verify): figer un preset “baseline” v3.431 (core + exécution + risque) — Comment obtenir: exporter un `.set` depuis MT5 après validation locale.

## See also

- Workflows index: `index.md`
- Backtesting / simulation: `backtesting.md`
- Smart Momentum v2: `smart-momentum.md`

## Last verified
Last verified: 2026-02-25 — Méthode: suppression des références au dossier BACKUPS + alignement avec `MQL5/Experts/Aurora.mq5` (AURORA_VERSION=3.431).
