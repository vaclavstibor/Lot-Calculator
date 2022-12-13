//+------------------------------------------------------------------+
//|                                                   Lot Calculator |
//|                                    Copyright 2022, Václav Stibor |
//|                                                          git-url |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Václav Stibor"
#property link "git-url"
#property version "2.00"
#property strict

// Define input variables
string input s0 = "Symbol:";
string input Symbol = "EURUSD";
string input s1 = "Open price:";
double input OpenPrice = 1.0541;
string input s2 = "Stop loss price:";
double input StopLossPrice = 1.0541;
string input s3 = "Account balance:";
double input AccountBalance = 5000;
string input s4 = "Risk percentage:";
double input RiskPercentage = 4;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit()
  {
   Print("(",Symbol,") Lot value: ", DoubleToString(LotCalculation(), 2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotCalculation()
  {
   double lots;

   double tickSize  = SymbolInfoDouble(Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lotStep   = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_STEP);

   double riskAmount   = AccountBalance * RiskPercentage / 100;
   double riskDistance = GetDistance();

   if(tickSize == 0 || tickValue == 0 || lotStep == 0)
     {
      Print("ERROR: Get data from server failed.");
      return 0;
     }

   double lotStepAmount = (riskDistance / tickSize) * tickValue * lotStep;

   if(lotStepAmount == 0)
     {
      Print("ERROR: Lot step amount calculation.");
     }

   lots = MathFloor(riskAmount / lotStepAmount) * lotStep;

   return NormalizeLots(lots);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetDistance()
  {
   double distance;

   int digits = SymbolInfoInteger(Symbol, SYMBOL_DIGITS);

   double NormalizedOpenPrice = NormalizeDouble(OpenPrice, digits);
   double NormalizedStopLossPrice = NormalizeDouble(StopLossPrice, digits);

   distance = MathAbs(NormalizedOpenPrice - NormalizedStopLossPrice);
//Print("GetDistance(): distance is " + distance);

   return distance;
  }

//- Lot size normalizer, round (floating point) numbers
// [Params] Lots is size of order.
double NormalizeLots(double Lots)
  {
//--
   double LotsMinimum = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_MIN);
   double LotsMaximum = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_MAX);
   double LotsStep    = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_STEP);
//--

// Prevent too greater volume. Prevent too smaller volume. Align to Step value
   return fmin(LotsMaximum, fmax(LotsMinimum, round(Lots / LotsStep) * LotsStep));
  }
//+------------------------------------------------------------------+
