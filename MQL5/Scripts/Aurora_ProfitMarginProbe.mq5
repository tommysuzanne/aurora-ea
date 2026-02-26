//+------------------------------------------------------------------+
//|                                        Aurora_ProfitMarginProbe  |
//|                                    Copyright 2026, Tommy Suzanne |
//|                                  https://github.com/tommysuzanne |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tommy Suzanne"
#property link      " https://github.com/tommysuzanne"
#property strict
#property script_show_inputs

input string InpSymbol            = "JP225"; // Symbol to inspect (IC Markets: "JP225")
input double InpLots              = 1.0;     // Volume to probe (lots)
input double InpMove_IndexPoints  = 1.0;     // Price move in index points (JP225: 1.00 = 1.00 price)
input bool   InpToFile            = true;    // Also write to FILE_COMMON
input string InpOutFile           = "AURORA\\profit-margin-probe.txt"; // FILE_COMMON relative path

void PrintKV(const string k, const string v)
{
   PrintFormat("[PROBE] %s=%s", k, v);
}

string DblStr(const double v, const int digits = 10)
{
   if(!MathIsValidNumber(v)) return("NaN");
   return(DoubleToString(v, digits));
}

// Writes a line to file (optional) and also prints it.
void EmitLine(int fh, const string k, const string v)
{
   PrintKV(k, v);
   if(fh != INVALID_HANDLE)
      FileWrite(fh, k, v);
}

bool TrySelectSymbol(const string symbol)
{
   ResetLastError();
   if(SymbolSelect(symbol, true))
      return(true);
   PrintFormat("[PROBE] SymbolSelect(%s) failed err=%d", symbol, GetLastError());
   return(false);
}

bool GetTickSafe(const string symbol, MqlTick &tick)
{
   ResetLastError();
   if(SymbolInfoTick(symbol, tick))
      return(true);

   // Fallback: some symbols may not have a tick immediately in some contexts.
   tick.bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   tick.ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   tick.last = SymbolInfoDouble(symbol, SYMBOL_LAST);
   tick.time = (datetime)TimeTradeServer();
   tick.time_msc = 0;
   return(tick.ask > 0.0 && tick.bid > 0.0);
}

string EnumStrLong(const long v)
{
   // Best-effort: EnumToString() works when cast to the correct enum type.
   // We keep the numeric value too.
   return(StringFormat("%lld", v));
}

bool CalcProfit(const ENUM_ORDER_TYPE type, const string symbol, const double lots,
                const double open_price, const double close_price, double &profit_out)
{
   ResetLastError();
   if(OrderCalcProfit(type, symbol, lots, open_price, close_price, profit_out))
      return(true);
   PrintFormat("[PROBE] OrderCalcProfit(%d,%s,%.2f,%.5f,%.5f) failed err=%d",
               (int)type, symbol, lots, open_price, close_price, GetLastError());
   profit_out = 0.0;
   return(false);
}

bool CalcMargin(const ENUM_ORDER_TYPE type, const string symbol, const double lots,
                const double price, double &margin_out)
{
   ResetLastError();
   if(OrderCalcMargin(type, symbol, lots, price, margin_out))
      return(true);
   PrintFormat("[PROBE] OrderCalcMargin(%d,%s,%.2f,%.5f) failed err=%d",
               (int)type, symbol, lots, price, GetLastError());
   margin_out = 0.0;
   return(false);
}

void OnStart()
{
   string symbol = InpSymbol;
   if(symbol == "")
      symbol = _Symbol;

   if(!TrySelectSymbol(symbol))
      return;

   int fh = INVALID_HANDLE;
   if(InpToFile)
   {
      ResetLastError();
      // Use ANSI so the file is readable without UTF-16 conversion.
      fh = FileOpen(InpOutFile, FILE_WRITE | FILE_TXT | FILE_COMMON | FILE_ANSI);
      if(fh == INVALID_HANDLE)
         PrintFormat("[PROBE] FileOpen(FILE_COMMON,%s) failed err=%d", InpOutFile, GetLastError());
   }

   // Account context
   const string acc_ccy = AccountInfoString(ACCOUNT_CURRENCY);
   const long acc_leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   EmitLine(fh, "account_currency", acc_ccy);
   EmitLine(fh, "account_leverage", (string)acc_leverage);

   // Symbol contract
   const long digits = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   const double tick_value_profit = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   const double tick_value_loss = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   const double contract_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   const long calc_mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE);
   const string ccy_profit = SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
   const string ccy_margin = SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN);
   const double vol_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   const double vol_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   const double vol_max = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

   EmitLine(fh, "symbol", symbol);
   EmitLine(fh, "SYMBOL_DIGITS", (string)digits);
   EmitLine(fh, "SYMBOL_POINT", DblStr(point, 10));
   EmitLine(fh, "SYMBOL_TRADE_TICK_SIZE", DblStr(tick_size, 10));
   EmitLine(fh, "SYMBOL_TRADE_TICK_VALUE", DblStr(tick_value, 10));
   EmitLine(fh, "SYMBOL_TRADE_TICK_VALUE_PROFIT", DblStr(tick_value_profit, 10));
   EmitLine(fh, "SYMBOL_TRADE_TICK_VALUE_LOSS", DblStr(tick_value_loss, 10));
   EmitLine(fh, "SYMBOL_TRADE_CONTRACT_SIZE", DblStr(contract_size, 10));
   EmitLine(fh, "SYMBOL_TRADE_CALC_MODE(raw)", EnumStrLong(calc_mode));
   EmitLine(fh, "SYMBOL_CURRENCY_PROFIT", ccy_profit);
   EmitLine(fh, "SYMBOL_CURRENCY_MARGIN", ccy_margin);
   EmitLine(fh, "SYMBOL_VOLUME_MIN", DblStr(vol_min, 4));
   EmitLine(fh, "SYMBOL_VOLUME_STEP", DblStr(vol_step, 4));
   EmitLine(fh, "SYMBOL_VOLUME_MAX", DblStr(vol_max, 4));

   // Current tick
   MqlTick t;
   if(!GetTickSafe(symbol, t))
   {
      EmitLine(fh, "tick_error", "No tick available (bid/ask unavailable)");
      if(fh != INVALID_HANDLE) FileClose(fh);
      return;
   }

   const double bid = t.bid;
   const double ask = t.ask;
   const double mid = (bid + ask) * 0.5;
   EmitLine(fh, "BID", DblStr(bid, (int)digits));
   EmitLine(fh, "ASK", DblStr(ask, (int)digits));
   EmitLine(fh, "MID", DblStr(mid, (int)digits));
   EmitLine(fh, "SPREAD(price)", DblStr(ask - bid, (int)digits));
   if(point > 0.0)
      EmitLine(fh, "SPREAD(points)", DblStr((ask - bid) / point, 2));

   const double lots = InpLots;
   const double move1 = InpMove_IndexPoints; // price units for JP225 (1.00 = 1.00 price)
   const double move_tick = tick_size;
   const double move_point = point;

   EmitLine(fh, "probe_lots", DblStr(lots, 4));
   EmitLine(fh, "probe_move_index_points(price)", DblStr(move1, (int)digits));
   EmitLine(fh, "probe_move_tick_size(price)", DblStr(move_tick, (int)digits));
   EmitLine(fh, "probe_move_mt5_point(price)", DblStr(move_point, (int)digits));

   // Profit in deposit currency (MT5 converts from symbol profit currency if needed).
   double p_buy_up = 0.0, p_buy_dn = 0.0, p_sell_dn = 0.0, p_sell_up = 0.0;
   CalcProfit(ORDER_TYPE_BUY,  symbol, lots, ask, ask + move1, p_buy_up);
   CalcProfit(ORDER_TYPE_BUY,  symbol, lots, ask, ask - move1, p_buy_dn);
   CalcProfit(ORDER_TYPE_SELL, symbol, lots, bid, bid - move1, p_sell_dn);
   CalcProfit(ORDER_TYPE_SELL, symbol, lots, bid, bid + move1, p_sell_up);

   EmitLine(fh, "OrderCalcProfit_BUY(+move)",  DblStr(p_buy_up, 8));
   EmitLine(fh, "OrderCalcProfit_BUY(-move)",  DblStr(p_buy_dn, 8));
   EmitLine(fh, "OrderCalcProfit_SELL(-move)", DblStr(p_sell_dn, 8));
   EmitLine(fh, "OrderCalcProfit_SELL(+move)", DblStr(p_sell_up, 8));

   // Derived economics from SYMBOL_TRADE_TICK_VALUE (more stable than OrderCalcProfit when values are tiny).
   if(tick_size > 0.0)
   {
      const double ticks_per_index_point = 1.0 / tick_size;
      const double value_per_tick = tick_value * lots; // deposit currency
      const double value_per_index_point = tick_value * ticks_per_index_point * lots;
      const double spread_ticks = (ask - bid) / tick_size;
      const double spread_cost = spread_ticks * tick_value * lots;
      EmitLine(fh, "DERIVED_ticks_per_index_point", DblStr(ticks_per_index_point, 2));
      EmitLine(fh, "DERIVED_value_per_tick(deposit_ccy)", DblStr(value_per_tick, 10));
      EmitLine(fh, "DERIVED_value_per_1.00_index_point(deposit_ccy)", DblStr(value_per_index_point, 10));
      EmitLine(fh, "DERIVED_spread_ticks", DblStr(spread_ticks, 2));
      EmitLine(fh, "DERIVED_spread_cost(deposit_ccy)", DblStr(spread_cost, 10));
   }

   // Profit for 1 tick_size and 1 point move, to validate tick_value.
   double p_buy_tick = 0.0, p_sell_tick = 0.0;
   double p_buy_point = 0.0, p_sell_point = 0.0;
   CalcProfit(ORDER_TYPE_BUY,  symbol, lots, ask, ask + move_tick,  p_buy_tick);
   CalcProfit(ORDER_TYPE_SELL, symbol, lots, bid, bid - move_tick,  p_sell_tick);
   CalcProfit(ORDER_TYPE_BUY,  symbol, lots, ask, ask + move_point, p_buy_point);
   CalcProfit(ORDER_TYPE_SELL, symbol, lots, bid, bid - move_point, p_sell_point);

   EmitLine(fh, "OrderCalcProfit_BUY(+tick_size)",  DblStr(p_buy_tick, 10));
   EmitLine(fh, "OrderCalcProfit_SELL(-tick_size)", DblStr(p_sell_tick, 10));
   EmitLine(fh, "OrderCalcProfit_BUY(+1_point)",    DblStr(p_buy_point, 10));
   EmitLine(fh, "OrderCalcProfit_SELL(-1_point)",   DblStr(p_sell_point, 10));

   if(tick_value > 0.0 && move_tick > 0.0)
   {
      // tick_value is usually the value of tick_size for 1 lot (in deposit currency).
      EmitLine(fh, "tick_value_note", "Compare OrderCalcProfit(+tick_size) with SYMBOL_TRADE_TICK_VALUE");
      EmitLine(fh, "tick_value_delta_buy",  DblStr(p_buy_tick - tick_value * lots, 10));
      EmitLine(fh, "tick_value_delta_sell", DblStr(p_sell_tick - tick_value * lots, 10));

      if(p_buy_tick == 0.0 && tick_value * lots > 0.0)
      {
         EmitLine(fh, "rounding_note",
                  "OrderCalcProfit(+tick_size) returned 0.0 while tick_value is non-zero. This can happen when values are below account currency rounding. Use larger InpLots or InpMove_IndexPoints to cross-check.");
      }
   }

   // Margin in deposit currency (depends on price, leverage, calc_mode, etc.)
   double m_buy = 0.0, m_sell = 0.0;
   CalcMargin(ORDER_TYPE_BUY,  symbol, lots, ask, m_buy);
   CalcMargin(ORDER_TYPE_SELL, symbol, lots, bid, m_sell);
   EmitLine(fh, "OrderCalcMargin_BUY",  DblStr(m_buy, 8));
   EmitLine(fh, "OrderCalcMargin_SELL", DblStr(m_sell, 8));

   // Optional: show USDJPY if available (helps interpret conversions when profit/margin currency is JPY).
   const string fx = "USDJPY";
   if(TrySelectSymbol(fx))
   {
      MqlTick fx_t;
      if(GetTickSafe(fx, fx_t))
      {
         EmitLine(fh, "USDJPY_BID", DblStr(fx_t.bid, 5));
         EmitLine(fh, "USDJPY_ASK", DblStr(fx_t.ask, 5));
      }
   }

   if(fh != INVALID_HANDLE)
   {
      FileClose(fh);
      PrintFormat("[PROBE] Wrote FILE_COMMON: %s", InpOutFile);
   }
}
