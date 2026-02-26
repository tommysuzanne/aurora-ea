# Indicateurs internes (MQL5/Indicators/Aurora)

## Objectif

Documenter quels indicateurs sont utilisés, comment ils sont chargés (`iCustom`) et quels buffers sont lus.

## Source-of-truth

- Handles et `CopyBuffer` : `MQL5/Experts/Aurora.mq5`
- Code indicateurs : `MQL5/Indicators/Aurora/*`

## Table (rôle principal)

Aurora utilise des indicateurs internes via `iCustom` + `CopyBuffer`, notamment :
- `Heiken_Ashi` : série lissée (possible source de signal)
- `ZLSMA` : filtre tendance “zero-lag”
- `ChandelierExit` : contexte tendance / stops dynamiques (ATR)
- `Hurst` : filtre structure (trend vs noise)
- `VWAP` : déviation vs VWAP
- `Kurtosis` : détection d’extrêmes (“fat tails”)
- `TrapCandle` : filtre anti “trap / stop-hunt”

## Paramétrage exact (iCustom / buffers)

Référence : initialisation des handles dans `MQL5/Experts/Aurora.mq5` (section “STRATEGY INITIALIZATION”) et lectures via `CopyBuffer`.

- `Heiken_Ashi` (`MQL5/Indicators/Aurora/Heiken_Ashi.mq5`)
  - Appel : `iCustom(NULL, 0, I_HA)`
  - Buffers lus : `HA_C` (buffer index 3 dans l’EA)
- `ChandelierExit` (`MQL5/Indicators/Aurora/ChandelierExit.mq5`)
  - Appel : `iCustom(NULL, 0, I_CE, CeAtrPeriod, CeAtrMult, InpLog_IndicatorInternal)`
  - Buffers lus : buy context (buffer 0) / sell context (buffer 1)
- `ZLSMA` (`MQL5/Indicators/Aurora/ZLSMA.mq5`)
  - Appel : `iCustom(NULL, 0, I_ZL, ZlPeriod, true)`
  - Buffer lu : buffer 0
- `Hurst` (`MQL5/Indicators/Aurora/Hurst.mq5`)
  - Appel : `iCustom(_Symbol, InpHurst_Timeframe, I_HURST, InpHurst_Window, InpHurst_Smoothing, InpHurst_Threshold)`
  - Buffer lu : buffer 0 (index 1 = bougie confirmée)
- `VWAP` (`MQL5/Indicators/Aurora/VWAP.mq5`)
  - Appel : `iCustom(_Symbol, PERIOD_CURRENT, I_VWAP, InpVWAP_DevLimit)`
  - Buffers lus : upper (buffer 1), lower (buffer 2)
- `Kurtosis` (`MQL5/Indicators/Aurora/Kurtosis.mq5`)
  - Appel : `iCustom(_Symbol, PERIOD_CURRENT, I_KURTOSIS, InpKurtosis_Period, InpKurtosis_Threshold, InpLog_IndicatorInternal)`
  - Buffer lu : buffer 0 (index 1 = bougie confirmée)
- `TrapCandle` (`MQL5/Indicators/Aurora/TrapCandle.mq5`)
  - Appel : `iCustom(_Symbol, PERIOD_CURRENT, I_TRAP, InpTrap_WickRatio, InpTrap_MinBodyPts, 0.4, true, 3)`
  - Buffer lu : buffer 2 (signal)
  - Note : certains paramètres sont codés en dur côté EA (cf. doc legacy).

## See also

- Ressources embarquées : `resources.md`
