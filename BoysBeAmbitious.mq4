//+------------------------------------------------------------------+
//|                                              BoysBeAmbitious.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- input parameters
input bool     London_Summer_Time=True;
input bool     NewYork_Summer_Time=True;

input double   Loss_Cut=5.0;

input color    LC_Color=clrWhite;
input int      LC_Width=2;
input int      LC_Style=STYLE_SOLID;

input color    Round_Color=clrCyan;
input int      Round_Width=1;
input int      Round_Style=STYLE_DASHDOT;

input color    LW_High_Color=clrMagenta;
input int      LW_High_Width=1;
input int      LW_High_Style=STYLE_DASH;
input color    LW_Low_Color=clrMagenta;
input int      LW_Low_Width=1;
input int      LW_Low_Style=STYLE_DASH;

input color    High_Color=clrYellow;
input int      High_Width=1;
input int      High_Style=STYLE_DASH;
input color    Low_Color=clrYellow;
input int      Low_Width=1;
input int      Low_Style=STYLE_DASH;

input color    Close_Color=clrYellow;
input int      Close_Width=1;
input int      Close_Style=STYLE_DASHDOTDOT;
input color    Open_Color=clrYellow;
input int      Open_Width=1;
input int      Open_Style=STYLE_DASHDOTDOT;

input bool     Live_SMA=True;
input color    SMA5_Color=clrLime;
input int      SMA5_Width=1;
input int      SMA5_Style=STYLE_DOT;
input color    SMA25_Color=clrLime;
input int      SMA25_Width=1;
input int      SMA25_Style=STYLE_DOT;
input color    SMA75_Color=clrLime;
input int      SMA75_Width=1;
input int      SMA75_Style=STYLE_DOT;
input color    SMA200_Color=clrLime;
input int      SMA200_Width=1;
input int      SMA200_Style=STYLE_DOT;

input color    Tokyo_Open_Color=clrAqua;
input int      Tokyo_Open_Width=1;
input int      Tokyo_Open_Style=STYLE_DASH;
input color    London_Open_Color=clrAqua;
input int      London_Open_Width=1;
input int      London_Open_Style=STYLE_DASH;
input color    NewYork_Open_Color=clrAqua;
input int      NewYork_Open_Width=1;
input int      NewYork_Open_Style=STYLE_DASH;

input color    Tokyo_Close_Color=clrMagenta;
input int      Tokyo_Close_Width=1;
input int      Tokyo_Close_Style=STYLE_DOT;
input color    London_Close_Color=clrMagenta;
input int      London_Close_Width=1;
input int      London_Close_Style=STYLE_DOT;
input color    NewYork_Close_Color=clrMagenta;
input int      NewYork_Close_Width=1;
input int      NewYork_Close_Style=STYLE_DOT;

input color    Market_Color=clrWhite;
input int      Market_Width=1;
input int      Market_Style=STYLE_DASHDOT;


double basejpy;
double lotSize;

double tokyoHigh;
double tokyoLow;

double londonHigh;
double londonLow;

#define  HR2400 86400       // 24 * 3600
int      TimeOfDay(datetime when){  return( when % HR2400          );         }
datetime DateOfDay(datetime when){  return( when - TimeOfDay(when) );         }
datetime Today(){                   return(DateOfDay( TimeCurrent() ));       }
datetime Tomorrow(){                return(Today() + HR2400);                 }
datetime Yesterday(int shift){      return( iTime(NULL, PERIOD_D1, shift) );  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void drawHLine(string id, double pos, color clr, int width, int style, string label, bool selectable = false) {

  if(style < 0 || 4 < style) {
    style = 0;
  }
  if(width < 1) {
    width = 1;
  }

  ObjectCreate(id, OBJ_HLINE, 0, 0, pos);
  ObjectSet(id, OBJPROP_COLOR, clr);
  ObjectSet(id, OBJPROP_WIDTH, width);
  ObjectSet(id, OBJPROP_STYLE, style);
  ObjectSet(id, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  
  ObjectSetInteger(0, id, OBJPROP_SELECTABLE, selectable);
  ObjectSetText(id, label, 12, "Arial", clr);
}

void drawRound() {

  for(int i = 0; i < 11; i++) {
    string rid = "round";
    double pos = MathRound(Bid * MathPow(10, Digits - 3)) / MathPow(10, Digits - 3) + double(i - 5) * 1000.0 * Point;

    ObjectCreate(rid + IntegerToString(i), OBJ_HLINE, 0, 0, pos);
    ObjectSet(rid + IntegerToString(i), OBJPROP_WIDTH, Round_Width);
    ObjectSet(rid + IntegerToString(i), OBJPROP_COLOR, Round_Color);
    ObjectSet(rid + IntegerToString(i), OBJPROP_STYLE, Round_Style);
    ObjectSet(rid + IntegerToString(i), OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  
    ObjectSetInteger(0, rid + IntegerToString(i), OBJPROP_SELECTABLE, false);
    ObjectSetText(rid + IntegerToString(i), DoubleToStr(pos, Digits - 3), 12, "Arial", Round_Color);
  }
}

void drawVLine(string id, string hour, string minute, color clr, int width, int style, string label) {

  if(style < 0 || 4 < style) {
    style = 0;
  }
  if(width < 1) {
    width = 1;
  }

  datetime time = StrToTime(TimeToStr(TimeCurrent(), TIME_DATE) + " " + hour + ":" + minute);

  ObjectCreate(id, OBJ_VLINE, 0, time, 0);
  ObjectSet(id, OBJPROP_WIDTH, width);
  ObjectSet(id, OBJPROP_COLOR, clr);
  ObjectSet(id, OBJPROP_STYLE, style);
  ObjectSet(id, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  
  ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
  ObjectSetText(id, label, 12, "Arial", clr);
  
  time = StrToTime(TimeToStr(Tomorrow(), TIME_DATE) + " " + hour + ":" + minute);

  ObjectCreate(id + " t", OBJ_VLINE, 0, time, 0);
  ObjectSet(id + " t", OBJPROP_WIDTH, width);
  ObjectSet(id + " t", OBJPROP_COLOR, clr);
  ObjectSet(id + " t", OBJPROP_STYLE, style);
  ObjectSet(id + " t", OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  
  ObjectSetInteger(0, id + "t", OBJPROP_SELECTABLE, false);
  ObjectSetText(id + "t", label, 12, "Arial", clr);
  
  for(int i = 0; i < 21; i++) {
    time = StrToTime(TimeToStr(Yesterday(i + 1), TIME_DATE) + " " + hour + ":" + minute);

    ObjectCreate(id + IntegerToString(i), OBJ_VLINE, 0, time, 0);
    ObjectSet(id + IntegerToString(i), OBJPROP_WIDTH, width);
    ObjectSet(id + IntegerToString(i), OBJPROP_COLOR, clr);
    ObjectSet(id + IntegerToString(i), OBJPROP_STYLE, style);
    ObjectSet(id + IntegerToString(i), OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
  
    ObjectSetInteger(0, id + IntegerToString(i), OBJPROP_SELECTABLE, false);
    ObjectSetText(id + IntegerToString(i), label, 12, "Arial", clr);
  }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

  ObjectDelete(0, "market high");
  ObjectDelete(0, "market low");

  ObjectDelete(0, "last week high");
  ObjectDelete(0, "last week low");

  ObjectDelete(0, "high");
  ObjectDelete(0, "low");
  ObjectDelete(0, "open");
  ObjectDelete(0, "close");

  ObjectDelete(0, "ma5");
  ObjectDelete(0, "ma25");
  ObjectDelete(0, "ma75");
  ObjectDelete(0, "ma200");

  ObjectDelete(0, "tokyo open");
  ObjectDelete(0, "tokyo close");
  ObjectDelete(0, "london open");
  ObjectDelete(0, "london close");
  ObjectDelete(0, "newyork open");
  ObjectDelete(0, "newyork close");

  ObjectDelete(0, "tokyo open t");
  ObjectDelete(0, "tokyo close t");
  ObjectDelete(0, "london open t");
  ObjectDelete(0, "london close t");
  ObjectDelete(0, "newyork open t");
  ObjectDelete(0, "newyork close t");

  for(int i = 0; i < 21; i++) {
    ObjectDelete(0, "tokyo open" + IntegerToString(i));
    ObjectDelete(0, "tokyo close" + IntegerToString(i));
    ObjectDelete(0, "london open" + IntegerToString(i));
    ObjectDelete(0, "london close" + IntegerToString(i));
    ObjectDelete(0, "newyork open" + IntegerToString(i));
    ObjectDelete(0, "newyork close" + IntegerToString(i));
  }

  for(int i = 0; i < 11; i++) {  
    string rid = "round";
    ObjectDelete(0, rid + IntegerToString(i));
  }
  
  ObjectDelete(0, "loss cut");
}
  
int OnInit()
  {
//--- indicator buffers mapping

  string base = StringSubstr(Symbol(), 3, 3);
  if(StringCompare(base, "JPY") != 0) {
    basejpy = (MarketInfo(base + "JPY", MODE_ASK) + MarketInfo(base + "JPY", MODE_BID)) / 2.0;
  }
  else {
    basejpy = 1.0;
  }

  lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);

  double lw_high = iHigh(Symbol(), PERIOD_W1, 1);
  double lw_low = iLow(Symbol(), PERIOD_W1, 1);
  
  int isLive = MarketInfo(Symbol(), MODE_TRADEALLOWED);
  
  double high = iHigh(Symbol(), PERIOD_D1, isLive);
  double low = iLow(Symbol(), PERIOD_D1, isLive);
  double open = iOpen(Symbol(), PERIOD_D1, isLive);
  double close = iClose(Symbol(), PERIOD_D1, isLive);
  
  if(Live_SMA) {
    isLive = 0;
  }

  double ma5 = iMA(Symbol(), PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma25 = iMA(Symbol(), PERIOD_D1, 25, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma75 = iMA(Symbol(), PERIOD_D1, 75, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma200 = iMA(Symbol(), PERIOD_D1, 200, 0, MODE_SMA, PRICE_CLOSE, isLive);

  drawHLine("last week high", lw_high, LW_High_Color, LW_High_Width, LW_High_Style, "Last Week High");
  drawHLine("last week low", lw_low, LW_Low_Color, LW_Low_Width, LW_Low_Style, "Last Week Low");

  drawHLine("high", high, High_Color, High_Width, High_Style, "Last Day High");
  drawHLine("low", low, Low_Color, Low_Width, Low_Style, "Last Day Low");
  drawHLine("open", open, Open_Color, Open_Width, Open_Style, "Last Day Open");
  drawHLine("close", close, Close_Color, Close_Width, Close_Style, "Last Day Close");
  drawHLine("ma5", ma5, SMA5_Color, SMA5_Width, SMA5_Style, "5 SMA");
  drawHLine("ma25", ma25, SMA25_Color, SMA25_Width, SMA25_Style, "25 SMA");
  drawHLine("ma75", ma75, SMA75_Color, SMA75_Width, SMA75_Style, "75 SMA");
  drawHLine("ma200", ma200, SMA200_Color, SMA200_Width, SMA200_Style, "200 SMA");
  
  drawRound();

  drawVLine("tokyo open", "03", "00", Tokyo_Open_Color, Tokyo_Open_Width, Tokyo_Open_Style, "Tokyo Open");
  drawVLine("tokyo close", "09", "00", Tokyo_Close_Color, Tokyo_Close_Width, Tokyo_Close_Style, "Tokyo Close");
  
  if(London_Summer_Time) {
    drawVLine("london open", "10", "00", London_Open_Color, London_Open_Width, London_Open_Style, "London Open");
    drawVLine("london close", "18", "30", London_Close_Color, London_Close_Width, London_Close_Style, "London Close");
  }
  else {
    drawVLine("london open", "11", "00", London_Open_Color, London_Open_Width, London_Open_Style, "London Open");
    drawVLine("london close", "19", "30", London_Close_Color, London_Close_Width, London_Close_Style, "London Close");
  }

  if(NewYork_Summer_Time) {
    drawVLine("newyork open", "16", "30", NewYork_Open_Color, NewYork_Open_Width, NewYork_Open_Style, "NewYork Open");
    drawVLine("newyork close", "23", "00", NewYork_Close_Color, NewYork_Close_Width, NewYork_Close_Style, "NewYork Close");
  }
  else {
    drawVLine("newyork open", "17", "30", NewYork_Open_Color, NewYork_Open_Width, NewYork_Open_Style, "NewYork Open");
    drawVLine("newyork close", "00", "00", NewYork_Close_Color, NewYork_Close_Width, NewYork_Close_Style, "NewYork Close");
  }

  drawHLine("market high", 0.0, Market_Color, Market_Width, Market_Style, "Market High");
  drawHLine("market low", 0.0, Market_Color, Market_Width, Market_Style, "Market Low");
  
  drawHLine("loss cut", (Ask + Bid) / 2.0, LC_Color, LC_Width, LC_Style, "LC: " + DoubleToStr(Loss_Cut, 2) + "%, ", true);
  
  ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, 0 , true);
  
   return(INIT_SUCCEEDED);
}

void determineTime() {

  string hid = "market high";
  string lid = "market low";

  if(setTokyoHigh()) {
    if(!setLondonHigh()) {
      ObjectSetText(hid, "Tokyo High", 12, "Arial", Market_Color);
      ObjectSetText(lid, "Tokyo Low", 12, "Arial", Market_Color);
      ObjectSetDouble(0, hid, OBJPROP_PRICE, tokyoHigh);
      ObjectSetDouble(0, lid, OBJPROP_PRICE, tokyoLow); 
    }
    else {
      ObjectSetText(hid, "London High", 12, "Arial", Market_Color);
      ObjectSetText(lid, "London Low", 12, "Arial", Market_Color);
      ObjectSetDouble(0, hid, OBJPROP_PRICE, londonHigh);
      ObjectSetDouble(0, lid, OBJPROP_PRICE, londonLow); 
    }
  }
  else {
    ObjectSetDouble(0, hid, OBJPROP_PRICE, 0.0);
    ObjectSetDouble(0, lid, OBJPROP_PRICE, 0.0);
  }
}


bool setLondonHigh() {

  int h = 18;
  if(!London_Summer_Time) {
    h ++;
  }
  
  if(Hour() < h || (Hour() == h && Minute() < 30)) {
    return False;
  }
  
  int start = 2*(Hour() - h);
  if(30 <= Minute()) {
    start ++;
  }
  
  londonHigh = iHigh(Symbol(), PERIOD_M30, iHighest(Symbol(), PERIOD_M30, MODE_HIGH, 17, start));
  londonLow = iLow(Symbol(), PERIOD_M30, iLowest(Symbol(), PERIOD_M30, MODE_LOW, 17, start));
  
  return True;
}

bool setTokyoHigh() {

  if(Hour() < 9) {
    return False;
  }
  
  tokyoHigh = iHigh(Symbol(), PERIOD_H1, iHighest(Symbol(), PERIOD_H1, MODE_HIGH, 6, Hour() - 8));
  tokyoLow = iLow(Symbol(), PERIOD_H1, iLowest(Symbol(), PERIOD_H1, MODE_LOW, 6, Hour() - 8));
  
  return True;
}

void calcLot() {

  double lcLine = ObjectGet("loss cut", OBJPROP_PRICE1);
  double price = (Ask + Bid) / 2.0;
  double loss = AccountEquity() * Loss_Cut / 100.0;
  
  string label = "LC: " + DoubleToStr(Loss_Cut, 2) + "% (" + DoubleToStr(loss, 0) + "JPY) , ";
    
  double lot = 0.0;
  if(lcLine < price) {
    lot = loss / ((Ask - lcLine) * lotSize * basejpy);
    label = label + " Long Lot = ";
  }
  else if(price < lcLine) {
    lot = loss / ((lcLine - Bid) * lotSize * basejpy);
    label = label + " Short Lot = ";
  }

  ObjectSetText("loss cut", label + DoubleToStr(lot, 2), 12, "Arial", LC_Color);
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
//---

  int isLive = MarketInfo(Symbol(), MODE_TRADEALLOWED);
  
  double h = iHigh(Symbol(), PERIOD_D1, isLive);
  double l = iLow(Symbol(), PERIOD_D1, isLive);
  double o = iOpen(Symbol(), PERIOD_D1, isLive);
  double c = iClose(Symbol(), PERIOD_D1, isLive);
  
  if(Live_SMA) {
    isLive = 0;
  }

  double ma5 = iMA(Symbol(), PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma25 = iMA(Symbol(), PERIOD_D1, 25, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma75 = iMA(Symbol(), PERIOD_D1, 75, 0, MODE_SMA, PRICE_CLOSE, isLive);
  double ma200 = iMA(Symbol(), PERIOD_D1, 200, 0, MODE_SMA, PRICE_CLOSE, isLive);
  
  ObjectSetDouble(0, "high", OBJPROP_PRICE, h);
  ObjectSetDouble(0, "low", OBJPROP_PRICE, l);
  ObjectSetDouble(0, "open", OBJPROP_PRICE, o);
  ObjectSetDouble(0, "close", OBJPROP_PRICE, c);
  ObjectSetDouble(0, "ma5", OBJPROP_PRICE, ma5);
  ObjectSetDouble(0, "ma25", OBJPROP_PRICE, ma25);
  ObjectSetDouble(0, "ma75", OBJPROP_PRICE, ma75);
  ObjectSetDouble(0, "ma200", OBJPROP_PRICE, ma200);

  determineTime();

  calcLot();
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  calcLot();
}

