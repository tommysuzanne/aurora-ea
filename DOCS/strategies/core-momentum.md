# Core — Momentum (Keltner-KAMA + Smart Momentum v2)

## Objectif

Décrire le core **Momentum** d’Aurora (v3.431) : indicateur KAMA + bandes type Keltner, avec option **Smart Momentum v2** (multiplicateur dynamique + gates).

## Sources

- EA (wiring + logique core) : `MQL5/Experts/Aurora.mq5`
- Indicateur (buffers KAMA/bandes/ER) : `MQL5/Indicators/Aurora/AuKeltnerKama.mq5`
- Inputs (référence) : `DOCS/inputs/index.md`
- Smart Momentum v2 (workflow) : `DOCS/workflows/smart-momentum.md`

## Vue d’ensemble

Le core Momentum utilise l’indicateur `AuKeltnerKama` pour obtenir :
- une ligne centrale (KAMA),
- un ATR (période `InpKeltner_AtrPeriod`),
- un Efficiency Ratio (ER),
- et des bandes “structurelles” (upper/lower).

Le signal est un breakout de bande :
- BUY si `Close[1] > upper[1]`
- SELL si `Close[1] < lower[1]`

Un filtre ER bloque les entrées si l’ER est trop faible (vibration/chop).

## Smart Momentum v2 (optionnel)

Quand `InpSmartMom_Enable=true`, le multiplicateur de bande devient dynamique :
- Calcul VR (volatility ratio) via deux ATR (`InpSmartMom_Vol_Short` / `InpSmartMom_Vol_Long`)
- Smoothing VR (EMA) + deadband sur le multiplicateur
- Mapping selon `InpSmartMom_Model` :
  - `LINEAR_LEGACY`
  - `SIGMOID_VR`
  - `PIECEWISE_REGIME`

En plus, des gates peuvent bloquer des entrées :
- gate VR “dans le régime”
- confirmation breakout (Reactive)
- cooldown de ré-entrée
- distance minimale de breakout
- ER floor dynamique (optionnel)

## Exécution (Reactive / Predictive)

Le core Momentum est compatible avec :
- **Reactive** : décision à la clôture de bougie, puis ordre (selon `InpEntry_Mode`).
- **Predictive** : pose d’ordres STOP sur les bandes pré-calculées, avec contrôles de cohérence (prix/SL/volume) et gates Smart Momentum.

## Logs

Les logs Smart Momentum sont routés via `InpLog_Diagnostic` (préfixe `[SMARTMOM]`).

## See also

- Inputs execution : `DOCS/inputs/2-1-execution.md`
- Inputs logs : `DOCS/inputs/4-2-logs.md`
- Workflow backtesting : `DOCS/workflows/backtesting.md`

## Last verified
Last verified: 2026-02-25 — Méthode: inspection statique de `MQL5/Experts/Aurora.mq5` (AURORA_VERSION=3.431) + vérification des chemins vers `MQL5/Indicators/Aurora/AuKeltnerKama.mq5`.
