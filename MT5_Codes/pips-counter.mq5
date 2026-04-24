//+------------------------------------------------------------------+
//|                        DailyClosedPL_PointsAndMoney_EURUSD.mq5  |
//|       Shows today's closed EURUSD trades P/L in points and money|
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_plots 0
#property strict

#import "shell32.dll" 
int ShellExecuteW(int handle, string operation, string file, string parameters, string directory, int showCmd); 
#import

datetime weekStart = 0, dayStart = 0;

string weekLabel = "weekly";
string dayLabel = "daily";
string tradeCountLabel = "trades";

string labelW = "W";
string labelD = "D";
string labelT = "T";

string path = "C:/Program Files/Octa Markets MetaTrader 5/MQL5/Indicators/My Indicators/Helpers/";

double wPips = 0, wMoney = 0, dPips = 0, dMoney = 0;
int deals = 0, dealsCounter = 0, dailyDeals = 0, tradecount = 0, result = 100;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(_Symbol != "EURUSD")
     {
      Print("This indicator is only for EURUSD chart.");
      return INIT_FAILED;
     }
   
   ObjectCreate(0, labelW, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, labelW, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, labelW, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, labelW, OBJPROP_XDISTANCE, 250);
   ObjectSetInteger(0, labelW, OBJPROP_YDISTANCE, 1);
   ObjectSetInteger(0, labelW, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, labelW, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, labelW, OBJPROP_TEXT, "Weekly:");
   ObjectSetInteger(0, labelW, OBJPROP_COLOR, clrWhite);

   ObjectCreate(0, labelD, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, labelD, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, labelD, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, labelD, OBJPROP_XDISTANCE, 250);
   ObjectSetInteger(0, labelD, OBJPROP_YDISTANCE, 25);
   ObjectSetInteger(0, labelD, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, labelD, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, labelD, OBJPROP_TEXT, "Daily:");
   ObjectSetInteger(0, labelD, OBJPROP_COLOR, clrWhite);
   
   ObjectCreate(0, labelT, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, labelT, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, labelT, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, labelT, OBJPROP_XDISTANCE, 360);
   ObjectSetInteger(0, labelT, OBJPROP_YDISTANCE, 1);
   ObjectSetInteger(0, labelT, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, labelT, OBJPROP_SELECTABLE, false);
   ObjectSetString(0, labelT, OBJPROP_TEXT, "Trades Taken:");
   ObjectSetInteger(0, labelT, OBJPROP_COLOR, clrWhite);

   ObjectCreate(0, weekLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, weekLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, weekLabel, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, weekLabel, OBJPROP_XDISTANCE, 2);
   ObjectSetInteger(0, weekLabel, OBJPROP_YDISTANCE, 1);
   ObjectSetInteger(0, weekLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, weekLabel, OBJPROP_SELECTABLE, false);

   ObjectCreate(0, dayLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, dayLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, dayLabel, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, dayLabel, OBJPROP_XDISTANCE, 2);
   ObjectSetInteger(0, dayLabel, OBJPROP_YDISTANCE, 25);
   ObjectSetInteger(0, dayLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, dayLabel, OBJPROP_SELECTABLE, false);
   
   ObjectCreate(0, tradeCountLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_XDISTANCE, 340);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_YDISTANCE, 1);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_SELECTABLE, false);

   checkWeekandDayStart();
   checkOnce();
   UpdateLabel();

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, weekLabel);
   ObjectDelete(0, dayLabel);
   ObjectDelete(0, tradeCountLabel);
   ObjectDelete(0, labelW);
   ObjectDelete(0, labelD);
   ObjectDelete(0, labelT);
   EventKillTimer();
  }
  
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spreads[])
  {
   
   HistorySelect(dayStart, TimeCurrent());
   deals = HistoryDealsTotal();
   
   if(dealsCounter != deals)
     {
      dealsCounter = deals;
      CalculatePipsandMoney(deals);
      UpdateLabel();
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate closed trade stats: points and money                   |
//+------------------------------------------------------------------+
void CalculatePipsandMoney(int newDeal)
  {
   ulong ticket = HistoryDealGetTicket(newDeal-1);

   //--- Trade Started
   long entryType = HistoryDealGetInteger(ticket, DEAL_ENTRY);
   if(entryType == DEAL_ENTRY_IN) //--- || !entryType || 0 == Trade taken
     {
      tradecount++;
      
      //--- Run External Programs to remind me for --- TRADES COUNT ---
      if(tradecount < 8)
        {         
         if(tradecount > 3)
            result = ShellExecuteW(0, "open", path+IntegerToString(tradecount)+"thTrade.exe", "" , NULL, 1);
         
         if(tradecount == 3)
            result = ShellExecuteW(0, "open", path+"3rdTrade.exe", "" , NULL, 1);
            
         if (result <= 32) 
            Alert("Shell Execute Failed: Could not able to launch : EXE Program no: "+IntegerToString(tradecount), result);
        }
         
      else
         closeTrading();
      
      return;
     }
   
   //--- Trade Closed
   double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
   double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

   wMoney += profit;
   wPips += profit/volume;
   
   dMoney += profit;
   dPips += profit/volume;
   
   if(dPips < -199)
      closeTrading();
     
   else
      PlaySound("Harp.wav");
  }
//+------------------------------------------------------------------+
//| Update label text and color                                      |
//+------------------------------------------------------------------+
void UpdateLabel()
  {
   //--- string text = StringFormat("Today's P/L: %.0f pips | %.2f %s", points, money, AccountInfoString(ACCOUNT_CURRENCY));
   color accTrades = tradecount < 4 ? clrTurquoise : clrLightSalmon;
   
   ObjectSetString(0, weekLabel, OBJPROP_TEXT, (string)NormalizeDouble(wPips,1)+" pips | "+(string)NormalizeDouble(wMoney,1)+" $");
   ObjectSetInteger(0, weekLabel, OBJPROP_COLOR, wMoney >= 0.0 ? clrTurquoise : clrLightSalmon);

   ObjectSetString(0, dayLabel, OBJPROP_TEXT, (string)NormalizeDouble(dPips,1)+" pips | "+(string)NormalizeDouble(dMoney,1)+" $");
   ObjectSetInteger(0, dayLabel, OBJPROP_COLOR, dMoney >= 0.0 ? clrTurquoise : clrLightSalmon);
   
   ObjectSetString(0, tradeCountLabel, OBJPROP_TEXT, (string)tradecount);
   ObjectSetInteger(0, tradeCountLabel, OBJPROP_COLOR, tradecount < 6 ? accTrades : clrRed);
  }

//+------------------------------------------------------------------+

void checkWeekandDayStart()
  {
   string todayDate = TimeToString(TimeCurrent(),TIME_DATE);
   datetime tempDate = StringToTime(todayDate+" 01:30:00");
   dayStart = tempDate;
   MqlDateTime startofWeek;
   for(int i=0; i<5; i++)
     {
      TimeToStruct(tempDate,startofWeek);
      if(startofWeek.day_of_week == 1)
        {
         weekStart = tempDate;
         break;
        }
      tempDate -= 86400;
     }
  }

//+------------------------------------------------------------------+

void checkOnce()
  {
   HistorySelect(weekStart, TimeCurrent());
   deals = HistoryDealsTotal();
   calculateDeals(deals,1);   //--- Calculates Weekly Deals

   HistorySelect(dayStart, TimeCurrent());
   deals = HistoryDealsTotal();
   calculateDeals(deals,0);   //--- Calculates Daily Deals

   dealsCounter = deals;   //--- Captures Daily Deals
  }

//+------------------------------------------------------------------+

void calculateDeals(int dealsGot, int x)
  {
   for(int i = dealsGot-1; i > 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);

      //--- Trade Closed
      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(!entry /* Entry trades only */)
        {
         if(!x) //--- For day trades only
            tradecount++;
         continue;
        }

      double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

      if(x) //--- Weekly Counter
        {
         wMoney += profit;
         wPips += profit/volume;
        }
      else //--- Dialy Counter
        {
         dMoney += profit;
         dPips += profit/volume;
        }
     }
     
    if(dPips < -199 || tradecount > 8)
      closeTrading();
  }
//+------------------------------------------------------------------+

void closeTrading()
  {
   PlaySound("Classic3long.wav");
      
   //--- Run External Program "OverTrading.exe" to remind me --- DO NOT TRADE MORE ---
   if(tradecount > 7)
      result = ShellExecuteW(0, "open", path+"OverTrading.exe", "" , NULL, 1);
   
   //--- Run External Program "LostTooMuch.exe" to remind me --- I have lost too much --- do not take more trades and close the terminal.
   else if(dPips < -199)
      result = ShellExecuteW(0, "open", path+"LostTooMuch.exe", "" , NULL, 1);
   
   if (result <= 32)
      Alert("Shell Execute Failed: Could not able to launch EXE Program: OverTrading.exe/LostTooMuch.exe", result);
      
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrMaroon);
  }

//+------------------------------------------------------------------+