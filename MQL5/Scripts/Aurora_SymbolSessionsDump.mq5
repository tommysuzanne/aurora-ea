//+------------------------------------------------------------------+
//|                                        Aurora_SymbolSessionsDump |
//|                                    Copyright 2026, Tommy Suzanne |
//|                                  https://github.com/tommysuzanne |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Tommy Suzanne"
#property link      " https://github.com/tommysuzanne"
#property strict
#property script_show_inputs

input string InpSymbol   = "JP225"; // Symbol to inspect (IC Markets: "JP225")
input bool   InpToFile   = true;    // Also write to FILE_COMMON
input string InpOutFile  = "AURORA\\symbol-sessions.txt"; // FILE_COMMON relative path
input int    InpMaxSessionsPerDay = 16; // Safety cap (most symbols have <= 4)

void PrintKV(const string k, const string v)
{
   PrintFormat("[SESSIONS] %s=%s", k, v);
}

string TimeStr(const datetime t)
{
   // Format: HH:MM (server time)
   return(TimeToString(t, TIME_MINUTES));
}

string DayName(const int day)
{
   switch(day)
   {
      case 0: return("Sun");
      case 1: return("Mon");
      case 2: return("Tue");
      case 3: return("Wed");
      case 4: return("Thu");
      case 5: return("Fri");
      case 6: return("Sat");
   }
   return((string)day);
}

bool TrySelectSymbol(const string symbol)
{
   ResetLastError();
   if(SymbolSelect(symbol, true))
      return(true);
   PrintFormat("[SESSIONS] SymbolSelect(%s) failed err=%d", symbol, GetLastError());
   return(false);
}

void EmitLine(const int fh, const string line)
{
   PrintFormat("[SESSIONS] %s", line);
   if(fh != INVALID_HANDLE)
      FileWriteString(fh, line + "\r\n");
}

void DumpSessionsForDay(const int fh, const string symbol, const int day)
{
   const ENUM_DAY_OF_WEEK dow = (ENUM_DAY_OF_WEEK)day;

   // Trade sessions
   for(int i = 0; i < InpMaxSessionsPerDay; i++)
   {
      datetime from = 0, to = 0;
      ResetLastError();
      if(!SymbolInfoSessionTrade(symbol, dow, (uint)i, from, to))
      {
         // No more sessions for this day.
         break;
      }
      EmitLine(fh, StringFormat("TRADE %s #%d %s-%s", DayName(day), i, TimeStr(from), TimeStr(to)));
   }

   // Quote sessions (can differ)
   for(int i = 0; i < InpMaxSessionsPerDay; i++)
   {
      datetime from = 0, to = 0;
      ResetLastError();
      if(!SymbolInfoSessionQuote(symbol, dow, (uint)i, from, to))
      {
         break;
      }
      EmitLine(fh, StringFormat("QUOTE %s #%d %s-%s", DayName(day), i, TimeStr(from), TimeStr(to)));
   }
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
      fh = FileOpen(InpOutFile, FILE_WRITE | FILE_TXT | FILE_COMMON | FILE_ANSI);
      if(fh == INVALID_HANDLE)
         PrintFormat("[SESSIONS] FileOpen(FILE_COMMON,%s) failed err=%d", InpOutFile, GetLastError());
   }

   EmitLine(fh, StringFormat("symbol=%s", symbol));
   EmitLine(fh, StringFormat("server_time=%s", TimeToString((datetime)TimeTradeServer(), TIME_DATE|TIME_SECONDS)));

   // Day parameter is 0..6 (Sun..Sat).
   for(int day = 0; day <= 6; day++)
      DumpSessionsForDay(fh, symbol, day);

   if(fh != INVALID_HANDLE)
   {
      FileClose(fh);
      PrintFormat("[SESSIONS] Wrote FILE_COMMON: %s", InpOutFile);
   }
}
