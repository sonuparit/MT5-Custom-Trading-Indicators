#property strict
#property indicator_chart_window
#property indicator_plots 0;

ENUM_BASE_CORNER Corner = CORNER_RIGHT_UPPER;
ENUM_ANCHOR_POINT Anchor = ANCHOR_RIGHT_UPPER;

input bool showAskBid = true; //--- Show AskLine and BidLine
input int alertSec = 20;      //--- Adv alert seconds

string cTimerButton = "candleTimerButton";
string pSpreadLabel = "pairSpreadLabel";
string cTimer = "candleTimer";
string pSpread = "pairSpread";
                  
long spread = 10;

datetime Spread_Timer = TimeCurrent();
datetime candleTimer = 0;

bool chartColorChanged = false;
bool timerRunning = false;
bool itsFirstTime = true;

int mins = 0;

string Color_Options[] = {"Magenta","Aqua","Yellow","FlatLines","RemoveSelection","SelectAll"};
string Color_Text[] = {"Res","Sup","Un-C","SFL","Rem","Sel"};
color Text_Color[] = {clrWhite,clrBlack,clrBlack,clrWhite,clrWhite,clrWhite};
color borderColor[] = {clrWhite,clrWhite,clrRed,clrWhite,clrAqua,clrMagenta};
color Color_Selected[] = {clrMagenta,clrAqua,clrYellow,clrBlack,clrBlack,clrBlack};
string Color_Tooltip[] = {"Resistance","Support","Un-Confirmed-Line","Select Flat Lines","Remove Selection","Select All"};
int xdis[] = {208,176,144};

string obj_names[20];
color obj_color = clrYellow;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- Indicator Corner default to Right Upper

    //---Show/Hide the Ask and Bid Line
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,showAskBid);
   ChartSetInteger(0,CHART_SHOW_BID_LINE,showAskBid);
   
   if(Period() == PERIOD_M1)
     {
      int xOffset = 98;
      for(int i=0;i<3;i++)
        {
         xdis[i] = xOffset;
         xOffset -= 32;
        }
     }
   else
     {
      //--- Creates Candle Timer label 1
      ObjectCreate(0, cTimerButton, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, cTimerButton, OBJPROP_ANCHOR, Anchor);
      ObjectSetInteger(0, cTimerButton, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, cTimerButton, OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(0, cTimerButton, OBJPROP_XDISTANCE, 108);
      ObjectSetInteger(0, cTimerButton, OBJPROP_YDISTANCE, 2);
      ObjectSetInteger(0, cTimerButton, OBJPROP_XSIZE, 45);
      ObjectSetInteger(0, cTimerButton, OBJPROP_YSIZE, 18);
      ObjectSetInteger(0, cTimerButton, OBJPROP_BORDER_COLOR, clrWhite);
      ObjectSetInteger(0, cTimerButton, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, cTimerButton, OBJPROP_FONTSIZE, 7);
      ObjectSetString(0, cTimerButton, OBJPROP_TOOLTIP, "Timer Not Running");
      ObjectSetString(0,cTimerButton,OBJPROP_TEXT,"Timer");
      
      //--- Creates Spread label 1
      ObjectCreate(0, pSpreadLabel, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_ANCHOR, Anchor);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_XDISTANCE, 45);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_YDISTANCE, 22);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, pSpreadLabel, OBJPROP_COLOR, clrWhite);
      ObjectSetString(0,pSpreadLabel,OBJPROP_TEXT,"Spread : ");
      
      //--- Creates Candle Timer label 2
      ObjectCreate(0, cTimer, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, cTimer, OBJPROP_ANCHOR, Anchor);
      ObjectSetInteger(0, cTimer, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, cTimer, OBJPROP_XDISTANCE, 2);
      ObjectSetInteger(0, cTimer, OBJPROP_YDISTANCE, 0);
      ObjectSetInteger(0, cTimer, OBJPROP_FONTSIZE, 10);
      
      //--- Creates Spread label 2
      ObjectCreate(0, pSpread, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, pSpread, OBJPROP_ANCHOR, Anchor);
      ObjectSetInteger(0, pSpread, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, pSpread, OBJPROP_XDISTANCE, 2);
      ObjectSetInteger(0, pSpread, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, pSpread, OBJPROP_FONTSIZE, 9);
     }

//--- Draw Color palletes
   int c=0;
   for(int i=0; i<6; i+=2)
     {
      ObjectCreate(0, Color_Options[i], OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_BGCOLOR, Color_Selected[i]);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_XDISTANCE, xdis[c]);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_YDISTANCE, 2);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_XSIZE, 30);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_YSIZE, 18);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_FONTSIZE, 5);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_BORDER_COLOR, borderColor[i]);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_COLOR, Text_Color[i]);
      ObjectSetString(0, Color_Options[i], OBJPROP_TOOLTIP, Color_Tooltip[i]);
      ObjectSetString(0, Color_Options[i], OBJPROP_TEXT, Color_Text[i]);
      c++;
     }
   c=0;
   for(int i=1; i<6; i+=2)
     {
      ObjectCreate(0, Color_Options[i], OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_XDISTANCE, xdis[c]);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_YDISTANCE, 22);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_XSIZE, 30);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_YSIZE, 18);
      ObjectSetInteger(0, Color_Options[i], OBJPROP_FONTSIZE, 5);
      if(Period() != PERIOD_M1 && i == 5)
        {
         ObjectSetInteger(0, Color_Options[i], OBJPROP_BGCOLOR, clrGray);
         ObjectSetInteger(0, Color_Options[i], OBJPROP_BORDER_COLOR, clrGray);
         ObjectSetString(0, Color_Options[i], OBJPROP_TOOLTIP, "Disabled");
        }
      else
        {
         ObjectSetInteger(0, Color_Options[i], OBJPROP_BGCOLOR, Color_Selected[i]);
         ObjectSetInteger(0, Color_Options[i], OBJPROP_BORDER_COLOR, borderColor[i]);
         ObjectSetInteger(0, Color_Options[i], OBJPROP_COLOR, Text_Color[i]);
         ObjectSetString(0, Color_Options[i], OBJPROP_TOOLTIP, Color_Tooltip[i]);
         ObjectSetString(0, Color_Options[i], OBJPROP_TEXT, Color_Text[i]);
        }
      c++;
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0; i<6; i++)
      ObjectDelete(0, Color_Options[i]);
      
   ObjectDelete(0, cTimerButton);
   ObjectDelete(0, cTimer);
   ObjectDelete(0, pSpreadLabel);
   ObjectDelete(0, pSpread);
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
   //--- Get Market Spread
   spread=SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   
   //--- Change background of the chart to maroon is spread is more than 11
   if(spread > 14 && TimeCurrent() > Spread_Timer)
     {
      if(Period() == PERIOD_M1)
         PlaySound("Glow.wav");
         
      ChartSetInteger(0,CHART_COLOR_BACKGROUND, clrMaroon);
      chartColorChanged = true;
      Spread_Timer = TimeCurrent()+180;
     }
   
   //--- Restore the chart background to black if spread is less than 12
   if(chartColorChanged && spread < 15)
     {
      PlaySound("Guitar.wav");
      ChartSetInteger(0,CHART_COLOR_BACKGROUND, clrBlack);
      chartColorChanged = false;
     }
   
   if(Period() != PERIOD_M1)
     {
      //--- Set Array as Series
      ArraySetAsSeries(time, true);
      
      //--- Candle timer calculations
      mins = int(time[0]+PeriodSeconds()-TimeCurrent());
      int s = mins % 60;
      int m = mins / 60;
      string _m = "", _s = "";
      if(m < 10) _m = "0";
      if(s < 10) _s = "0";
      
      //--- Update the timer
      ObjectSetString(0, cTimer, OBJPROP_TEXT,_m+IntegerToString(m)+":"+_s+IntegerToString(s));
      
      if(!timerRunning)
         ObjectSetInteger(0,cTimer, OBJPROP_COLOR, m > 0 ? clrAqua : clrLightSalmon);
      else
        {
         if(mins < alertSec)
           {         
            ObjectSetString(0, cTimerButton, OBJPROP_TEXT, "Timer");
            ObjectSetInteger(0, cTimerButton, OBJPROP_BGCOLOR, clrBlack);
            ObjectSetString(0, cTimerButton, OBJPROP_TOOLTIP, "Timer Not Running");
            PlaySound("Classic3.wav");
            timerRunning = false;
           }
        }
      
      //--- Update the spread
      ObjectSetString(0, pSpread, OBJPROP_TEXT,IntegerToString(spread));
      ObjectSetInteger(0,pSpread, OBJPROP_COLOR, spread < 12 ? clrAqua : clrLightSalmon);
     }
     
   if(Period() == PERIOD_M15)
     {
      if((time[0] + 840) < TimeCurrent() && candleTimer < TimeCurrent())
        {
         //Only for 15M and above timeframes - Not for 5M or 1M timeframes
         candleTimer = TimeCurrent() + 120;
         if(!itsFirstTime)
            Alert("Check Charts for Trends, Flats, Tops, Bottoms etc");
         itsFirstTime = false;
        }
     }
   
   return(rates_total);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   long cId = ChartID();
   int n = ObjectsTotal(cId,0);
   int h = ObjectsTotal(cId, 0, OBJ_HLINE);
   
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == cTimerButton)
     {
      if(!timerRunning)
        {
         timerRunning = true;
         ObjectSetString(0, cTimerButton, OBJPROP_TEXT, "Runn..");
         ObjectSetInteger(0, cTimerButton, OBJPROP_BGCOLOR, C'120,0,0');
         ObjectSetString(0, cTimerButton, OBJPROP_TOOLTIP, "Timer Running");
         ObjectSetInteger(0,cTimer, OBJPROP_COLOR, clrRed);
         ChartRedraw();
        }
      else
        {
         timerRunning = false;
         ObjectSetString(0, cTimerButton, OBJPROP_TEXT, "Timer");
         ObjectSetInteger(0, cTimerButton, OBJPROP_BGCOLOR, clrBlack);
         ObjectSetString(0, cTimerButton, OBJPROP_TOOLTIP, "Timer Not Running");
         ChartRedraw();
        }
     }
    
   if(id == CHARTEVENT_OBJECT_CLICK && (sparam == "SelectAll" || sparam == "RemoveSelection"))
     {
      bool value = Period() == PERIOD_M1 ? true : false;
      for(int i=0; i<n; ++i)
        {
         string name = ObjectName(cId, i, 0);
         ObjectSetInteger(cId,name,OBJPROP_SELECTED, sparam == "SelectAll" ? value : false);
        }
      ChartRedraw();
     }
     
   else if(id == CHARTEVENT_OBJECT_CLICK && sparam == "FlatLines")
     {
      for(int i=0; i<h; ++i)
        {
         //--- hLine Found now get its Name and Color
         string name = ObjectName(cId, i, 0, OBJ_HLINE);
         long hLineColor = ObjectGetInteger(cId,name,OBJPROP_COLOR);

         //--- If hLine color is DarkSlateGray or Maroon do the following
         if(hLineColor == clrDarkSlateGray || hLineColor == clrMaroon)
            ObjectSetInteger(cId,name,OBJPROP_SELECTED, true);
        }
      ChartRedraw();
     }
     
   else
     {
      for(int j=0; j<3; j++)  //--- Number of Colors = Color_Options - 3
        {
         if(id == CHARTEVENT_OBJECT_CLICK && sparam == Color_Options[j])
           {
            int found = 0;
            for(int i=0; i<n; ++i)
              {
               string name = ObjectName(cId, i, 0);
               bool selected = ObjectGetInteger(cId, name, OBJPROP_SELECTED);
               if(selected)
                 {
                  obj_names[found] = name;
                  ++found;
                  ObjectSetInteger(cId, name, OBJPROP_COLOR, Color_Selected[j]);
                  ObjectSetInteger(cId, name, OBJPROP_SELECTED, false); 
                 }
              }
            if(found>0)
              {
               long cId = ChartFirst();
               while(cId != -1)
                 {
                  const int win = (int)ChartGetInteger(cId, CHART_WINDOWS_TOTAL);
                  for(int k=0; k<win; ++k)
                    {
                     const int n = ObjectsTotal(cId, k);
                     for(int i=0; i<n; ++i)
                       {
                        const string name = ObjectName(cId, i, k);
                        for(int c=0; c<found; c++)
                          {
                           if(name == obj_names[c])
                             {
                              ObjectSetInteger(cId, name, OBJPROP_COLOR, Color_Selected[j]);
                              ObjectSetInteger(cId, name, OBJPROP_SELECTED, false);
                             }
                          }
                       }
                    }
                  ChartRedraw(cId);  
                  cId = ChartNext(cId);
                 }
              }
            ChartRedraw();
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
