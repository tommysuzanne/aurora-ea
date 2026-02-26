# JP225 (IC Markets) — Référence calibration

## Objectif

Fournir une référence stable (unités, sessions, baseline inputs) pour backtester Aurora v3.431 sur `JP225` (IC Markets).

## Sources

- Specs broker: `REPORTS/symbol-info.txt`, `REPORTS/profit-margin-probe.txt`
- Calibration ticks IC: `REPORTS/ICM_JP225_calibration.md`
- EA: `MQL5/Experts/Aurora.mq5`

## Unités

- IC `JP225`: `SYMBOL_POINT=0.01` (`REPORTS/symbol-info.txt`)
- Conversion: `points_mt5 = price / 0.01`

## Sessions recommandées (server time)

- Optimisation (baseline): `03:00–07:00` (spread typique `2.0` index points)
- Robustesse: `19:55–23:55` (spread typique `4.0` index points)

Source: `REPORTS/ICM_JP225_microstructure_sessions.md` + `REPORTS/ICM_JP225_calibration.md`.

## Baseline inputs (exemple)

Ces valeurs sont un point de départ (pas un “golden set”).

- Sessions: `InpSess_EnableTime=true`, `03:00–07:00`, `InpSess_CloseMode=SESS_MODE_FORCE_CLOSE`
- Coûts: `SpreadLimit=300`, `Slippage=100` (`TODO(verify)`), `SignalMaxGapPts=800`
- Risk: `RiskMode=RISK_FIXED_VOL`, `Risk=100`, `InpMaxLotSize=250`, `InpMaxTotalLots=250`
- Predictive: `OFFSET_MODE_POINTS`, `InpPredictive_Offset=200`, `InpPredictive_Update_Threshold=100`, `InpEntry_Expiration_Sec=20`
- SL/Trail: `SL_MODE_DYNAMIC_ATR`, `InpSL_AtrMult=1.3`, `TrailMode=TRAIL_ATR`, `TrailAtrMult=0.6`
- BE: `InpBE_Enable=true`, `BE_MODE_RATIO`, `InpBE_Trigger_Ratio=0.6`

Détails + stats: `REPORTS/ICM_JP225_calibration.md`.

## See also

- Inputs: `DOCS/inputs/index.md`
- Backtesting: `DOCS/workflows/backtesting.md`

## Last verified
Last verified: 2026-02-25 — Méthode: relecture `REPORTS/ICM_JP225_calibration.md` + mise à jour du wording version + vérification des unités via `REPORTS/symbol-info.txt`.
