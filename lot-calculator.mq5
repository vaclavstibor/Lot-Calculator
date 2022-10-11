//+------------------------------------------------------------------+
//|                                                LotCalculator.mq5 |
//|                                              Copyright 2022, ... |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, ..."
#property version   "1.00"
#property description "Calculator to find current lot value by user input parameters:"
#property description " - order open price"
#property description " - stop loss price"
#property description " - capital"
#property description " - risk percentage"

double input OrderOpenPrice = 7510.3;        // Otevírací cena
double input OrderStopLossPrice = 7537.15;    // Stop loss cena
double input Capital = 300000;      // Kapitál
double input RiskPercentage = 0.3;  // Risk
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double OrderLotSize = DeltaLotCalc();

   Print("(",_Symbol,") Lot value: ", DoubleToString(OrderLotSize, 2));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+

//- Lot calculator for panding orders
// [Params] StopLoss is size of zone range. OrderOpenPrice is price. OrderStopLoss is price.
double DeltaLotCalc()
  {

//--
   double TickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double TickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//--

   double Risk = Capital * RiskPercentage / 100;

// Non-FX instrument must be checked via same currency as user acc
   double DeltaPerLot = TickValue / TickSize;

   double OrderLots = Risk / (MathAbs(NormalizeDouble(OrderOpenPrice,_Digits) - NormalizeDouble(OrderStopLossPrice,_Digits)) * DeltaPerLot /* + CommissionPerLot*/);

   return NormalizeLots(OrderLots);
  }

//- Lot size normalizer, for round (floating point) numbers
// [Params] Lots is size of order.
double NormalizeLots(double Lots)
  {
   double LotsMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double LotsMaximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double LotsStep    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

// Prevent too greater volume. Prevent too smaller volume. Align to Step value
   return fmin(LotsMaximum, fmax(LotsMinimum, round(Lots / LotsStep) * LotsStep));
  }  
//+------------------------------------------------------------------+
