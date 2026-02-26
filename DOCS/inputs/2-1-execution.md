# Inputs — 2.1 Exécution

## Source-of-truth

- `MQL5/Experts/Aurora.mq5` (section Inputs)

## Définition (extrait)

```mql5
input group "2.1 - Exécution"
input ulong                     MagicNumber                 = 77008866;                 // Numéro magique
input ENUM_ENTRY_STRATEGY       InpEntry_Strategy           = STRATEGY_PREDICTIVE;      // Stratégie d'exécution (Réactif / Prédictif)
input ENUM_PREDICTIVE_OFFSET_MODE InpPredictive_Offset_Mode = OFFSET_MODE_POINTS;       // Prédictif - Mode Offset (Points / ATR)
input int                       InpPredictive_Offset        = 0;                        // Prédictif - Offset (Points fixes)
input int                       InpPredictive_ATR_Period    = 14;                       // Prédictif - Période (ATR)
input double                    InpPredictive_ATR_Mult      = 0.1;                      // Prédictif - Multiplicateur (ATR)
input int                       InpPredictive_Update_Threshold = 2;                     // Prédictif - Seuil de Mise à jour (Points)
input ENUM_ENTRY_MODE           InpEntry_Mode               = ENTRY_MODE_MARKET;        // Réactif - Mode d'exécution (Market / Limit / Stop)
input int                       InpEntry_Dist_Pts           = 0;                        // Réactif - Distance d'entrée (STOP, points)
input int                       InpEntry_Expiration_Sec     = 15;                       // Exécution - Expiration des ordres en attente (pending) (secondes)
input AURORA_OPEN_SIDE          InpOpen_Side                = DIR_BOTH_SIDES;           // Type de positions (Long / Short / Bidirectionnel)
input ENUM_FILLING              Filling                     = FILLING_DEFAULT;          // Type de remplissage des ordres (Auto/FOK/IOC/RETURN)
input int                       TimerInterval               = 1;                        // Intervalle OnTimer (secondes)
```

## See also

- Exécution reactive : `../strategies/execution-reactive.md`
- Exécution predictive : `../strategies/execution-predictive.md`

## Last verified
Last verified: 2026-02-25 — Méthode: mise à jour des références de version + vérification de `AURORA_VERSION` dans `MQL5/Experts/Aurora.mq5` (3.431).
