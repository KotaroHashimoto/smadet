//+------------------------------------------------------------------+
//|                                                     UpOrDown.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

string buttonID = "BI";
string CurrencyPairs[] = {"EURUSD", "EURJPY", "USDJPY", "GBPUSD", "GBPJPY", 
                          "AUDUSD", "AUDJPY", "EURGBP", "EURAUD", "GBPAUD"};

int OnInit()
  {
//---
  ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 100, 100);
  ObjectSetInteger(0, buttonID, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, clrGray);
  ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 30);
  ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 50);
  ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, 150);
  ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, 50);
  ObjectSetString(0, buttonID, OBJPROP_FONT, "Arial");
  ObjectSetString(0, buttonID, OBJPROP_TEXT, "Generate File");
  ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, 15);
  ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);

//---
  return(INIT_SUCCEEDED);
}

string determine(double ma, double price) {

  if(ma == 0 || price == 0) {
    return "err";
  }
  else if(price < ma) {
    return "下落";
  }
  else {
    return "上昇";
  }
}

double digits(string currencyPair) {

  if(StringFind(currencyPair, "JPY") != -1)
    return 100.0;
  else
    return 10000.0;
}

void generateFile() {

  int isLive = MarketInfo(Symbol(), MODE_TRADEALLOWED);
  string date = string(Year()) + "_" + string(Month()) + "_" + string((Day() - isLive));
  int handle=FileOpen("TrendAnalysis.csv", FILE_CSV|FILE_WRITE, ',');
  if(handle < 0) {
    Print("File write error. " + string(GetLastError()));
    return;
  }
  else {
    FileWrite(handle, date);
    FileWrite(handle, "CurrencyPair", "5SMA", "25SMA", "75SMA", "200SMA", "5ATR", "25ATR");
  }
  
  for(int i = 0; i < 10; i++) {
  
    double ma5 = iMA(CurrencyPairs[i], PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, isLive);
    double ma25 = iMA(CurrencyPairs[i], PERIOD_D1, 25, 0, MODE_SMA, PRICE_CLOSE, isLive);
    double ma75 = iMA(CurrencyPairs[i], PERIOD_D1, 75, 0, MODE_SMA, PRICE_CLOSE, isLive);
    double ma200 = iMA(CurrencyPairs[i], PERIOD_D1, 200, 0, MODE_SMA, PRICE_CLOSE, isLive);

    double price = iClose(CurrencyPairs[i], PERIOD_D1, isLive);

    double atr5 = 0;
    double atr25 = 0;
    double accum = 0;

    for(int j = 0; j < 25; j ++) {
      accum += digits(CurrencyPairs[i]) * (iHigh(CurrencyPairs[i], PERIOD_D1, j + isLive) - iLow(CurrencyPairs[i], PERIOD_D1, j + isLive));

      if(j == 4) {
        atr5 = accum / double(j + 1);
      }
      if(j == 24) {
        atr25 = accum / double(j + 1);
      }
    }
    
    FileWrite(handle, CurrencyPairs[i], determine(ma5, price), determine(ma25, price), determine(ma75, price), determine(ma200, price), DoubleToStr(atr5, 2), DoubleToStr(atr25, 2));
//    Print(CurrencyPairs[i], " = ", price, ", ma5 = ", ma5, ", ma25 = ", ma25, ", ma75 = ", ma75, ", ma200 = ", ma200, " atr5 = ", atr5, ", atr25 = ", atr25);
  }
  
  FileClose(handle);
  Print(date, " file write succeeded.");
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0, buttonID);   
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  if(id == CHARTEVENT_OBJECT_CLICK) {
    string clickedChartObject = sparam;
    if(clickedChartObject == buttonID) {
      generateFile();
      
      Sleep(500);
      ObjectSetInteger(0, buttonID, OBJPROP_STATE, 0);      
    }
  }
}
