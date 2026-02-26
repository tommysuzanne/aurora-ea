# Aurora EA (MetaTrader 5 / MQL5)

> Ce dépôt public contient uniquement `DOCS/`, `MQL5/` et `README.md`.

[![Version](https://img.shields.io/badge/version-3.431-blue.svg)](https://github.com/tommysuzanne)
[![Platform](https://img.shields.io/badge/platform-MetaTrader%205-green.svg)](https://www.metatrader5.com)
[![License](https://img.shields.io/badge/license-Proprietary-lightgrey.svg)](#license)

Version code : `3.431` (source-of-truth : `MQL5/Experts/Aurora.mq5`, `AURORA_VERSION`).

Aurora est un **Expert Advisor MetaTrader 5 (MQL5)** événementiel et modulaire :
- **Cores** : SuperTrend (ZLSMA + Chandelier Exit) + Momentum (Keltner-KAMA)
- **Deux exécutions** : Reactive (Market/Limit/Stop) ou Predictive (ordres en attente gérés)
- **Pipeline de guards** : sessions, protection week-end, news (MT5 Economic Calendar), filtres de spread/régime
- **Exécution asynchrone** : `OrderSendAsync` + retries via `OnTradeTransaction` + persistance
- **Backtest plus réaliste** : couche optionnelle de simulation (latence / slippage / rejets / padding de spread)

Liens rapides :
- Documentation technique (index) : [`DOCS/index.md`](./DOCS/index.md)
- Git workflow (local-first) : [`DOCS/workflows/git-workflow.md`](./DOCS/workflows/git-workflow.md)
- Release (version + changelog auto) : [`DOCS/workflows/release.md`](./DOCS/workflows/release.md)
- Legacy monolith (complet, historique — peut diverger du code) : [`DOCS/legacy/Aurora_Documentation.md`](./DOCS/legacy/Aurora_Documentation.md)
- Entrypoint : [`MQL5/Experts/Aurora.mq5`](./MQL5/Experts/Aurora.mq5)

---

## Fonctionnalités (v3.431)

- Gestion **prédictive** des ordres en attente (offset points/ATR + seuil de mise à jour)
- Filtres de régime/stress (Hurst, VWAP, Kurtosis, Trap Candle, Spike Guard, lissage prix)
- Contrôles de risque (kill‑switch drawdown equity, limite trades/jour, limites lots, spread/slippage)
- Break‑Even (ratio/points/ATR), trailing (standard/points/ATR), option “sortie sur clôture” via stops virtuels
- Dashboard Canvas + news à venir via le **calendrier économique MT5**

## Installation (depuis les sources)

Aurora embarque des indicateurs via `#resource` (fichiers `.ex5`). Si les `.ex5` n’existent pas encore, compilez d’abord les indicateurs.

1) Copiez le dossier `MQL5/` du repo dans le répertoire de données MT5 (`Fichier → Ouvrir le dossier de données`).
2) Dans MetaEditor, compilez les indicateurs dans [`MQL5/Indicators/Aurora/`](./MQL5/Indicators/Aurora/) (création des `.ex5`).
3) Compilez l’EA : [`MQL5/Experts/Aurora.mq5`](./MQL5/Experts/Aurora.mq5).
4) Dans MT5, attachez `Aurora` à un graphique et activez **Algo Trading**.

## Configuration

La documentation technique complète (inputs + dépendances + “contrat d’inputs”) est dans [`DOCS/index.md`](./DOCS/index.md) (voir `DOCS/inputs/index.md`).

Notes :
- Les presets `.set` (si présents) peuvent cibler des versions plus anciennes ; vérifiez les inputs par rapport à la version du code (`AURORA_VERSION` dans `MQL5/Experts/Aurora.mq5`) avant usage live.
- Référence v3.431 (structure + points clés) : voir `DOCS/workflows/v3431-current.md`.
- Smart Momentum v2 : voir `DOCS/workflows/smart-momentum.md`.

## Backtest

Aurora inclut une simulation optionnelle “reality check” pour le Strategy Tester :
- `InpSim_*` permet de simuler latence, slippage, rejets, padding de spread (et commission simulée).

## JP225 (IC Markets) — Data-first research

Workflow pour exploiter `TICKS/JPNIDXJPY_mt5_ticks.csv` et produire des recommandations (sessions/exec) avant optimisation Cloud :

- Doc: [`DOCS/workflows/jp225-data-research.md`](./DOCS/workflows/jp225-data-research.md)
- Scripts: `scripts/jp225/*`
- Contrat broker MT5 (spread live+sampling, volumes, contrat/argent, filling/exécution): [`MQL5/Scripts/Aurora_SymbolInfoDump.mq5`](./MQL5/Scripts/Aurora_SymbolInfoDump.mq5)
- Outputs: `REPORTS/` et `PLANS/`

## Structure du projet

```
MQL5/
├── Experts/
│   └── Aurora.mq5
├── Include/
│   └── Aurora/
│       ├── aurora_async_manager.mqh
│       ├── aurora_constants.mqh
│       ├── aurora_dashboard.mqh
│       ├── aurora_engine.mqh
│       ├── aurora_error_utils.mqh
│       ├── aurora_guard_pipeline.mqh
│       ├── aurora_logger.mqh
│       ├── aurora_news_core.mqh
│       ├── aurora_newsfilter.mqh
│       ├── aurora_pyramiding.mqh
│       ├── aurora_session_manager.mqh
│       ├── aurora_simulation.mqh
│       ├── aurora_snapshot.mqh
│       ├── aurora_state_manager.mqh
│       ├── aurora_time.mqh
│       ├── aurora_trade_contract.mqh
│       ├── aurora_types.mqh
│       ├── aurora_virtual_stops.mqh
│       └── aurora_weekend_guard.mqh
├── Indicators/
│   └── Aurora/
│       ├── ATR_HeikenAshi.mq5
│       ├── ChandelierExit.mq5
│       ├── Heiken_Ashi.mq5
│       ├── Hurst.mq5
│       ├── Kurtosis.mq5
│       ├── TrapCandle.mq5
│       ├── VWAP.mq5
│       └── ZLSMA.mq5
├── Scripts/
│   └── Aurora_SymbolInfoDump.mq5
└── Images/
    ├── Aurora_Icon.bmp
    ├── Aurora_Icon.ico
    └── Aurora_Icon.png
```

## Avertissement

Le trading comporte des risques significatifs. Ce dépôt est fourni à des fins de test/éducation ; aucune garantie de performance.

## Licence

Propriétaire. Tous droits réservés.
