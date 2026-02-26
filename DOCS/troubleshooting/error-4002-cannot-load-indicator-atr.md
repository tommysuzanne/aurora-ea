# Erreur 4002 — “cannot load indicator 'Average True Range' … [4002]”

## Objectif

Diagnostiquer et corriger l’erreur MT5/Strategy Tester :

`cannot load indicator 'Average True Range' (JP225) [4002]`

et éviter qu’une stratégie (ex: Momentum) se bloque **sans explication actionnable**.

## Symptôme ↔ impact (Aurora)

- Symptôme: le terminal journalise `cannot load indicator 'Average True Range' ... [4002]`.
- Impact typique: un composant qui dépend de `iATR()` échoue à s’initialiser (handle `INVALID_HANDLE`) ⇒ un indicateur custom/EA peut refuser l’init ou rester “non prêt” ⇒ **pas d’ordres**.

Dans Aurora, cela peut casser Momentum si `AuKeltnerKama` dépend de `iATR()` pour calculer ses bandes, ou casser des modes SL/BE/Trail basés sur ATR.

## Signification de `[4002]`

`4002 = ERR_WRONG_INTERNAL_PARAMETER` (erreur runtime MT5).

Source (doc officielle):
- MQL5 Error Codes: <https://www.mql5.com/en/docs/constants/errorswarnings/errorcodes>
- `iATR()` (création handle ATR): <https://www.mql5.com/en/docs/indicators/iatr>
- `ResetLastError()` / `GetLastError()`: <https://www.mql5.com/en/docs/common/resetlasterror>
- `CopyBuffer()` (lecture d’un handle): <https://www.mql5.com/en/docs/series/copybuffer>

## Causes fréquentes (Tester vs Live)

> Règle: ne pas supposer. Chaque hypothèse doit être prouvée/invalidée via un test concret.

### A) Strategy Tester / agents

- Séries / historique pas prêt au moment de la création du handle (surtout au tout début du test).
- Environnement agent incomplet / standard indicators absents ou corrompus (peut se manifester comme un échec de chargement d’un indicateur “standard”).
- Différences d’exécution (agent local vs cloud), ou build MT5 spécifique.

### B) Live / chart

- Symbole non standard / custom symbol / suffixe broker (ex: mapping `JP225` vs `JP225.`).
- SymbolSelect/Market Watch non prêt ou symbol non tradable/disabled.

## Diagnostic (procédure)

### 1) Activer des logs utiles

Dans les inputs Aurora:

- `InpLog_General=true`
- `InpLog_Diagnostic=true`
- `InpLog_IndicatorInternal=true`

But: lier explicitement l’erreur du terminal au **composant** qui a échoué (handle, symbole, timeframe, période).

### 2) Tester `iATR()` isolément (script)

Lancer `MQL5/Scripts/Aurora_ATRHandleDiag.mq5` sur un chart `JP225` (et/ou dans le Tester).

Attendus:
- Si `iATR()` retourne `INVALID_HANDLE`, le script imprime `err=4002` (ou autre) avec le contexte.
- Si `iATR()` marche mais `CopyBuffer` échoue, la cause est souvent “data not ready / series not synchronized”.

### 3) Vérifier le contrat symbole

Lancer `MQL5/Scripts/Aurora_SymbolInfoDump.mq5` et vérifier que le symbole est sélectionné/visible et cohérent.

### 4) Vérifier la compilation des `.ex5` embarqués

Si Aurora embarque un indicateur via `#resource` (ex: `Indicators\\Aurora\\AuKeltnerKama.ex5`), le terminal doit avoir une version **compilée** à jour.

`TODO(verify): confirmer le workflow exact de compilation/copie des `.ex5` pour le Tester (local vs agents)` — Comment obtenir: suivre `DOCS/getting-started/install-compile.md` et vérifier la présence des `.ex5` dans le Data Folder du terminal utilisé par le Tester.

## Correctifs côté code (Aurora)

- Momentum: éviter une dépendance dure à `iATR()` dans l’indicateur `MQL5/Indicators/Aurora/AuKeltnerKama.mq5` (calcul ATR manuel si nécessaire).
- SL/BE/Trail basés sur ATR: si un handle `iATR()` échoue, logger clairement et utiliser un fallback (ATR calculé via `high/low/close`) au lieu de “bloquer silencieusement”.

`TODO(verify): valider en Strategy Tester (JP225) que l’erreur ne se reproduit plus et que Momentum place des ordres` — Comment obtenir: run court (1–2 jours) + logs `InpLog_*` + comparer avant/après.

## See also

- Logs & diagnostic: `DOCS/workflows/debugging.md`
- EA: `MQL5/Experts/Aurora.mq5`
- Indicateur Momentum: `MQL5/Indicators/Aurora/AuKeltnerKama.mq5`

## Last verified
Last verified: 2026-02-22 — Méthode: inspection statique du code (`iCustom` Momentum + dépendance `iATR`) + ajout d’un script de diagnostic `iATR` (repro Tester à confirmer via TODO).
