//+------------------------------------------------------------------+
//|                                                     Template.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link      "https://algotrading.today"
#property version   "1.00"
#property indicator_chart_window
//--- 
#property indicator_minimum 1
#property indicator_maximum 10
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- input parameters
input int      i_MaPeriod = 5;   // MA Period

//--- structs
struct BuffersStruct
{
   double BufferLabel1[];
   double BufferLabel2[];
};

//--- global variables
int g_HandleMa1;
int g_HandleMa2;
BuffersStruct g_BuffersStruct;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_BuffersStruct.BufferLabel1, INDICATOR_DATA);
   SetIndexBuffer(1, g_BuffersStruct.BufferLabel2, INDICATOR_DATA);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   IndicatorSetString(INDICATOR_SHORTNAME, "Test("+string(_Period)+")");

   ArraySetAsSeries(g_BuffersStruct.BufferLabel1, true);
   g_HandleMa1 = iMA(_Symbol, 0, i_MaPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_HandleMa2 = iMA(_Symbol, 0, i_MaPeriod, 0, MODE_EMA, PRICE_OPEN);
   
   return INIT_SUCCEEDED;
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
   if (BarsCalculated(g_HandleMa1) < rates_total || BarsCalculated(g_HandleMa2) < rates_total)
      return 0;
   
   int toCopy;
   if (prev_calculated > rates_total || prev_calculated <= 0)
      toCopy = rates_total;
   else
      toCopy = rates_total - prev_calculated + 1;

   if (CopyBuffer(g_HandleMa1, 0, 0, toCopy, g_BuffersStruct.BufferLabel1) <= 0)
      return 0;
   if (CopyBuffer(g_HandleMa2, 0, 0, toCopy, g_BuffersStruct.BufferLabel2) <= 0)
      return 0;
   
   return rates_total;
}

//+------------------------------------------------------------------+
