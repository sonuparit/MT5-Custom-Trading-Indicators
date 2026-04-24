//+------------------------------------------------------------------+
//|                                                        trend.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#property strict

//--- Button name
string objname = "alertButton";

input bool testing = false;
input double sensitivity = 0.00002;       //--- Proximity of Alert
input double alertLevel = 0.00040;        //--- Alert Level
input long tillTime = 10800;              //--- 3 hours Till Time

//--- To get the S/R Lines
string whatLine[30];
string whatRect[30];

//--- store hLines Names
string hLineNames[30];

//--- To store S/R Line Prices
double hLinePrice[30];
double rectPrices[30];

//--- To get Alert only once
int indexofH[30] = { 99,99,99,99,99,99,99,99,99,99,
                     99,99,99,99,99,99,99,99,99,99,
                     99,99,99,99,99,99,99,99,99,99
                   };
                   
int indexofR[30] = { 99,99,99,99,99,99,99,99,99,99,
                     99,99,99,99,99,99,99,99,99,99,
                     99,99,99,99,99,99,99,99,99,99
                   };

//--- To get Alert only once per candle
datetime candleTimer = 0;

//--- To alert (False Alert/True Alert)
bool alerting = false;
bool hunch = false;
bool updateFast[30];

//--- To save alerts
int hKey = 0;
int rKey = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Indicator name ---//
   IndicatorSetString(INDICATOR_SHORTNAME,"TradeAlert");

   //--- Create an Alert Button
   ObjectCreate(0, objname, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, objname, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, objname, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, objname, OBJPROP_BGCOLOR, C'0,80,0');
   ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, Period() == PERIOD_M1 ? 162 : 272);
   ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, 2);
   ObjectSetInteger(0, objname, OBJPROP_XSIZE, 62);
   ObjectSetInteger(0, objname, OBJPROP_YSIZE, 18);
   ObjectSetInteger(0, objname, OBJPROP_BORDER_COLOR, clrWhite);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, objname, OBJPROP_FONTSIZE, 6);
   ObjectSetString(0, objname, OBJPROP_TOOLTIP, "Alerts Not Running");
   ObjectSetString(0, objname, OBJPROP_TEXT, "Alert");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,objname);
   deleteAlert(hKey);
   deleteRect(rKey);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
     
   if(!testing && alerting)
     {
      double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      
      //--- Alert 1
      if(Period() == PERIOD_M1)
        {
         for(int i=0; i<hKey; i++)
           {
            if(indexofH[i] != i && whatLine[i] == "green")
              {
               if(bid < hLinePrice[i])
                 {
                  indexofH[i] = i;
                  PlaySound("alert2.wav");
                 }
              }
            if(indexofH[i] != i && whatLine[i] == "red")
              {
               if(bid > hLinePrice[i])
                 {
                  indexofH[i] = i;
                  PlaySound("Bells3.wav");
                 }
              }   
           }
        }
      else
        {
         ArraySetAsSeries(time, true);
         
         if(time[0] != candleTimer)
           {
            candleTimer = time[0];
            
            ArraySetAsSeries(open, true);
            ArraySetAsSeries(close, true);
            ArraySetAsSeries(low, true);
            ArraySetAsSeries(high, true);
              
            //--- Alert 2
            for(int i=0; i<hKey; i++)
              {
               if(indexofH[i] != i && whatLine[i] == "green")
                 {
                  if(low[2] <= hLinePrice[i] || low[1] <= hLinePrice[i])
                    {
                     if(open[1] < close[1])     //--- Green Candle
                       {
                        indexofH[i] = i;
                        PlaySound("alert2.wav");
                       }
                        
                    }
                 }
               if(indexofH[i] != i && whatLine[i] == "red")
                 {
                  if(high[2] >= hLinePrice[i] || high[1] >= hLinePrice[i])
                    {
                     if(open[1] > close[1])     //--- Red Candle
                       {
                        indexofH[i] = i;
                        PlaySound("Bells3.wav");
                       }
                    }
                 }   
              }
           }
        }
      
      //--- Alert for INVALID market directions
      for(int i=0; i<rKey; i++)
        {
         if(indexofR[i] != i)
           {
            //--- Alert to drop the up trades
            if(whatRect[i] == "green" && bid < rectPrices[i])
              {
               indexofR[i] = i; //--- Alert only once
               fadeRect(i);
              }
              
            //--- Alert to drop the down trades
            else if(whatRect[i] == "red" && bid > rectPrices[i])
              {
               indexofR[i] = i; //--- Alert only once
               fadeRect(i);
              }
           }
        }
     }
     
   //--- return value of prev_calculated for next call
   return(rates_total);
  }
  
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == objname)
     {
      if(!alerting && !hunch)
        {
         hunch = true;
         ObjectSetString(0, objname, OBJPROP_TEXT, "-----");
         ObjectSetInteger(0, objname, OBJPROP_BGCOLOR, C'0,0,0');
         long Cid = ChartID();
         
         //--- Select "Object Arrow Left Price" and process them on the basis of color
         int objArrowLeftPrice = ObjectsTotal(Cid, 0, OBJ_ARROW_LEFT_PRICE);
         for(int i=0; i<objArrowLeftPrice; i++)
           {
            //--- hLine Found now get its Name and Color
            string name = ObjectName(Cid, i, 0, OBJ_ARROW_LEFT_PRICE);
            long arrowColor = ObjectGetInteger(Cid,name,OBJPROP_COLOR);
            
            //--- If hLine color is Cyan or Magenta do the following
            if(arrowColor == clrAqua || arrowColor == clrMagenta)
              {
               //--- Get arrow price
               double arrowPrice = ObjectGetDouble(Cid,name,OBJPROP_PRICE,0);
               long arrowTime = ObjectGetInteger(Cid,name,OBJPROP_TIME,0);
               long timeGap = 0;    //20 Mins
               
               int arrowLPBIndex = iBarShift(NULL,PERIOD_CURRENT,arrowTime);
               if(arrowColor == clrAqua)
                 {
                  ObjectCreate(0,"rect"+IntegerToString(rKey),OBJ_RECTANGLE,0,arrowTime+timeGap,arrowPrice-0.00011,arrowTime+tillTime,arrowPrice+alertLevel);
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_FILL,true);
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_COLOR,C'0,60,60');
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_SELECTABLE,true);
                  
                  rectPrices[rKey] = arrowPrice-0.00011;
                  whatRect[rKey] = "green";
                  
                  if(!testing)
                    {
                     int lowestBarIndex = iLowest(NULL,PERIOD_CURRENT,MODE_LOW,arrowLPBIndex,0);
                     double barPrice = iLow(NULL,PERIOD_CURRENT,lowestBarIndex);
                     if(barPrice < rectPrices[rKey])
                       {
                        indexofR[rKey] = rKey;
                        fadeRect(rKey);
                       }
                    }
                 }
                 
               else
                 {
                  ObjectCreate(0,"rect"+IntegerToString(rKey),OBJ_RECTANGLE,0,arrowTime+timeGap,arrowPrice+0.00023,arrowTime+tillTime,arrowPrice-alertLevel);
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_FILL,true);
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_COLOR,C'80,0,0');
                  ObjectSetInteger(0,"rect"+IntegerToString(rKey),OBJPROP_SELECTABLE,true);
                  
                  rectPrices[rKey] = arrowPrice+0.00011;
                  whatRect[rKey] = "red";
                  
                  if(!testing)
                    {
                     int highestBarIndex = iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,arrowLPBIndex,0);
                     double barPrice = iHigh(NULL,PERIOD_CURRENT,highestBarIndex);
                     if(barPrice > rectPrices[rKey])
                       {
                        indexofR[rKey] = rKey;
                        fadeRect(rKey);
                       }
                    }
                 }               
               rKey++;
              }
           }
         
         //--- Select "Horizontal Lines" and process them on the basis of color
         int objHLine = ObjectsTotal(Cid, 0, OBJ_HLINE);
         for(int i=0; i<objHLine; i++)
           {
            //--- hLine Found now get its Name and Color
            string name = ObjectName(Cid, i, 0, OBJ_HLINE);
            long hLineColor = ObjectGetInteger(Cid,name,OBJPROP_COLOR);

            //--- If hLine color is clrAqua or Magenta do the following
            if(hLineColor == clrAqua || hLineColor == clrMagenta)
              {
               //--- Alerting
               alerting = true;
               
               //--- Get hLine price
               double hPrice = ObjectGetDouble(Cid,name,OBJPROP_PRICE,0);
               ObjectSetString(0,name,OBJPROP_TOOLTIP,"Alerting");

               if(hLineColor == clrAqua)
                 {
                  whatLine[hKey] = "green";
                  hLinePrice[hKey] = hPrice+sensitivity;
                 }
                 
               else
                 {
                  whatLine[hKey] = "red";
                  hLinePrice[hKey] = hPrice-sensitivity;
                 }
                 
               //--- store hline Names
               hLineNames[hKey] = name;
               hKey++;
              }
           }
           
         if(alerting)
           {
            ObjectSetString(0, objname, OBJPROP_TEXT, "Reset");
            ObjectSetInteger(0, objname, OBJPROP_BGCOLOR, C'120,0,0');
            ObjectSetString(0, objname, OBJPROP_TOOLTIP, "Alerts Running");
           }
        }
     
      else
        {
         //--- Reset the Alerts
         alerting = hunch = false;
         
         //--- delete all alerts
         deleteAlert(hKey);
         
         //--- delete all Rectangles
         deleteRect(rKey);
         
         //--- Reset the button and Alert visuals
         long Cid = ChartID();
         int objHLine = ObjectsTotal(Cid, 0, OBJ_HLINE);
         for(int i=0; i<objHLine; i++)
           {
            string name = ObjectName(Cid, i, 0, OBJ_HLINE);
            ObjectSetString(0,name,OBJPROP_TOOLTIP,name);
           }
         
         ObjectSetString(0, objname, OBJPROP_TEXT, "Alert");
         ObjectSetInteger(0, objname, OBJPROP_BGCOLOR, C'0,80,0');
         ObjectSetString(0, objname, OBJPROP_TOOLTIP, "Alerts Not Running");
        }
     }
   ChartRedraw();
  }
  
//+------------------------------------------------------------------+

void fadeRect(int x)
  {
   ObjectSetInteger(0,"rect"+IntegerToString(x),OBJPROP_COLOR,C'100,100,100');
   PlaySound("expert.wav");
   
  }
  
//+------------------------------------------------------------------+

void deleteRect(int x)
  {
   for(int i=0; i<x; i++)
     {
      indexofR[i] = 99;
      ObjectDelete(0,"rect"+IntegerToString(i));
     }
     
   rKey = 0;
  }
  
//+------------------------------------------------------------------+

void deleteAlert(int x)
  {
   for(int i=0; i<x; i++)
      indexofH[i] = 99;
      
   hKey = 0;
  }
  
//+------------------------------------------------------------------+