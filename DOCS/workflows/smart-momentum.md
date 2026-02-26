# Smart Momentum v2 (v3.431)

## Objectif

Documenter l’implémentation Smart Momentum v2 dans `MQL5/Experts/Aurora.mq5` pour améliorer robustesse + performance, tout en conservant l’ATR structurel inchangé.

## Sources

- EA cible: `MQL5/Experts/Aurora.mq5`
- Logger cible: `MQL5/Include/Aurora/aurora_logger.mqh`

## Interface publique ajoutée (Momentum)

- `ENUM_SMARTMOM_MODEL`: `LINEAR_LEGACY`, `SIGMOID_VR`, `PIECEWISE_REGIME`
- `InpSmartMom_Model`
- `InpSmartMom_VR_ClampMin`, `InpSmartMom_VR_ClampMax`
- `InpSmartMom_VR_SmoothAlpha`
- `InpSmartMom_Mult_Deadband`
- `InpSmartMom_RegimeGate_Enable`, `InpSmartMom_Regime_VR_Min`, `InpSmartMom_Regime_VR_Max`
- `InpSmartMom_BreakoutConfirmBars`, `InpSmartMom_ReentryCooldownBars`
- `InpSmartMom_MinBreakoutPts`
- Smart Momentum v2 journalise désormais via `InpLog_Diagnostic` (plus de flag SmartMom dédié)
- `InpSmartMom_UseDynamicERFloor`, `InpSmartMom_DynER_BaseFloor`, `InpSmartMom_DynER_VR_Factor`, `InpSmartMom_DynER_MinFloor`, `InpSmartMom_DynER_MaxFloor`

Bornes principales conservées: `InpSmartMom_MinMult` / `InpSmartMom_MaxMult`.

## Logique implémentée

1. **Mapping multiplicateur configurable**
   - Modèle linéaire legacy (`MinMult * VR` clampé).
   - Modèle sigmoid (recommandé après validation).
   - Modèle piecewise régime.
2. **Stabilisation temporelle**
   - État runtime: VR brut, VR lissé, multiplicateur cible, multiplicateur actif.
   - Deadband sur `mult_active` pour éviter micro-oscillations.
3. **Gate d’entrée**
   - Filtre ER (base ou floor dynamique),
   - Filtre VR de régime,
   - Distance minimale de breakout,
   - Confirmation breakout (Reactive),
   - Cooldown de re-entry.
4. **Cohérence géométrique**
   - Fonction unifiée `GetSmartMomentumBandsV2(...)` utilisée par:
     - setup entrée (`BuySetup`/`SellSetup`),
     - sorties (`CheckClose`),
     - `ComputeStop` (path Momentum),
     - pré-calcul Predictive.
5. **Observabilité**
   - Logs dédiés `[SMARTMOM]` via `CAuroraLogger::InfoSmartMom/WarnSmartMom/ErrorSmartMom`.
   - Compteurs runtime (générés, acceptés, filtrés, blocs gate/cooldown/breakout, fills).

## Contraintes maintenues

- Pas de refactor ATR structurel.
- Pas de modification des signatures iCustom ATR existantes pour SuperTrend/Momentum ATR.

## Validation attendue

- Sanity: compilation EA sans erreur + init handles OK.
- Invariants techniques: pas de NaN/EMPTY dans bandes, bornes `MinMult <= mult_active <= MaxMult`.
- A/B: comparer un preset “baseline” (SmartMom désactivé ou modèle legacy) vs un preset Smart Momentum v2 avec mêmes conditions de test.
- Walk-forward: valider stabilité multi-fenêtres avant changement du modèle par défaut.

## TODO(verify)

- TODO(verify): confirmer les gains PF/NetProfit/WinRate/DD/Expectancy sur les fenêtres walk-forward cibles — Comment obtenir: lancer les campagnes A/B dans MT5 Strategy Tester avec mêmes datasets, spreads et sessions, puis consolider les métriques par fenêtre.
- TODO(verify): figer les bornes temporelles IS/OOS par symbole/timeframe selon historique réellement disponible — Comment obtenir: lister l’historique effectif dans MT5 (`Centre d’historique`) et versionner les bornes dans `REPORTS/`.

## See also

- Référence v3.431: [`v3431-current.md`](v3431-current.md)
- Workflow backtesting: [`backtesting.md`](backtesting.md)

## Last verified
Last verified: 2026-02-25 — Méthode: inspection statique de `MQL5/Experts/Aurora.mq5` et `MQL5/Include/Aurora/aurora_logger.mqh` (AURORA_VERSION=3.431).
