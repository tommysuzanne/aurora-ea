# Aurora EA (MetaTrader 5 / MQL5)

Expert Advisor MetaTrader 5 (MQL5) **événementiel** et **modulaire**.  
Event-driven, modular MetaTrader 5 (MQL5) Expert Advisor.

[![Release](https://img.shields.io/github/v/tag/tommysuzanne/aurora-ea?sort=semver)](https://github.com/tommysuzanne/aurora-ea/releases)
[![Last commit](https://img.shields.io/github/last-commit/tommysuzanne/aurora-ea/main)](https://github.com/tommysuzanne/aurora-ea/commits/main)
[![Platform](https://img.shields.io/badge/platform-MetaTrader%205-green.svg)](https://www.metatrader5.com)
[![License](https://img.shields.io/badge/license-Personal%20Use%20%2F%20Commercial-lightgrey.svg)](#licence)

Un miroir public (read-only) est publié sur `tommysuzanne/aurora-ea` au moment des tags de release `vX.YYY`
(voir [`DOCS/workflows/public-mirror.md`](./DOCS/workflows/public-mirror.md)).

## Points clés

- **Cores** : SuperTrend (ZLSMA + Chandelier Exit) + Momentum (Keltner-KAMA)
- **Deux exécutions** : Reactive (Market/Limit/Stop) ou Predictive (ordres en attente gérés)
- **Pipeline de guards** : sessions, protection week-end, news (MT5 Economic Calendar), filtres de spread/régime
- **Exécution asynchrone** : `OrderSendAsync` + retries via `OnTradeTransaction` + persistance
- **Backtest plus réaliste** : couche optionnelle de simulation (latence / slippage / rejets / padding de spread)

<details>
<summary>Table of contents</summary>

- [Quickstart](#quickstart)
- [Requirements](#requirements)
- [Documentation](#documentation)
- [Releases & Changelog](#releases--changelog)
- [Public mirror](#public-mirror)
- [Support](#support)
- [Security](#security)
- [Licence](#licence)
- [Commercial licensing](#commercial-licensing)
- [Disclaimer](#disclaimer)

</details>

## Quickstart

1) Copier le dossier [`MQL5/`](./MQL5/) dans le dossier de données MT5 (`File → Open Data Folder`).
2) Dans MetaEditor, compiler les indicateurs dans [`MQL5/Indicators/Aurora/`](./MQL5/Indicators/Aurora/) (génère les `.ex5`).
3) Compiler l’EA : [`MQL5/Experts/Aurora.mq5`](./MQL5/Experts/Aurora.mq5).
4) Dans MT5, attacher `Aurora` à un graphique et activer **Algo Trading**.

- Guide complet : [`DOCS/getting-started/install-compile.md`](./DOCS/getting-started/install-compile.md)
- Runbook live : [`DOCS/getting-started/run-live.md`](./DOCS/getting-started/run-live.md)

## Requirements

- MetaTrader 5 + MetaEditor.
- Les indicateurs embarqués sont référencés via `#resource` en `.ex5` : compilez d’abord `MQL5/Indicators/Aurora/*`.
- La version du code est la source-of-truth : `AURORA_VERSION` dans `MQL5/Experts/Aurora.mq5`.

## Documentation

Start here :

- Index doc (source-of-truth) : [`DOCS/index.md`](./DOCS/index.md)
- Inputs (liste + defaults + descriptions) : [`DOCS/inputs/index.md`](./DOCS/inputs/index.md)
- Contrat d’inputs (refus d’init) : [`DOCS/inputs/input-contract.md`](./DOCS/inputs/input-contract.md)
- Backtesting / simulation : [`DOCS/workflows/backtesting.md`](./DOCS/workflows/backtesting.md)
- Debugging / logs : [`DOCS/workflows/debugging.md`](./DOCS/workflows/debugging.md)
- Troubleshooting / FAQ : [`DOCS/troubleshooting/index.md`](./DOCS/troubleshooting/index.md)

## Releases & Changelog

- Releases (tags `vX.YYY`) : https://github.com/tommysuzanne/aurora-ea/releases
- Changelog public (concis) : [`DOCS/CHANGELOG.md`](./DOCS/CHANGELOG.md)

## Public mirror

Le dépôt `tommysuzanne/aurora-ea` est un miroir minimal (docs + sources MQL5 + fichiers meta).  
Le développement se fait ailleurs ; pas de PR externes ici.

- Détails : [`DOCS/workflows/public-mirror.md`](./DOCS/workflows/public-mirror.md)

## Support

Voir [`SUPPORT.md`](./SUPPORT.md) (Issues OK, PR externes non acceptées, checklist à fournir).

## Security

Voir [`SECURITY.md`](./SECURITY.md) (report privé).

## Licence

Ce projet est **source-visible** (code accessible), mais **pas** distribué sous une licence open source OSI.

- Gratuit pour **usage personnel** (personne physique), code visible et modifiable.
- Toute **exploitation commerciale** (entreprise, prestation, “as-a-service”, usage pour des tiers) nécessite une licence
  commerciale.

- Détails : [`LICENSE`](./LICENSE)
- Licence commerciale : [`COMMERCIAL.md`](./COMMERCIAL.md)
- FAQ licence : [`DOCS/reference/licensing.md`](./DOCS/reference/licensing.md)

## Commercial licensing

Contact : `hello@tommysuzanne.com`  
Objet recommandé : `[Aurora EA] Commercial license`

Merci d’indiquer (au minimum) : société/pays, usage envisagé, broker(s)/symboles, contraintes (SLA/reporting/audit).

## Disclaimer

Le trading comporte des risques significatifs. Ce dépôt est fourni à des fins de test/éducation ; aucune garantie de
performance. Rien ici ne constitue un conseil en investissement.
