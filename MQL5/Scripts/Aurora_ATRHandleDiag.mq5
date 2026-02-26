//+------------------------------------------------------------------+
//|                                           Aurora_ATRHandleDiag   |
//|                                    Copyright 2026, Tommy Suzanne |
//|                                  https://github.com/tommysuzanne |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tommy Suzanne"
#property link      " https://github.com/tommysuzanne"
#property strict
#property script_show_inputs

#include <Aurora/aurora_error_utils.mqh>

input string         InpSymbol         = "JP225";          // Symbol to test (empty -> _Symbol)
input ENUM_TIMEFRAMES InpTimeframe     = PERIOD_CURRENT;   // Timeframe to test
input int            InpAtrPeriod      = 14;               // ATR period
input int            InpCopyCount      = 5;                // CopyBuffer count (0..N-1)
input bool           InpPreloadRates   = true;             // Try CopyRates before iATR
input int            InpPreloadBars    = 500;              // CopyRates bar count

void OnStart()
{
   string symbol = InpSymbol;
   if(symbol == "") symbol = _Symbol;

   ENUM_TIMEFRAMES tf = InpTimeframe;
   if(tf == PERIOD_CURRENT) tf = (ENUM_TIMEFRAMES)Period();

   PrintFormat("[ATR-DIAG] symbol=%s tf=%s atrPeriod=%d tester=%d visual=%d build=%d",
               symbol,
               EnumToString(tf),
               InpAtrPeriod,
               (int)MQLInfoInteger(MQL_TESTER),
               (int)MQLInfoInteger(MQL_VISUAL_MODE),
               (int)TerminalInfoInteger(TERMINAL_BUILD));

   ResetLastError();
   if(!SymbolSelect(symbol, true))
   {
      const int err = GetLastError();
      PrintFormat("[ATR-DIAG] SymbolSelect(%s) failed err=%d (%s)", symbol, err, ErrorDescription(err));
      return;
   }

   const int bars = Bars(symbol, tf);
   PrintFormat("[ATR-DIAG] Bars(%s,%s)=%d", symbol, EnumToString(tf), bars);

   if(InpPreloadRates)
   {
      const int want = (InpPreloadBars > 1 ? InpPreloadBars : 1);
      MqlRates rates[];
      ResetLastError();
      const int got = CopyRates(symbol, tf, 0, want, rates);
      const int err = GetLastError();
      PrintFormat("[ATR-DIAG] CopyRates(count=%d) got=%d err=%d (%s)", want, got, err, ErrorDescription(err));
   }

   ResetLastError();
   const int h = iATR(symbol, tf, InpAtrPeriod);
   const int atrErr = GetLastError();
   PrintFormat("[ATR-DIAG] iATR(handle)=%d err=%d (%s)", h, atrErr, ErrorDescription(atrErr));
   if(h == INVALID_HANDLE) return;

   const int count = (InpCopyCount > 1 ? InpCopyCount : 1);
   double buf[];
   ArrayResize(buf, count);
   ArraySetAsSeries(buf, true);
   ResetLastError();
   const int n = CopyBuffer(h, 0, 0, count, buf);
   const int copyErr = GetLastError();
   PrintFormat("[ATR-DIAG] CopyBuffer(count=%d) n=%d err=%d (%s)", count, n, copyErr, ErrorDescription(copyErr));

   for(int i = 0; i < MathMin(n, count); i++)
   {
      PrintFormat("[ATR-DIAG] ATR[%d]=%.10f", i, buf[i]);
   }

   IndicatorRelease(h);
}

