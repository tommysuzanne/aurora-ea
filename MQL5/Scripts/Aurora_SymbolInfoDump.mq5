//+------------------------------------------------------------------+
//|                                             Aurora_SymbolInfoDump |
//|                                    Copyright 2026, Tommy Suzanne |
//|                                  https://github.com/tommysuzanne |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tommy Suzanne"
#property link      " https://github.com/tommysuzanne"
#property strict
#property script_show_inputs

#ifndef SYMBOL_EXPIRATION_GTC
#define SYMBOL_EXPIRATION_GTC 1
#endif
#ifndef SYMBOL_EXPIRATION_DAY
#define SYMBOL_EXPIRATION_DAY 2
#endif
#ifndef SYMBOL_EXPIRATION_SPECIFIED
#define SYMBOL_EXPIRATION_SPECIFIED 4
#endif
#ifndef SYMBOL_EXPIRATION_SPECIFIED_DAY
#define SYMBOL_EXPIRATION_SPECIFIED_DAY 8
#endif

#ifndef SYMBOL_FILLING_FOK
#define SYMBOL_FILLING_FOK 1
#endif
#ifndef SYMBOL_FILLING_IOC
#define SYMBOL_FILLING_IOC 2
#endif
#ifndef SYMBOL_FILLING_BOC
#define SYMBOL_FILLING_BOC 4
#endif

#ifndef SYMBOL_ORDER_MARKET
#define SYMBOL_ORDER_MARKET 1
#endif
#ifndef SYMBOL_ORDER_LIMIT
#define SYMBOL_ORDER_LIMIT 2
#endif
#ifndef SYMBOL_ORDER_STOP
#define SYMBOL_ORDER_STOP 4
#endif
#ifndef SYMBOL_ORDER_STOP_LIMIT
#define SYMBOL_ORDER_STOP_LIMIT 8
#endif
#ifndef SYMBOL_ORDER_SL
#define SYMBOL_ORDER_SL 16
#endif
#ifndef SYMBOL_ORDER_TP
#define SYMBOL_ORDER_TP 32
#endif
#ifndef SYMBOL_ORDER_CLOSEBY
#define SYMBOL_ORDER_CLOSEBY 64
#endif

input string InpSymbol            = "JP225"; // Symbol to inspect (IC Markets: "JP225")
input bool   InpToChart           = true;    // Also show compact summary on chart
input bool   InpToFile            = true;    // Also write to FILE_COMMON
input string InpOutFile           = "AURORA\\symbol-info.txt"; // FILE_COMMON relative path
input int    InpReferenceSlippage = 30;      // Reference slippage (points) used by Aurora inputs
input int    InpSpreadSamples     = 25;      // Number of spread samples for min/avg/p50/p90/max
input int    InpSpreadSampleMs    = 100;     // Delay between spread samples (ms)

void PrintKV(const string k, const string v)
{
   PrintFormat("[SYMBOL-INFO] %s=%s", k, v);
}

string DblStr(const double v, const int digits = 8)
{
   if(!MathIsValidNumber(v)) return("NaN");
   return(DoubleToString(v, digits));
}

string BoolStr(const bool v)
{
   return(v ? "true" : "false");
}

string TimeStr(const datetime v)
{
   if(v <= 0)
      return("0");
   return(TimeToString(v, TIME_DATE | TIME_SECONDS));
}

string FillFlags(const long mask)
{
   string out = "";
   if((mask & SYMBOL_FILLING_FOK) != 0) out += "FOK ";
   if((mask & SYMBOL_FILLING_IOC) != 0) out += "IOC ";
   if((mask & SYMBOL_FILLING_BOC) != 0) out += "BOC ";
   if(out == "") return("(none flagged; RETURN may still apply)");
   StringTrimRight(out);
   return(out);
}

string ExpFlags(const long mask)
{
   string out = "";
   if((mask & SYMBOL_EXPIRATION_GTC) != 0) out += "GTC ";
   if((mask & SYMBOL_EXPIRATION_DAY) != 0) out += "DAY ";
   if((mask & SYMBOL_EXPIRATION_SPECIFIED) != 0) out += "SPECIFIED ";
   if((mask & SYMBOL_EXPIRATION_SPECIFIED_DAY) != 0) out += "SPECIFIED_DAY ";
   if(out == "") return("(mode=0/unknown)");
   StringTrimRight(out);
   return(out);
}

string OrderFlags(const long mask)
{
   string out = "";
   if((mask & SYMBOL_ORDER_MARKET) != 0) out += "MARKET ";
   if((mask & SYMBOL_ORDER_LIMIT) != 0) out += "LIMIT ";
   if((mask & SYMBOL_ORDER_STOP) != 0) out += "STOP ";
   if((mask & SYMBOL_ORDER_STOP_LIMIT) != 0) out += "STOP_LIMIT ";
   if((mask & SYMBOL_ORDER_SL) != 0) out += "SL ";
   if((mask & SYMBOL_ORDER_TP) != 0) out += "TP ";
   if((mask & SYMBOL_ORDER_CLOSEBY) != 0) out += "CLOSE_BY ";
   if(out == "") return("(none flagged)");
   StringTrimRight(out);
   return(out);
}

void PushKV(string &keys[],
            string &vals[],
            const string key,
            const string val)
{
   const int n = ArraySize(keys);
   ArrayResize(keys, n + 1);
   ArrayResize(vals, n + 1);
   keys[n] = key;
   vals[n] = val;
   PrintKV(key, val);
}

void OnStart()
{
   string symbol = InpSymbol;
   if(symbol == "")
      symbol = _Symbol;

   ResetLastError();
   if(!SymbolSelect(symbol, true))
   {
      const int err = GetLastError();
      PrintFormat("[SYMBOL-INFO] SymbolSelect(%s) failed err=%d", symbol, err);
      return;
   }

   string keys[];
   string vals[];

   const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   const long stops_level_pts = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const long digits = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   const long freeze_level_pts = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   const double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   const double tick_value_profit = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   const double tick_value_loss = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   const double contract_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   const long trade_calc_mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE);
   const string ccy_base = SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE);
   const string ccy_profit = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
   const string ccy_margin = SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN);
   const double margin_initial = SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL);
   const double margin_maintenance = SymbolInfoDouble(symbol, SYMBOL_MARGIN_MAINTENANCE);
   const double margin_hedged = SymbolInfoDouble(symbol, SYMBOL_MARGIN_HEDGED);
   const bool margin_hedged_use_leg = (SymbolInfoInteger(symbol, SYMBOL_MARGIN_HEDGED_USE_LEG) != 0);
   const long swap_mode = SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE);
   const double swap_long = SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG);
   const double swap_short = SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT);
   const long swap_roll3x = SymbolInfoInteger(symbol, SYMBOL_SWAP_ROLLOVER3DAYS);
   const double vol_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   const double vol_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   const double vol_max = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   const double vol_limit = SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT);

   const long trade_mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   const long exe_mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_EXEMODE);
   const long fill_mask = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   const long exp_mask = SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_MODE);
   const long order_mask = SymbolInfoInteger(symbol, SYMBOL_ORDER_MODE);
   const long ticks_book_depth = SymbolInfoInteger(symbol, SYMBOL_TICKS_BOOKDEPTH);
   const bool symbol_select = (SymbolInfoInteger(symbol, SYMBOL_SELECT) != 0);
   const bool symbol_visible = (SymbolInfoInteger(symbol, SYMBOL_VISIBLE) != 0);
   const string symbol_desc = SymbolInfoString(symbol, SYMBOL_DESCRIPTION);
   const string symbol_path = SymbolInfoString(symbol, SYMBOL_PATH);
   const long symbol_chart_mode = SymbolInfoInteger(symbol, SYMBOL_CHART_MODE);
   const long spread_points = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   const bool spread_float = (SymbolInfoInteger(symbol, SYMBOL_SPREAD_FLOAT) != 0);
   const double session_limit_min = SymbolInfoDouble(symbol, SYMBOL_SESSION_PRICE_LIMIT_MIN);
   const double session_limit_max = SymbolInfoDouble(symbol, SYMBOL_SESSION_PRICE_LIMIT_MAX);
   const datetime terminal_server_time = TimeTradeServer();
   const datetime terminal_local_time = TimeLocal();
   const datetime terminal_gmt_time = TimeGMT();

   MqlTick tick;
   const bool has_tick = SymbolInfoTick(symbol, tick);
   const double bid = has_tick ? tick.bid : SymbolInfoDouble(symbol, SYMBOL_BID);
   const double ask = has_tick ? tick.ask : SymbolInfoDouble(symbol, SYMBOL_ASK);
   const double last = has_tick ? tick.last : SymbolInfoDouble(symbol, SYMBOL_LAST);

   double spread_price_live = ask - bid;
   if(!MathIsValidNumber(spread_price_live) || spread_price_live < 0.0)
      spread_price_live = 0.0;
   const double spread_points_live = (point > 0.0 ? spread_price_live / point : 0.0); // MT5 points
   const double spread_ticks_live = (tick_size > 0.0 ? spread_price_live / tick_size : 0.0);
   const double spread_price_from_symbol = (point > 0.0 ? (double)spread_points * point : 0.0);

   double spread_min_pts = 0.0;
   double spread_avg_pts = 0.0;
   double spread_p50_pts = 0.0;
   double spread_p90_pts = 0.0;
   double spread_max_pts = 0.0;
   int spread_n = 0;
   const int sample_target = (InpSpreadSamples > 1 ? InpSpreadSamples : 1);
   const int sample_wait_ms = (InpSpreadSampleMs > 0 ? InpSpreadSampleMs : 0);
   if(point > 0.0)
   {
      double spread_pts_samples[];
      for(int i = 0; i < sample_target; i++)
      {
         MqlTick st;
         if(SymbolInfoTick(symbol, st))
         {
            const double sp_pts = (st.ask - st.bid) / point;
            if(MathIsValidNumber(sp_pts) && sp_pts >= 0.0)
            {
               const int n = ArraySize(spread_pts_samples);
               ArrayResize(spread_pts_samples, n + 1);
               spread_pts_samples[n] = sp_pts;
            }
         }
         if(i + 1 < sample_target && sample_wait_ms > 0)
            Sleep(sample_wait_ms);
      }

      spread_n = ArraySize(spread_pts_samples);
      if(spread_n > 0)
      {
         double sum = 0.0;
         ArraySort(spread_pts_samples);
         spread_min_pts = spread_pts_samples[0];
         spread_max_pts = spread_pts_samples[spread_n - 1];
         for(int i = 0; i < spread_n; i++)
            sum += spread_pts_samples[i];
         spread_avg_pts = sum / spread_n;
         spread_p50_pts = spread_pts_samples[(spread_n - 1) / 2];
         spread_p90_pts = spread_pts_samples[(int)MathFloor((spread_n - 1) * 0.90)];
      }
   }

   PushKV(keys, vals, "symbol", symbol);
   PushKV(keys, vals, "chart_symbol", _Symbol);
   PushKV(keys, vals, "chart_period", EnumToString((ENUM_TIMEFRAMES)_Period));
   PushKV(keys, vals, "terminal_time_server", TimeStr(terminal_server_time));
   PushKV(keys, vals, "terminal_time_local", TimeStr(terminal_local_time));
   PushKV(keys, vals, "terminal_time_gmt", TimeStr(terminal_gmt_time));
   PushKV(keys, vals, "SYMBOL_DESCRIPTION", symbol_desc);
   PushKV(keys, vals, "SYMBOL_PATH", symbol_path);
   PushKV(keys, vals, "SYMBOL_SELECT", BoolStr(symbol_select));
   PushKV(keys, vals, "SYMBOL_VISIBLE", BoolStr(symbol_visible));
   PushKV(keys, vals, "SYMBOL_CHART_MODE", EnumToString((ENUM_SYMBOL_CHART_MODE)symbol_chart_mode));
   PushKV(keys, vals, "SYMBOL_DIGITS", (string)digits);
   PushKV(keys, vals, "SYMBOL_POINT", DblStr(point, 10));
   PushKV(keys, vals, "SYMBOL_TRADE_TICK_SIZE", DblStr(tick_size, 10));
   PushKV(keys, vals, "SYMBOL_TRADE_TICK_VALUE", DblStr(tick_value, 10));
   PushKV(keys, vals, "SYMBOL_TRADE_TICK_VALUE_PROFIT", DblStr(tick_value_profit, 10));
   PushKV(keys, vals, "SYMBOL_TRADE_TICK_VALUE_LOSS", DblStr(tick_value_loss, 10));
   PushKV(keys, vals, "SYMBOL_TRADE_CONTRACT_SIZE", DblStr(contract_size, 4));
   PushKV(keys, vals, "SYMBOL_TRADE_CALC_MODE", EnumToString((ENUM_SYMBOL_CALC_MODE)trade_calc_mode));
   PushKV(keys, vals, "SYMBOL_CURRENCY_BASE", ccy_base);
   PushKV(keys, vals, "SYMBOL_CURRENCY_PROFIT", ccy_profit);
   PushKV(keys, vals, "SYMBOL_CURRENCY_MARGIN", ccy_margin);
   PushKV(keys, vals, "SYMBOL_MARGIN_INITIAL", DblStr(margin_initial, 8));
   PushKV(keys, vals, "SYMBOL_MARGIN_MAINTENANCE", DblStr(margin_maintenance, 8));
   PushKV(keys, vals, "SYMBOL_MARGIN_HEDGED", DblStr(margin_hedged, 8));
   PushKV(keys, vals, "SYMBOL_MARGIN_HEDGED_USE_LEG", BoolStr(margin_hedged_use_leg));
   PushKV(keys, vals, "SYMBOL_SWAP_MODE", EnumToString((ENUM_SYMBOL_SWAP_MODE)swap_mode));
   PushKV(keys, vals, "SYMBOL_SWAP_LONG", DblStr(swap_long, 8));
   PushKV(keys, vals, "SYMBOL_SWAP_SHORT", DblStr(swap_short, 8));
   PushKV(keys, vals, "SYMBOL_SWAP_ROLLOVER3DAYS", EnumToString((ENUM_DAY_OF_WEEK)swap_roll3x));
   PushKV(keys, vals, "SYMBOL_VOLUME_MIN", DblStr(vol_min, 4));
   PushKV(keys, vals, "SYMBOL_VOLUME_STEP", DblStr(vol_step, 4));
   PushKV(keys, vals, "SYMBOL_VOLUME_MAX", DblStr(vol_max, 4));
   PushKV(keys, vals, "SYMBOL_VOLUME_LIMIT", DblStr(vol_limit, 4));

   PushKV(keys, vals, "SYMBOL_TRADE_STOPS_LEVEL(points)", (string)stops_level_pts);
   PushKV(keys, vals, "SYMBOL_TRADE_FREEZE_LEVEL(points)", (string)freeze_level_pts);
   if(point > 0.0)
   {
      PushKV(keys, vals, "SYMBOL_TRADE_STOPS_LEVEL(price)", DblStr((double)stops_level_pts * point, 10));
      PushKV(keys, vals, "SYMBOL_TRADE_FREEZE_LEVEL(price)", DblStr((double)freeze_level_pts * point, 10));
   }

   PushKV(keys, vals, "SYMBOL_SPREAD(points)", (string)spread_points);
   PushKV(keys, vals, "SYMBOL_SPREAD(mt5_points)", (string)spread_points);
   PushKV(keys, vals, "SYMBOL_SPREAD(price_units)", DblStr(spread_price_from_symbol, (int)digits));
   PushKV(keys, vals, "SYMBOL_SPREAD(ticks)", DblStr((tick_size > 0.0 ? spread_price_from_symbol / tick_size : 0.0), 2));
   PushKV(keys, vals, "SYMBOL_SPREAD_FLOAT", BoolStr(spread_float));
   PushKV(keys, vals, "TICK_AVAILABLE", BoolStr(has_tick));
   PushKV(keys, vals, "SYMBOL_TICKS_BOOKDEPTH", (string)ticks_book_depth);
   PushKV(keys, vals, "SYMBOL_SESSION_PRICE_LIMIT_MIN", DblStr(session_limit_min, (int)digits));
   PushKV(keys, vals, "SYMBOL_SESSION_PRICE_LIMIT_MAX", DblStr(session_limit_max, (int)digits));
   PushKV(keys, vals, "TICK_TIME", TimeStr((datetime)tick.time));
   PushKV(keys, vals, "TICK_TIME_MSC", (string)tick.time_msc);
   PushKV(keys, vals, "SYMBOL_BID", DblStr(bid, (int)digits));
   PushKV(keys, vals, "SYMBOL_ASK", DblStr(ask, (int)digits));
   PushKV(keys, vals, "SYMBOL_LAST", DblStr(last, (int)digits));
   PushKV(keys, vals, "SPREAD_LIVE(price)", DblStr(spread_price_live, 10));
   PushKV(keys, vals, "SPREAD_LIVE(price_units)", DblStr(spread_price_live, (int)digits));
   PushKV(keys, vals, "SPREAD_LIVE(points)", DblStr(spread_points_live, 2));
   PushKV(keys, vals, "SPREAD_LIVE(mt5_points)", DblStr(spread_points_live, 2));
   PushKV(keys, vals, "SPREAD_LIVE(ticks)", DblStr(spread_ticks_live, 2));
   PushKV(keys, vals, "SPREAD_SAMPLING_TARGET", (string)sample_target);
   PushKV(keys, vals, "SPREAD_SAMPLING_INTERVAL_MS", (string)sample_wait_ms);
   PushKV(keys, vals, "SPREAD_SAMPLING_WINDOW_MS", (string)((sample_target - 1) * sample_wait_ms));
   PushKV(keys, vals, "SPREAD_SAMPLING_COUNT_OK", (string)spread_n);
   if(spread_n > 0)
   {
      PushKV(keys, vals, "SPREAD_SAMPLING_MIN(points)", DblStr(spread_min_pts, 2));
      PushKV(keys, vals, "SPREAD_SAMPLING_AVG(points)", DblStr(spread_avg_pts, 2));
      PushKV(keys, vals, "SPREAD_SAMPLING_P50(points)", DblStr(spread_p50_pts, 2));
      PushKV(keys, vals, "SPREAD_SAMPLING_P90(points)", DblStr(spread_p90_pts, 2));
      PushKV(keys, vals, "SPREAD_SAMPLING_MAX(points)", DblStr(spread_max_pts, 2));
      PushKV(keys, vals, "SPREAD_SAMPLING_MIN(price_units)", DblStr(spread_min_pts * point, (int)digits));
      PushKV(keys, vals, "SPREAD_SAMPLING_AVG(price_units)", DblStr(spread_avg_pts * point, (int)digits));
      PushKV(keys, vals, "SPREAD_SAMPLING_P50(price_units)", DblStr(spread_p50_pts * point, (int)digits));
      PushKV(keys, vals, "SPREAD_SAMPLING_P90(price_units)", DblStr(spread_p90_pts * point, (int)digits));
      PushKV(keys, vals, "SPREAD_SAMPLING_MAX(price_units)", DblStr(spread_max_pts * point, (int)digits));
   }
   else
   {
      PushKV(keys, vals, "SPREAD_SAMPLING_NOTE", "No valid sample captured.");
   }

   PushKV(keys, vals, "SYMBOL_TRADE_MODE", EnumToString((ENUM_SYMBOL_TRADE_MODE)trade_mode));
   PushKV(keys, vals, "SYMBOL_TRADE_EXEMODE", EnumToString((ENUM_SYMBOL_TRADE_EXECUTION)exe_mode));
   PushKV(keys, vals, "SYMBOL_FILLING_MODE(mask)", (string)fill_mask);
   PushKV(keys, vals, "SYMBOL_FILLING_MODE(flags)", FillFlags(fill_mask));
   PushKV(keys, vals, "SYMBOL_EXPIRATION_MODE(mask)", (string)exp_mask);
   PushKV(keys, vals, "SYMBOL_EXPIRATION_MODE(flags)", ExpFlags(exp_mask));
   PushKV(keys, vals, "SYMBOL_ORDER_MODE(mask)", (string)order_mask);
   PushKV(keys, vals, "SYMBOL_ORDER_MODE(flags)", OrderFlags(order_mask));

   PushKV(keys, vals, "SLIPPAGE_NOTE", "No broker-side SYMBOL_* property. Use EA input + observed fills.");
   PushKV(keys, vals, "UNITS_NOTE", "MT5 points are fractional quote units: price = mt5_points * SYMBOL_POINT.");
   PushKV(keys, vals, "REFERENCE_SLIPPAGE(points)", (string)InpReferenceSlippage);
   PushKV(keys, vals, "REFERENCE_SLIPPAGE(price)", DblStr((double)InpReferenceSlippage * point, 10));
   if(spread_points_live > 0.0)
      PushKV(keys, vals, "REFERENCE_SLIPPAGE(xSpreadLive)", DblStr((double)InpReferenceSlippage / spread_points_live, 3));
   else
      PushKV(keys, vals, "REFERENCE_SLIPPAGE(xSpreadLive)", "N/A");

   if(InpToChart)
   {
      string chartText = "";
      chartText += "Aurora Symbol Info Dump\n";
      chartText += "symbol: " + symbol + "\n";
      chartText += "digits/point: " + (string)digits + " / " + DblStr(point, 10) + "\n";
      chartText += "bid/ask/last: " + DblStr(bid, (int)digits) + " / " + DblStr(ask, (int)digits) + " / " + DblStr(last, (int)digits) + "\n";
      chartText += "spread: " + DblStr(spread_price_live, (int)digits) + " price (" + DblStr(spread_points_live, 2) + " mt5 pts)\n";
      chartText += "spread(float): " + BoolStr(spread_float) + "\n";
      chartText += "stops/freeze(points): " + (string)stops_level_pts + " / " + (string)freeze_level_pts + "\n";
      chartText += "trade mode: " + EnumToString((ENUM_SYMBOL_TRADE_MODE)trade_mode) + "\n";
      chartText += "execution: " + EnumToString((ENUM_SYMBOL_TRADE_EXECUTION)exe_mode) + "\n";
      chartText += "filling: " + FillFlags(fill_mask) + "\n";
      chartText += "expiration: " + ExpFlags(exp_mask) + "\n";
      chartText += "calc/currency: " + EnumToString((ENUM_SYMBOL_CALC_MODE)trade_calc_mode) + " / " + ccy_profit + "\n";
      chartText += "order types: " + OrderFlags(order_mask) + "\n";
      chartText += "vol(min/step/max): " + DblStr(vol_min, 4) + " / " + DblStr(vol_step, 4) + " / " + DblStr(vol_max, 4) + "\n";
      if(spread_n > 0)
         chartText += "spread sample p50/p90: " + DblStr(spread_p50_pts, 2) + " / " + DblStr(spread_p90_pts, 2) + " mt5 pts\n";
      chartText += "ref slippage(points): " + (string)InpReferenceSlippage + " (price=" + DblStr((double)InpReferenceSlippage * point, 10) + ")";
      Comment(chartText);
   }

   if(!InpToFile)
      return;

   ResetLastError();
   const int h = FileOpen(InpOutFile, FILE_WRITE | FILE_TXT | FILE_COMMON);
   if(h == INVALID_HANDLE)
   {
      const int err = GetLastError();
      PrintFormat("[SYMBOL-INFO] FileOpen(FILE_COMMON, %s) failed err=%d", InpOutFile, err);
      return;
   }

   const int n = ArraySize(keys);
   for(int i = 0; i < n; i++)
      FileWrite(h, keys[i], vals[i]);
   FileClose(h);

   PrintFormat("[SYMBOL-INFO] Wrote FILE_COMMON: %s", InpOutFile);
}
