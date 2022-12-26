//+------------------------------------------------------------------+
//|                                                   Lot Calculator |
//|                                    Copyright 2022, Václav Stibor |
//|                   https://github.com/vaclavstibor/lot-calculator |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Václav Stibor"
#property link "https://github.com/vaclavstibor/lot-calculator"
#property version "2.00"
#property strict

// Define input variables
string input s0 = "Symbol:";
string input Symbol = "EURUSD";            // Input format: EURUSD
string input s1 = "Open price:";
double input OpenPrice = "1.06168";        // Input format: 1.54321
string input s2 = "Stop loss price:";
double input StopLossPrice = "1.06068";    // Input format: 1.54221
string input s3 = "Account equity:";
double input AccountEquity = 5000;         // Input format: 5000
string input s4 = "Risk percentage:";
double input RiskPercentage = 1;           // Input format: 1

// Define global variables
double LotsStep = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_STEP);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit()
    {
        Print("(",Symbol,") Lot value: ", DoubleToString(LotsCalculation(), 2));
    }

//+------------------------------------------------------------------+
//| Get lot value depends on risk amount and stop loss               |
//+------------------------------------------------------------------+
double LotsCalculation()
    {
        // Function return variable
        double lots;

        // The smallest value of price change of current symbol
        double tickSize  = SymbolInfoDouble(Symbol, SYMBOL_TRADE_TICK_SIZE);
        // Whenever price change by tick size then profit chaged by tick value
        double tickValue = SymbolInfoDouble(Symbol, SYMBOL_TRADE_TICK_VALUE);

        // How much want user risk (e.g. 900 $)
        double riskAmount   = AccountEquity * RiskPercentage / 100;
        // Compute stop loss price distance from open price
        double riskDistance = GetDistance();

        if(tickSize == 0 || tickValue == 0 || LotsStep == 0)
        {
            Print("ERROR: Get data from broker's server failed. (0)");
            return 0;
        }

        // Risk amount for the smallest lots step
        double lotStepAmount = (riskDistance / tickSize) * tickValue * LotsStep;

        if(lotStepAmount == 0)
        {
            Print("ERROR: Lot step amount calculation. (0)");
        }

        lots = MathFloor(riskAmount / lotStepAmount) * LotsStep;

        return NormalizeLots(lots);
    }

//+------------------------------------------------------------------+
//| Get distance between stop loss and open price                    |
//+------------------------------------------------------------------+
double GetDistance()
    {
        // Function return variable
        double distance;

        // Get digits of symbol that user want
        int digits = SymbolInfoInteger(Symbol, SYMBOL_DIGITS);

        // Normalize prices to be compatible with symbol digits
        double NormalizedOpenPrice = NormalizeDouble(OpenPrice, digits);
        double NormalizedStopLossPrice = NormalizeDouble(StopLossPrice, digits);

        distance = MathAbs(NormalizedOpenPrice - NormalizedStopLossPrice);
        //Print("GetDistance(): distance is " + distance);

        return distance;
    }

//+------------------------------------------------------------------+
//| Lot size normalizer, round (floating point) numbers.             |
//| [Params] Lots is size of order.                                  |
//+------------------------------------------------------------------+
double NormalizeLots(double Lots)
    {
        double LotsMinimum = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_MIN);
        double LotsMaximum = SymbolInfoDouble(Symbol, SYMBOL_VOLUME_MAX);

        // Prevent too greater volume. Prevent too smaller volume. Align to Step value
        return fmin(LotsMaximum, fmax(LotsMinimum, round(Lots / LotsStep) * LotsStep));
  }
//+------------------------------------------------------------------+
