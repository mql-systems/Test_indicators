//+------------------------------------------------------------------+
//|                                                    ZigZagMax.mq5 |
//|                       Copyright 2022-2024, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property indicator_chart_window

//--- properties
#property indicator_buffers 4
#property indicator_plots 1
//---
#property indicator_type1  DRAW_ZIGZAG
#property indicator_label1 "ZigZag Up;ZigZag Down"
#property indicator_color1 clrOrange
//---
#property indicator_type2  DRAW_NONE
#property indicator_label2 "ZigZag Trend"
//---
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrRed
#property indicator_label3 "ZigZag Trend change"

//--- defines
#define BUFFER_EMPTY        0.0
#define BUFFER_TREND_UP     1.0
#define BUFFER_TREND_DOWN  -1.0

//--- buffers
double g_bufferZigZagUp[];
double g_bufferZigZagDown[];
double g_bufferTrend[];
double g_bufferChangePoints[];

//--- global variables
datetime g_lastBarTime = 0;

//+------------------------------------------------------------------+
//| App initialization function                                      |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   SetIndexBuffer(0, g_bufferZigZagUp);
   SetIndexBuffer(1, g_bufferZigZagDown);
   SetIndexBuffer(2, g_bufferTrend);
   SetIndexBuffer(3, g_bufferChangePoints);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, BUFFER_EMPTY);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, BUFFER_EMPTY);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, BUFFER_EMPTY);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, BUFFER_EMPTY);

   BufferInitialize();

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int ratesTotal,
                const int prevCalculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
{
   //--- new bar
   int limit = ratesTotal - prevCalculated;
   if (limit <= 0)
      return ratesTotal;
   if (ratesTotal < 2 || prevCalculated < 0)
      return 0;
   
   //--- first start indicator (initialize)
   if (prevCalculated == 0)
   {
      BufferInitialize();

      limit--;
      g_bufferZigZagUp[limit] = high[limit];
      g_bufferZigZagDown[limit] = low[limit];
      g_bufferTrend[limit] = BUFFER_EMPTY;
      g_bufferChangePoints[limit] = BUFFER_EMPTY;
   }
   else if (time[limit] != g_lastBarTime)
      return 0;
   
   g_lastBarTime = time[1];
   
   //--- calculate
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);
   ArraySetAsSeries(time, true);

   for (int i = limit - 1; i > 0; i--)
   {
      // - CALC -
   }

   return ratesTotal;
}

//+------------------------------------------------------------------+
//| Buffer initialize                                                |
//+------------------------------------------------------------------+
void BufferInitialize()
{
   ArrayInitialize(g_bufferZigZagUp, BUFFER_EMPTY);
   ArrayInitialize(g_bufferZigZagDown, BUFFER_EMPTY);
   ArrayInitialize(g_bufferTrend, BUFFER_EMPTY);
   ArrayInitialize(g_bufferChangePoints, BUFFER_EMPTY);

   ArraySetAsSeries(g_bufferZigZagUp, true);
   ArraySetAsSeries(g_bufferZigZagDown, true);
   ArraySetAsSeries(g_bufferTrend, true);
   ArraySetAsSeries(g_bufferChangePoints, true);
}

//+------------------------------------------------------------------+