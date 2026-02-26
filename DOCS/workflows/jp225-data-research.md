# JP225 — Exploiter un CSV ticks (IC Markets) pour calibrer Aurora

## Objectif

Décrire une procédure reproductible pour analyser `TICKS/JPNIDXJPY_mt5_ticks.csv` (ticks 2019→...) et produire:

- des **recommandations de sessions** (heure serveur),
- des **bornes réalistes** pour les paramètres d'exécution (spread/slippage/predictive),
- des artefacts `REPORTS/` et `PLANS/` prêts à exécuter dans MT5/Cloud.

## Sources

- CSV ticks: `TICKS/JPNIDXJPY_mt5_ticks.csv`
- EA: `MQL5/Experts/Aurora.mq5`
- Helpers exécution/spread: `MQL5/Include/Aurora/aurora_engine.mqh`
- Sessions/weekend: `MQL5/Include/Aurora/aurora_session_manager.mqh`, `MQL5/Include/Aurora/aurora_weekend_guard.mqh`
- Workflows: `DOCS/workflows/backtesting.md`

## Hypothèses temporelles (IC Markets)

- La donnée est en heure serveur broker: UTC+2 (hiver) / UTC+3 (été).
- Aucune conversion n'est appliquée par les scripts.

`TODO(verify): confirmer le mapping exact UTC+2/UTC+3 sur une date de transition DST — Comment obtenir: comparer le shift observé dans les timestamps avec la transition EU (dernier dimanche de mars/octobre) sur 1 journée.`

## Procédure

### 0) Vérifier le contrat du symbole (MT5)

Avant de calibrer `SpreadLimit`/stops, récupérer les propriétés symboles du broker dans MT5.

Script:
- `MQL5/Scripts/Aurora_SymbolInfoDump.mq5`

Champs minimum:
- `SYMBOL_POINT`
- `SYMBOL_TRADE_TICK_SIZE`
- `SYMBOL_TRADE_STOPS_LEVEL`

Champs recommandés (script enrichi):
- spread live: `SYMBOL_SPREAD`, `SYMBOL_SPREAD_FLOAT`, `SYMBOL_BID`, `SYMBOL_ASK`, `SPREAD_LIVE(points)`
- spread échantillonné (pré-opt): `SPREAD_SAMPLING_MIN/AVG/P50/P90/MAX(points)` (inputs `InpSpreadSamples`, `InpSpreadSampleMs`)
- capacités broker (proxy exécution/slippage): `SYMBOL_TRADE_EXEMODE`, `SYMBOL_FILLING_MODE`, `SYMBOL_EXPIRATION_MODE`, `SYMBOL_ORDER_MODE`
- contraintes exécution: `SYMBOL_TRADE_STOPS_LEVEL`, `SYMBOL_TRADE_FREEZE_LEVEL`, `SYMBOL_VOLUME_MIN/STEP/MAX`
- contrat/argent: `SYMBOL_TRADE_CONTRACT_SIZE`, `SYMBOL_TRADE_CALC_MODE`, `SYMBOL_CURRENCY_PROFIT` (aussi `SYMBOL_CURRENCY_BASE`, `SYMBOL_CURRENCY_MARGIN`, `SYMBOL_MARGIN_*`, `SYMBOL_SWAP_*`)
- repère slippage: `REFERENCE_SLIPPAGE(points)` / `REFERENCE_SLIPPAGE(price)` (input script), car MT5 n'expose pas de propriété broker native `SYMBOL_*` pour le slippage

Notes:
- `InpToChart=true` affiche un résumé compact directement sur le graphe.
- `InpToFile=true` écrit les mêmes couples clé/valeur dans `FILE_COMMON` (par défaut `AURORA\symbol-info.txt`).
- Unités: les champs `(...points)` du script sont des **points MT5** (`price = points * SYMBOL_POINT`). Pour JP225 (`SYMBOL_POINT=0.01`), un spread affiché de `4.00` en prix vaut `400` points MT5.

`TODO(verify): exécuter le script sur IC Markets Global pour `JP225` et reporter les valeurs dans les rapports `REPORTS/JP225_predictive_calibration.md` et `PLANS/JP225_cloud_optimization.md` — Comment obtenir: MT5 -> Navigator -> Scripts -> lancer `Aurora_SymbolInfoDump` sur un chart.`

### 1) Audit ticks (couverture, anomalies, spread global)

Commande:

```sh
python3 scripts/jp225/audit_ticks.py --in TICKS/JPNIDXJPY_mt5_ticks.csv --out REPORTS/jp225_ticks_audit.json
```

Sortie:
- `REPORTS/jp225_ticks_audit.json`

### 2) Microstructure minute-of-week (1m + 5m)

Commande:

```sh
python3 scripts/jp225/microstructure.py --in TICKS/JPNIDXJPY_mt5_ticks.csv --out-dir REPORTS/data
```

Sorties:
- `REPORTS/data/jp225_minute_of_week_1m.csv`
- `REPORTS/data/jp225_minute_of_week_5m.csv`

### 3) Recommandations sessions (candidates)

Commande:

```sh
python3 scripts/jp225/recommend_sessions.py --micro-dir REPORTS/data --out REPORTS/JP225_microstructure_sessions.md
```

Sortie:
- `REPORTS/JP225_microstructure_sessions.md`

### 3b) Stats sessionnelles (spread/jumps) (recommandé)

Commande (Session A exemple):

```sh
python3 scripts/jp225/session_stats.py --in TICKS/JPNIDXJPY_mt5_ticks.csv --start 20:00 --end 00:00 --days Mon,Tue,Wed,Thu,Fri --out REPORTS/jp225_sessionA_2000_0000_stats.json
```

Sortie:
- `REPORTS/jp225_sessionA_2000_0000_stats.json`

### 4) Barres M1 dérivées (optionnel)

Commande:

```sh
python3 scripts/jp225/build_m1_bars.py --in TICKS/JPNIDXJPY_mt5_ticks.csv --out TICKS/derived/jp225_m1_mid.csv.gz
```

Sortie:
- `TICKS/derived/jp225_m1_mid.csv.gz`

## See also

- Backtesting (MT5 + simulation): `DOCS/workflows/backtesting.md`
- Inputs exécution: `DOCS/inputs/2-1-execution.md`
- Inputs sessions: `DOCS/inputs/3-1-sessions.md`

## Last verified
Last verified: 2026-02-16 — Méthode: inspection statique + enrichissement du script `MQL5/Scripts/Aurora_SymbolInfoDump.mq5` (spread live + sampling, contrat/argent, capacités d'exécution, repère slippage, affichage chart).
