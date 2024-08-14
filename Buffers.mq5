//+------------------------------------------------------------------+
//|                                                    ZigZagMax.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                   https://github.com/mql-systems/Test_indicators |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link      "https://github.com/mql-systems/Test_indicators"
#property version   "1.00"
#property indicator_chart_window

//--- properties
#property indicator_buffers 5
#property indicator_plots 3
//---
#property indicator_type1  DRAW_ZIGZAG
#property indicator_label1 "ZigZag Up;ZigZag Down"
#property indicator_color1 clrOrange
//---
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrNONE
#property indicator_label2 "ZigZag Change Points"
//---
#property indicator_type3  DRAW_NONE
#property indicator_label3 "ZigZag Trend"

//--- defines
#define BUFFER_EMPTY        0.0
#define BUFFER_TREND_UP     1.0
#define BUFFER_TREND_DOWN  -1.0

//--- inputs
input bool i_IsShowZigZagChangePoints = true;   // Shows the ZigZag change points

//--- buffers
double g_bufferZigZagUp[];
double g_bufferZigZagDown[];
double g_bufferZigZagTrend[];
double g_bufferZigZagChangePoints[];
double g_bufferTestOpenPrice[];

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
   SetIndexBuffer(2, g_bufferZigZagChangePoints);
   SetIndexBuffer(3, g_bufferZigZagTrend);
   SetIndexBuffer(4, g_bufferTestOpenPrice);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, BUFFER_EMPTY);   // 0 = ZigZag Up & Down (BufferUp & BufferDown)
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, BUFFER_EMPTY);   // 1 = ZagZag Change Points
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, BUFFER_EMPTY);   // 2 = ZagZag Trend

   PlotIndexSetInteger(1, PLOT_LINE_COLOR, i_IsShowZigZagChangePoints ? clrRed : clrNONE);
   
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
      g_bufferTestOpenPrice[limit] = open[limit];
      
      if (open[limit] > close[limit])
      {
         g_bufferZigZagUp[limit] = BUFFER_EMPTY;
         g_bufferZigZagDown[limit] = low[limit];
         g_bufferZigZagChangePoints[limit] = low[limit];
         g_bufferZigZagTrend[limit] = BUFFER_TREND_DOWN;
      }
      else
      {
         g_bufferZigZagUp[limit] = high[limit];
         g_bufferZigZagDown[limit] = BUFFER_EMPTY;
         g_bufferZigZagChangePoints[limit] = high[limit];
         g_bufferZigZagTrend[limit] = BUFFER_TREND_UP;
      }
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
      g_bufferTestOpenPrice[i] = open[i];

      if (high[i+1] < high[i])
      {
         if (low[i+1] < low[i] || g_bufferZigZagTrend[i] > 0)
            ChangeZigZagUp(ratesTotal, i, high[i]);
         else
            ChangeZigZagDown(ratesTotal, i, low[i]);
      }
      else if (low[i+1] > low[i] || g_bufferZigZagTrend[i] < 0)
         ChangeZigZagDown(ratesTotal, i, low[i]);
      else
         ChangeZigZagUp(ratesTotal, i, high[i]);
   }

   return ratesTotal;
}

//+------------------------------------------------------------------+
//| Сдвинуть ZigZag Up                                               |
//+------------------------------------------------------------------+
void ChangeZigZagUp(int ratesTotal, int i, double high)
{
   for (int j = i + 1; j < ratesTotal; j++)
   {
      if (g_bufferZigZagTrend[j] > 0)
      {
         g_bufferZigZagUp[j] = BUFFER_EMPTY;
         break;
      }
      else if (g_bufferZigZagTrend[j] < 0)
         break;
   }

   g_bufferZigZagUp[i] = high;
   g_bufferZigZagDown[i] = BUFFER_EMPTY;
   g_bufferZigZagChangePoints[i] = high;
   g_bufferZigZagTrend[i] = BUFFER_TREND_UP;
}

//+------------------------------------------------------------------+
//| Сдвинуть ZigZag Down                                             |
//+------------------------------------------------------------------+
void ChangeZigZagDown(int ratesTotal, int i, double low)
{
   for (int j = i + 1; j < ratesTotal; j++)
   {
      if (g_bufferZigZagTrend[j] < 0)
      {
         g_bufferZigZagDown[j] = BUFFER_EMPTY;
         break;
      }
      else if (g_bufferZigZagTrend[j] > 0)
         break;
   }

   g_bufferZigZagUp[i] = BUFFER_EMPTY;
   g_bufferZigZagDown[i] = low;
   g_bufferZigZagChangePoints[i] = low;
   g_bufferZigZagTrend[i] = BUFFER_TREND_DOWN;
}

//+------------------------------------------------------------------+
//| Buffer initialize                                                |
//+------------------------------------------------------------------+
void BufferInitialize()
{
   ArrayInitialize(g_bufferZigZagUp, BUFFER_EMPTY);
   ArrayInitialize(g_bufferZigZagDown, BUFFER_EMPTY);
   ArrayInitialize(g_bufferZigZagChangePoints, BUFFER_EMPTY);
   ArrayInitialize(g_bufferZigZagTrend, BUFFER_EMPTY);
   ArrayInitialize(g_bufferTestOpenPrice, BUFFER_EMPTY);

   ArraySetAsSeries(g_bufferZigZagUp, true);
   ArraySetAsSeries(g_bufferZigZagDown, true);
   ArraySetAsSeries(g_bufferZigZagChangePoints, true);
   ArraySetAsSeries(g_bufferZigZagTrend, true);
   ArraySetAsSeries(g_bufferTestOpenPrice, true);
}

//+------------------------------------------------------------------+