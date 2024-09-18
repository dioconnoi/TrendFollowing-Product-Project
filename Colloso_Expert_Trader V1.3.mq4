/*

This EA is a Financial Technology Masters Product Project

*/

//-PROPERTIES-//
//Properties help the software look better when you load it in MT4
//Provide more information and details
//This is what you see in the About tab when you load an indicator or an Expert Advisor
#property link          "https://www.linkedin.com/in/emmanuelazubuike/"
#property version       "2.00"
#property strict
#property copyright     "Collosotrading.com - 2024-2025"
#property description   "This is a TrendFollowing and Pullback Automated EA" 
#property description   " "
#property description   "PROJECT : This is a Fintech Masters Product Project."
#property description   "By Emmanuel Azubuike."
#property description   " "
//You can add an icon for when the EA loads on chart but it's not necessary
//The commented line below is an example of icon, icon must be in the MQL4/Files folder and have a ico extension

//-INCLUDES-//
//Include allows to import code from another file
//In the following instance the file has to be placed in the MQL4/Include Folder
#include <MQLTA ErrorHandling.mqh>

//-COMMENTS-//
//This is a single line comment and I do it placing // at the start of the comment, this text is ignored when compiling

/*
This is a multi line comment
it starts with /* and it finishes with the * and / like below
*/


//-ENUMERATIVE VARIABLES-//
//Enumerative variables are useful to associate numerical values to easy to remember strings
//It is similar to constants but also helps if the variable is set from the input page of the EA
//The text after the // is what you see in the input paramenters when the EA loads
//It is good practice to place all the enumberative at the start

enum e_cycles { Min_1=9, Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

enum ENUM_HOUR{
   h00=00,     //00:00
   h01=01,     //01:00
   h02=02,     //02:00
   h03=03,     //03:00
   h04=04,     //04:00
   h05=05,     //05:00
   h06=06,     //06:00
   h07=07,     //07:00
   h08=08,     //08:00
   h09=09,     //09:00
   h10=10,     //10:00
   h11=11,     //11:00
   h12=12,     //12:00
   h13=13,     //13:00
   h14=14,     //14:00
   h15=15,     //15:00
   h16=16,     //16:00
   h17=17,     //17:00
   h18=18,     //18:00
   h19=19,     //19:00
   h20=20,     //20:00
   h21=21,     //21:00
   h22=22,     //22:00
   h23=23,     //23:00
};

enum ENUM_SIGNAL_ENTRY{
   SIGNAL_ENTRY_NEUTRAL=0,    //SIGNAL ENTRY NEUTRAL
   SIGNAL_ENTRY_BUY=1,        //SIGNAL ENTRY BUY
   SIGNAL_ENTRY_SELL=-1,      //SIGNAL ENTRY SELL
};

enum ENUM_SIGNAL_EXIT{
   SIGNAL_EXIT_NEUTRAL=0,     //SIGNAL EXIT NEUTRAL
   SIGNAL_EXIT_BUY=1,         //SIGNAL EXIT BUY
   SIGNAL_EXIT_SELL=-1,        //SIGNAL EXIT SELL
   SIGNAL_EXIT_ALL=2,         //SIGNAL EXIT ALL
};

enum ENUM_TRADING_ALLOW_DIRECTION{
   TRADING_ALLOW_BOTH=0,      //ALLOW BOTH BUY AND SELL
   TRADING_ALLOW_BUY=1,       //ALLOW BUY ONLY
   TRADING_ALLOW_SELL=-1,     //ALLOW SELL ONLY
};

enum ENUM_RISK_BASE{
   RISK_BASE_EQUITY=1,        //EQUITY
   RISK_BASE_BALANCE=2,       //BALANCE
   RISK_BASE_FREEMARGIN=3,    //FREE MARGIN
};

enum ENUM_RISK_DEFAULT_SIZE{
   RISK_DEFAULT_FIXED=1,      //FIXED SIZE
   RISK_DEFAULT_AUTO=2,       //AUTOMATIC SIZE BASED ON RISK
};

enum ENUM_MODE_SL{
   SL_FIXED=0,                //FIXED STOP LOSS
   SL_AUTO=1,                 //AUTOMATIC STOP LOSS
};

enum ENUM_MODE_TP{
   TP_FIXED=0,                //FIXED TAKE PROFIT
   TP_AUTO=1,                 //AUTOMATIC TAKE PROFIT
};

enum ENUM_MODE_SL_BY{
   SL_BY_POINTS=0,            //STOP LOSS PASSED IN POINTS
   SL_BY_PRICE=1,             //STOP LOSS PASSED BY PRICE
};

enum Signal_Type{
Trending,//Trending
Pullback,//Pullback
};

enum Timeframe_Combination_Type{
Two_TF,//Two_Timeframes
Three_TF,//Three_Timeframes
};

enum Entry_Order_Type
  {
   Ask_Confirm,
   At_Market,
   Pending_Order,
  };
  

//-INPUT PARAMETERS-//
//The input parameters are the ones that can be set by the user when launching the EA
//If you place a comment following the input variable this will be shown as description of the field

//This is where you should include the input parameters for your entry and exit signals

input string Comment1X = "========================"; // MAIN CONTROLSX
input string IndicatorName1 = "MAIN CONTROLS ";           // MAIN CONTROLS
input string Comment2X = "========================"; // MAIN CONTROLSY

input  e_cycles   TimeFrame                      = Min_60;
input  e_cycles   TimeFrame_2                    = Min_15;
input  e_cycles   TimeFrame_3                    = Min_5;
input Signal_Type Signal_Types =Trending;//Signal_Type;
input Timeframe_Combination_Type Timeframe_Combination_Types =Two_TF;//Timeframe_Combination_Type;
extern Entry_Order_Type       Entry_Order_TypeXX                 = At_Market; //Entry Order Type
//+------------------------------------------------------------------+

input string Comment_strategy="==========";                          //Risk Management Settings
input int MAFastPeriod=10;                                           //Fast MA Period
input int MAFastShift=0;                                             //Fast MA Shift
input ENUM_MA_METHOD MAFastMethod=MODE_SMA;                          //Fast MA Method
input ENUM_APPLIED_PRICE MAFastAppliedPrice=PRICE_CLOSE;             //Fast MA Applied Price
input int MASlowPeriod=25;                                           //Slow MA Period
input int MASlowShift=0;                                             //Slow MA Shift
input ENUM_MA_METHOD MASlowMethod=MODE_SMA;                          //Slow MA Method
input ENUM_APPLIED_PRICE MASlowAppliedPrice=PRICE_CLOSE;             //Slow MA Applied Price
input double PSARStopStep=0.04;                                      //Stop Loss PSAR Step
input double PSARStopMax=0.4;                                        //Stop Loss PSAR Max

//General input parameters
input string Comment_0="==========";                                 //Risk Management Settings
input ENUM_RISK_DEFAULT_SIZE RiskDefaultSize=RISK_DEFAULT_AUTO;      //Position Size Mode
input double DefaultLotSize=1;                                       //Position Size (if fixed or if no stop loss defined)
input ENUM_RISK_BASE RiskBase=RISK_BASE_BALANCE;                     //Risk Base
input int MaxRiskPerTrade=2;                                         //Percentage To Risk Each Trade
input double MinLotSize=0.01;                                        //Minimum Position Size Allowed
input double MaxLotSize=100;                                         //Maximum Position Size Allowed

input string Comment_1="==========";                                 //Trading Hours Settings
input bool UseTradingHours=false;                                    //Limit Trading Hours
input ENUM_HOUR TradingHourStart=h07;                                //Trading Start Hour (Broker Server Hour)
input ENUM_HOUR TradingHourEnd=h19;                                  //Trading End Hour (Broker Server Hour)

input string Comment_2="==========";                                 //Stop Loss And Take Profit Settings
input ENUM_MODE_SL StopLossMode=SL_FIXED;                            //Stop Loss Mode
input int DefaultStopLoss=0;                                         //Default Stop Loss In Points (0=No Stop Loss)
input int MinStopLoss=0;                                             //Minimum Allowed Stop Loss In Points
input int MaxStopLoss=5000;                                          //Maximum Allowed Stop Loss In Points
input ENUM_MODE_TP TakeProfitMode=TP_FIXED;                          //Take Profit Mode
input int DefaultTakeProfit=0;                                       //Default Take Profit In Points (0=No Take Profit)
input int MinTakeProfit=0;                                           //Minimum Allowed Take Profit In Points
input int MaxTakeProfit=5000;                                        //Maximum Allowed Take Profit In Points

input string Comment_3="==========";                                 //Trailing Stop Settings
input bool UseTrailingStop=false;                                    //Use Trailing Stop

input string Comment_4="==========";                                 //Additional Settings
input int MagicNumber=0;                                             //Magic Number For The Orders Opened By This EA
input string OrderNote="";                                           //Comment For The Orders Opened By This EA
input int Slippage=5;                                                //Slippage in points
input int MaxSpread=100;                                             //Maximum Allowed Spread To Trade In Points

extern string DISPLAY_settings    ="DISPLAY / SOUND SETTINGS";
input string Confirm_Sound = "alert.wav";
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;

//extern string     Comment11                     = "- Optional EA actions -";

extern bool       EASounds                      = true;
extern bool       Show_Profit_Comments          = true;
input double ZoomFactor = 1;
input double FontSizeMultiplier = 1;
input string Font = "Arial";

string EA_Name = "Colloso's DayTrading EA";
string CommentOrder = EA_Name+" Order";
double Lots;
//-GLOBAL VARIABLES-//
//The viables included in this section are global, hence they can be used in any part of the code
//It is useful to add a comment to remember what is the variable for

bool IsPreChecksOk=false;                 //Indicates if the pre checks are satisfied
bool IsNewCandle=false;                   //Indicates if this is a new candle formed
bool IsSpreadOK=false;                    //Indicates if the spread is low enough to trade
bool IsOperatingHours=false;              //Indicates if it is possible to trade at the current time (server time)
bool IsTradedThisBar=false;               //Indicates if an order was already executed in the current candle

double TickValue=0;                       //Value of a tick in account currency at 1 lot
double LotSize=0;                         //Lot size for the position

int OrderOpRetry=10;                      //Number of attempts to retry the order submission
int TotalOpenOrders=0;                    //Number of total open orders
int TotalOpenBuy=0;                       //Number of total open buy orders
int TotalOpenSell=0;                      //Number of total open sell orders
int StopLossBy=SL_BY_POINTS;              //How the stop loss is passed for the lot size calculation

ENUM_SIGNAL_ENTRY SignalEntry=SIGNAL_ENTRY_NEUTRAL;      //Entry signal variable
ENUM_SIGNAL_EXIT SignalExit=SIGNAL_EXIT_NEUTRAL;         //Exit signal variable

//-NATIVE MT4 EXPERT ADVISOR RUNNING FUNCTIONS-//

//OnInit is executed once, when the EA is loaded
//OnInit is also executed if the time frame or symbol for the chart is changed
int OnInit(){
   //It is useful to set a function to check the integrity of the initial parameters and call it as first thing
   CheckPreChecks();
   //If the initial pre checks have something wrong, stop the program
   if(!IsPreChecksOk){
      OnDeinit(INIT_FAILED);
      return(INIT_FAILED);
   }   
   //Function to initialize the values of the global variables
   InitializeVariables();
   
   //If everything is ok the function returns successfully and the control is passed to a timer or the OnTike function
   return(INIT_SUCCEEDED);
}

bool confirmBuyTrade=false;
bool confirmSellTrade = false;
string prefix = "strategyeaCtrading";
void ShowConfirmWindow(double lot, double price, double sl, double tp)
  {
   int xpos = 100;
   int ypos = 400;
   if(confirmBuyTrade)
     {

      PlaySound(Confirm_Sound);
      ObjectDelete(0,prefix+"sellconfirm");
      ObjectDelete(0,prefix+"sellcancel");
      ObjectDelete(0,prefix+"sellinfo");
      ObjectDelete(0,prefix+"dialogbackground2");
      RectLabelCreate(0,prefix+"dialogbackground1",0,xpos-20,ypos-20,390,55,clrBlack,BORDER_FLAT,0,clrGray);
      datetime dt = TimeCurrent();
      LabelCreate(0,prefix+"buyinfo",0,  xpos+0,ypos+-12,CORNER_LEFT_UPPER,StringFormat("%s Lot:%f Price:%f Sl:%f Tp:%f", TimeToStr(dt), lot,price,sl,tp),Font,8,clrWhite);

      //LabelCreate(0,prefix+"buyinfo",0,  xpos+0,ypos+-12,CORNER_LEFT_UPPER,StringFormat("Lot:%f Price:%f Sl:%f Tp:%f", lot,price,sl,tp),Font,8,clrWhite);

      ButtonCreate(0,prefix+"buyconfirm",0,xpos+0,ypos+12,150,18,CORNER_LEFT_UPPER,"Confirm Buy Trade",Font,10,clrWhite,clrGreen);
      ButtonCreate(0,prefix+"buycancel",0,xpos+200,ypos+12,150,18,CORNER_LEFT_UPPER,"Cancel Buy Trade",Font,10,clrWhite,clrRed);
     }
   ypos= ypos + 60;
   if(confirmSellTrade)
     {
      PlaySound(Confirm_Sound);
      ObjectDelete(0,prefix+"buyconfirm");
      ObjectDelete(0,prefix+"buycancel");
      ObjectDelete(0,prefix+"buyinfo");

      ObjectDelete(0,prefix+"dialogbackground1");
      RectLabelCreate(0,prefix+"dialogbackground2",0,xpos-20,ypos-20,390,55,clrBlack,BORDER_FLAT,0,clrGray);
      datetime dt = TimeCurrent();
      LabelCreate(0,prefix+"sellinfo",0,  xpos+0,ypos+-12,CORNER_LEFT_UPPER,StringFormat("%s Lot:%f Price:%f Sl:%f Tp:%f",TimeToStr(dt), lot,price,sl,tp),Font,8,clrWhite);
      //LabelCreate(0,prefix+"sellinfo",0,  xpos+0,ypos+-12,CORNER_LEFT_UPPER,StringFormat("Lot:%f Price:%f Sl:%f Tp:%f", lot,price,sl,tp),Font,8,clrWhite);

      ButtonCreate(0,prefix+"sellconfirm",0,xpos+0,ypos+12,150,18,CORNER_LEFT_UPPER,"Confirm Sell Trade",Font,10,clrWhite,clrGreen);
      ButtonCreate(0,prefix+"sellcancel",0,xpos+200,ypos+12,150,18,CORNER_LEFT_UPPER,"Cancel Sell Trade",Font,10,clrWhite,clrRed);
     }
  }


//The OnDeinit function is called just before terminating the program
void OnDeinit(const int reason){
   //You can include in this function something you want done when the EA closes
   //For example clean the chart form graphical objects, write a report to a file or some kind of alert
   {
   ObjectsDeleteAll(0,prefix);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {


   if(id==CHARTEVENT_OBJECT_CLICK && sparam==prefix+"buyconfirm")
     {

      ObjectDelete(0,prefix+"buyconfirm");
      ObjectDelete(0,prefix+"buycancel");
      ObjectDelete(0,prefix+"buyinfo");

      ObjectDelete(0,prefix+"dialogbackground1");
      ChartRedraw();
      //OpenPos(OP_BUY,currentstoploss);
      confirmBuyTrade = false;

     }
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==prefix+"buycancel")
     {

      ObjectDelete(0,prefix+"buyconfirm");
      ObjectDelete(0,prefix+"buycancel");
      ObjectDelete(0,prefix+"buyinfo");
      ObjectDelete(0,prefix+"dialogbackground1");
      confirmBuyTrade = false;
      ChartRedraw();
     }


   if(id==CHARTEVENT_OBJECT_CLICK && sparam==prefix+"sellconfirm")
     {

      ObjectDelete(0,prefix+"sellconfirm");
      ObjectDelete(0,prefix+"sellcancel");
      ObjectDelete(0,prefix+"sellinfo");
      ObjectDelete(0,prefix+"dialogbackground2");
      ChartRedraw();
      //OpenPos(OP_SELL,currentstoploss);
      confirmSellTrade = false;

     }
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==prefix+"sellcancel")
     {

      ObjectDelete(0,prefix+"sellconfirm");
      ObjectDelete(0,prefix+"sellcancel");
      ObjectDelete(0,prefix+"sellinfo");
      ObjectDelete(0,prefix+"dialogbackground2");
      confirmSellTrade = false;
      ChartRedraw();

     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      if(ObjectFind(chart_ID,name)<0)
        {
         Print(__FUNCTION__,
               ": failed to create text label! Error code = ",GetLastError());
         return(false);
        }
     }

//--- set label coordinates
   if(anchor==ANCHOR_RIGHT || anchor==ANCHOR_RIGHT_LOWER || anchor==ANCHOR_RIGHT_UPPER)
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
     }
   else
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x*ZoomFactor);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y*ZoomFactor);
     }
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size*FontSizeMultiplier*ZoomFactor);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      if(ObjectFind(chart_ID,name)<0)
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle label! Error code = ",GetLastError()," name:",name);
         return(false);
        }
     }

//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x*ZoomFactor);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y*ZoomFactor);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width*ZoomFactor);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height*ZoomFactor);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=2)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();

//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      if(ObjectFind(chart_ID,name)<0)
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return(false);
        }
     }


//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x*ZoomFactor);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y*ZoomFactor);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width*ZoomFactor);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height*ZoomFactor);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font==""? Font:font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size*FontSizeMultiplier*ZoomFactor);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

//The OnTick function is triggered every time MT4 receives a price change for the symbol in the chart
void OnTick(){
   //Re-initialize the values of the global variables at every run
   InitializeVariables();
   //ScanOrders scans all the open orders and collect statistics, if an error occurs it skips to the next price change
   if(!ScanOrders()) return;
   //CheckNewBar checks if the price change happened at the start of a new bar
   CheckNewBar();
   //CheckOperationHours checks if the current time is in the operating hours
   CheckOperationHours();
   //CheckSpread checks if the spread is above the maximum spread allowed
   CheckSpread();
   //CheckTradedThisBar checks if there was already a trade executed in the current candle
   CheckTradedThisBar();
   //EvaluateExit contains the code to decide if there is an exit signal
   EvaluateExit();
   //ExecuteExit executes the exit in case there is an exit signal
   ExecuteExit();
   //Scan orders again in case some where closed, if an error occurs it skips to the next price change
   if(!ScanOrders()) return;
   //Execute Trailing Stop
   ExecuteTrailingStop();
   //EvaluateEntry contains the code to decide if there is an entry signal
   EvaluateEntry_Trend();
   EvaluateEntry_Pullback();
   //ExecuteEntry executes the entry in case there is an entry signal
   ExecuteEntry();
   ExecuteEntry_AskConfirm();
}


//-CUSTOM EA FUNCTIONS-//

//Perform integrity checks when the EA is loaded
void CheckPreChecks(){
   IsPreChecksOk=true;
   if(!IsTradeAllowed()){
      IsPreChecksOk=false;
      Print("Live Trading is not enabled, please enable it in MT4 and chart settings");
      return;
   }
   if(DefaultStopLoss<MinStopLoss || DefaultStopLoss>MaxStopLoss){
      IsPreChecksOk=false;
      Print("Default Stop Loss must be between Minimum and Maximum Stop Loss Allowed");
      return;
   }
   if(DefaultTakeProfit<MinTakeProfit || DefaultTakeProfit>MaxTakeProfit){
      IsPreChecksOk=false;
      Print("Default Take Profit must be between Minimum and Maximum Take Profit Allowed");
      return;
   }
   if(DefaultLotSize<MinLotSize || DefaultLotSize>MaxLotSize){
      IsPreChecksOk=false;
      Print("Default Lot Size must be between Minimum and Maximum Lot Size Allowed");
      return;
   }
   if(Slippage<0){
      IsPreChecksOk=false;
      Print("Slippage must be a positive value");
      return;
   }
   if(MaxSpread<0){
      IsPreChecksOk=false;
      Print("Maximum Spread must be a positive value");
      return;
   }
   if(MaxRiskPerTrade<0 || MaxRiskPerTrade>100){
      IsPreChecksOk=false;
      Print("Maximum Risk Per Trade must be a percentage between 0 and 100");
      return;
   }
}

//Initialize variables
void InitializeVariables(){
   IsNewCandle=false;
   IsTradedThisBar=false;
   IsOperatingHours=false;
   IsSpreadOK=false;
   
   LotSize=DefaultLotSize;
   TickValue=0;
   
   TotalOpenBuy=0;
   TotalOpenSell=0;
   TotalOpenOrders=0;
   
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   SignalExit=SIGNAL_EXIT_NEUTRAL;
}

////Evaluate if there is an entry signal
//void EvaluateEntry(){
//   int period     = Get_TimeFrame(TimeFrame);
//   int period_2     = Get_TimeFrame(TimeFrame_2);
//   int period_3     = Get_TimeFrame(TimeFrame_3);
//   
//   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
//   if(!IsSpreadOK) return;    //If the spread is too high don't give an entry signal
//   if(UseTradingHours && !IsOperatingHours) return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
//   //if(!IsNewCandle) return;      //If you want to provide a signal only if it's a new candle opening
//   if(IsTradedThisBar) return;   //If you don't want to execute multiple trades in the same bar
//   if(TotalOpenOrders>0) return; //If there are already open orders and you don't want to open more
//   
//   //Declaring the variables for the entry and exit check
//   double MASlowPrev=iMA(Symbol(),PERIOD_CURRENT,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
//   double MASlowCurr=iMA(Symbol(),PERIOD_CURRENT,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
//   double MAFastPrev=iMA(Symbol(),PERIOD_CURRENT,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
//   double MAFastCurr=iMA(Symbol(),PERIOD_CURRENT,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
//   
//   //This is where you should insert your Entry Signal for BUY orders
//   //Include a condition to open a buy order, the condition will have to set SignalEntry=SIGNAL_ENTRY_BUY   
//   if(MAFastPrev<MASlowPrev && MAFastCurr>MASlowCurr) SignalEntry=SIGNAL_ENTRY_BUY;
//   
//   //This is where you should insert your Entry Signal for SELL orders
//   //Include a condition to open a sell order, the condition will have to set SignalEntry=SIGNAL_ENTRY_SELL
//   if(MAFastPrev>MASlowPrev && MAFastCurr<MASlowCurr) SignalEntry=SIGNAL_ENTRY_SELL;
//   
//}

//Evaluate if there is an entry signal
void EvaluateEntry_Trend(){
   int period     = Get_TimeFrame(TimeFrame);
   int period_2     = Get_TimeFrame(TimeFrame_2);
   int period_3     = Get_TimeFrame(TimeFrame_3);
   double close_3, close_1, close_2;
   close_1 = iClose(Symbol(),period,1);
   close_2 = iClose(Symbol(),period_2,1);
   close_3 = iClose(Symbol(),period_3,1);
   
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   if(!IsSpreadOK) return;    //If the spread is too high don't give an entry signal
   if(UseTradingHours && !IsOperatingHours) return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
   //if(!IsNewCandle) return;      //If you want to provide a signal only if it's a new candle opening
   if(IsTradedThisBar) return;   //If you don't want to execute multiple trades in the same bar
   if(TotalOpenOrders>0) return; //If there are already open orders and you don't want to open more
   
   //Declaring the variables for the entry and exit check
   double MASlowPrev_1=iMA(Symbol(),period,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_1=iMA(Symbol(),period,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_1=iMA(Symbol(),period,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_1=iMA(Symbol(),period,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   double MASlowPrev_2=iMA(Symbol(),period_2,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_2=iMA(Symbol(),period_2,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_2=iMA(Symbol(),period_2,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_2=iMA(Symbol(),period_2,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   double MASlowPrev_3=iMA(Symbol(),period_3,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_3=iMA(Symbol(),period_3,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_3=iMA(Symbol(),period_3,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_3=iMA(Symbol(),period_3,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   //This is where you should insert your Entry Signal for BUY orders
   //Include a condition to open a buy order, the condition will have to set SignalEntry=SIGNAL_ENTRY_BUY   
   //if(MAFastPrev_1<MASlowPrev_1 && MAFastCurr_1>MASlowCurr_1) SignalEntry=SIGNAL_ENTRY_BUY;

   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Three_TF); 
      if (close_1>MAFastCurr_1 && MAFastCurr_1>MASlowCurr_1 && close_2>MAFastCurr_2 && MAFastCurr_2>MASlowCurr_2 && close_3>MAFastCurr_3&& MAFastCurr_3>MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_BUY;
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Two_TF); 
      if (close_2>MAFastCurr_2 && MAFastCurr_2>MASlowCurr_2 && close_3>MAFastCurr_3&& MAFastCurr_3>MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_BUY;

   //This is where you should insert your Entry Signal for SELL orders
   //Include a condition to open a sell order, the condition will have to set SignalEntry=SIGNAL_ENTRY_SELL
   
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Three_TF);
      if (close_1<MASlowCurr_1 && MAFastCurr_1<MASlowCurr_1 && close_2<MAFastCurr_2 && MAFastCurr_2<MASlowCurr_2 && close_3<MAFastCurr_3&& MAFastCurr_3<MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_SELL;
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Two_TF);
      if (close_2<MAFastCurr_2 && MAFastCurr_2<MASlowCurr_2&& close_3<MAFastCurr_3&& MAFastCurr_3<MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_SELL;
 
}

//Evaluate if there is an entry signal
void EvaluateEntry_Pullback(){
   int period     = Get_TimeFrame(TimeFrame);
   int period_2     = Get_TimeFrame(TimeFrame_2);
   int period_3     = Get_TimeFrame(TimeFrame_3);
   double close_3, close_1, close_2;
   close_1 = iClose(Symbol(),period,1);
   close_2 = iClose(Symbol(),period_2,1);
   close_3 = iClose(Symbol(),period_3,1);
   
   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   if(!IsSpreadOK) return;    //If the spread is too high don't give an entry signal
   if(UseTradingHours && !IsOperatingHours) return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
   //if(!IsNewCandle) return;      //If you want to provide a signal only if it's a new candle opening
   if(IsTradedThisBar) return;   //If you don't want to execute multiple trades in the same bar
   if(TotalOpenOrders>0) return; //If there are already open orders and you don't want to open more
   
   //Declaring the variables for the entry and exit check
   double MASlowPrev_1=iMA(Symbol(),period,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_1=iMA(Symbol(),period,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_1=iMA(Symbol(),period,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_1=iMA(Symbol(),period,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   double MASlowPrev_2=iMA(Symbol(),period_2,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_2=iMA(Symbol(),period_2,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_2=iMA(Symbol(),period_2,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_2=iMA(Symbol(),period_2,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   double MASlowPrev_3=iMA(Symbol(),period_3,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr_3=iMA(Symbol(),period_3,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev_3=iMA(Symbol(),period_3,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr_3=iMA(Symbol(),period_3,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);
   
   //This is where you should insert your Entry Signal for BUY orders
   //Include a condition to open a buy order, the condition will have to set SignalEntry=SIGNAL_ENTRY_BUY   
   //if(MAFastPrev_1<MASlowPrev_1 && MAFastCurr_1>MASlowCurr_1) SignalEntry=SIGNAL_ENTRY_BUY;

   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Three_TF); 
      if (close_1>MAFastCurr_1 && MAFastCurr_1>MASlowCurr_1 && close_2<MAFastCurr_2 && MAFastCurr_2<MASlowCurr_2 && close_3>MAFastCurr_3&& MAFastCurr_3>MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_BUY;
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Two_TF); 
      if (close_2<MAFastCurr_2 && MAFastCurr_2<MASlowCurr_2 && close_3>MAFastCurr_3&& MAFastCurr_3>MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_BUY;

   //This is where you should insert your Entry Signal for SELL orders
   //Include a condition to open a sell order, the condition will have to set SignalEntry=SIGNAL_ENTRY_SELL
   
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Three_TF);
      if (close_1<MASlowCurr_1 && MAFastCurr_1<MASlowCurr_1 && close_2>MAFastCurr_2 && MAFastCurr_2>MASlowCurr_2 && close_3<MAFastCurr_3&& MAFastCurr_3<MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_SELL;
   if (Signal_Types ==Trending&&Timeframe_Combination_Types==Two_TF);
      if (close_2>MAFastCurr_2 && MAFastCurr_2>MASlowCurr_2&& close_3<MAFastCurr_3&& MAFastCurr_3<MASlowCurr_3) SignalEntry=SIGNAL_ENTRY_SELL;
 
}

//Execute entry if there is an entry signal
void ExecuteEntry(){
   //If there is no entry signal no point to continue
   if(SignalEntry==SIGNAL_ENTRY_NEUTRAL) return;
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
   //If there is a Buy entry signal
   if(SignalEntry==SIGNAL_ENTRY_BUY&& Entry_Order_TypeXX ==At_Market){
      RefreshRates();   //Get latest rates
      Operation=OP_BUY; //Set the operation to BUY
      OpenPrice=Ask;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice-DefaultStopLoss*Point;
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate();
      }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice+DefaultTakeProfit*Point;
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate();
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits);
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits);
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits);   
      //Submit the order  
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
   }
   if(SignalEntry==SIGNAL_ENTRY_SELL&& Entry_Order_TypeXX ==At_Market){
      RefreshRates();   //Get latest rates
      Operation=OP_SELL; //Set the operation to SELL
      OpenPrice=Bid;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice+DefaultStopLoss*Point;
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate();
      }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice-DefaultTakeProfit*Point;
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate();
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits);
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits);
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits);   
      //Submit the order  
      SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice);
   }
   
}

//Execute entry if there is an entry signal
void ExecuteEntry_AskConfirm(){
   //If there is no entry signal no point to continue
   if(SignalEntry==SIGNAL_ENTRY_NEUTRAL) return;
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
   //If there is a Buy entry signal
   if(SignalEntry==SIGNAL_ENTRY_BUY && Entry_Order_TypeXX ==Ask_Confirm){
      RefreshRates();   //Get latest rates
      Operation=OP_BUY; //Set the operation to BUY
      OpenPrice=Ask;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice-DefaultStopLoss*Point;
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate();
      }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice+DefaultTakeProfit*Point;
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate();
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits);
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits);
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits);   
      //Submit the order  
      ShowConfirmWindow(Lots,OpenPrice,StopLossPrice,TakeProfitPrice);
   }
   if(SignalEntry==SIGNAL_ENTRY_SELL && Entry_Order_TypeXX ==Ask_Confirm){
      RefreshRates();   //Get latest rates
      Operation=OP_SELL; //Set the operation to SELL
      OpenPrice=Bid;    //Set the open price to Ask price
      //If the Stop Loss is fixed and the default stop loss is set
      if(StopLossMode==SL_FIXED && DefaultStopLoss>0){
         StopLossPrice=OpenPrice+DefaultStopLoss*Point;
      }
      //If the Stop Loss is automatic
      if(StopLossMode==SL_AUTO){
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=StopLossPriceCalculate();
      }
      //If the Take Profix price is fixed and defined
      if(TakeProfitMode==TP_FIXED && DefaultTakeProfit>0){
         TakeProfitPrice=OpenPrice-DefaultTakeProfit*Point;
      }
      //If the Take Profit is automatic
      if(TakeProfitMode==TP_AUTO){
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=TakeProfitCalculate();
      }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits);
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits);
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits);   
      //Submit the order  
      ShowConfirmWindow(Lots,OpenPrice,StopLossPrice,TakeProfitPrice);
   }
   
}

//Evaluate if there is an exit signal
void EvaluateExit(){
   SignalExit=SIGNAL_EXIT_NEUTRAL;
   
   //Declaring the variables for the evaluation of the exit
   double MASlowPrev=iMA(Symbol(),PERIOD_CURRENT,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,1);
   double MASlowCurr=iMA(Symbol(),PERIOD_CURRENT,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice,0);
   double MAFastPrev=iMA(Symbol(),PERIOD_CURRENT,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,1);
   double MAFastCurr=iMA(Symbol(),PERIOD_CURRENT,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice,0);

   //This is where you should include your exit signal for BUY orders
   //If you want, include a condition to close the open buy orders, condition will have to set SignalExit=SIGNAL_EXIT_BUY then return 
   if(MAFastPrev>MASlowPrev && MAFastCurr<MASlowCurr) SignalExit=SIGNAL_EXIT_BUY;

   //This is where you should include your exit signal for SELL orders
   //If you want, include a condition to close the open sell orders, condition will have to set SignalExit=SIGNAL_EXIT_SELL then return 
   if(MAFastPrev<MASlowPrev && MAFastCurr>MASlowCurr) SignalExit=SIGNAL_EXIT_SELL;

   //This is where you should include your exit signal for ALL orders
   //If you want, include a condition to close all the open orders, condition will have to set SignalExit=SIGNAL_EXIT_ALL then return 
   
}


//Execute exit if there is an exit signal
void ExecuteExit(){
   //If there is no Exit Signal no point to continue the routine
   if(SignalExit==SIGNAL_EXIT_NEUTRAL) return;
   //If there is an exit signal for all orders
   if(SignalExit==SIGNAL_EXIT_ALL){
      //Close all orders
      CloseAll(OP_ALL);
   }
   //If there is an exit signal for BUY order
   if(SignalExit==SIGNAL_EXIT_BUY){
      //Close all BUY orders
      CloseAll(OP_BUY);
   }
   //If there is an exit signal for SELL orders
   if(SignalExit==SIGNAL_EXIT_SELL){
      //Close all SELL orders
      CloseAll(OP_SELL);
   }

}


//Execute Trailing Stop to limit losses and lock in profits
void ExecuteTrailingStop(){
   //If the option is off then exit
   if(!UseTrailingStop) return;
   //If there are no open orders no point to continue the code
   if(TotalOpenOrders==0) return;
   //if(!IsNewCandle) return;      //If you only want to do the stop trailing once at the beginning of a new candle
   //Scan all the orders to see if some needs a stop loss update
   for(int i=0;i<OrdersTotal();i++) {
      //If there is a problem reading the order print the error, exit the function and return false
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return;
      }
      //If the order is not for the instrument on chart we can ignore it
      if(OrderSymbol()!=Symbol()) continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(OrderMagicNumber()!=MagicNumber) continue;
      //Define current values
      RefreshRates();
      double SLPrice=NormalizeDouble(OrderStopLoss(),Digits);     //Current Stop Loss price for the order
      double TPPrice=NormalizeDouble(OrderTakeProfit(),Digits);   //Current Take Profit price for the order
      double Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;       //Current Spread for the instrument
      double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point; //Minimum distance between current price and stop loss

      //If it is a buy order then trail stop for buy orders
      if(OrderType()==OP_BUY){
         //Include code to trail the stop for buy orders
         double NewSLPrice=0;
         
         //This is where you should include the code to assign a new value to the STOP LOSS
         double PSARCurr=iSAR(Symbol(),PERIOD_CURRENT,PSARStopStep,PSARStopMax,0);
         NewSLPrice=PSARCurr;
         
         double NewTPPrice=TPPrice;
         //Normalize the price before the submission
         NewSLPrice=NormalizeDouble(NewSLPrice,Digits);
         //If there is no new stop loss set then skip to next order
         if(NewSLPrice==0) continue;
         //If the new stop loss price is lower than the previous then skip to next order, we only move the stop closer to the price and not further away
         if(NewSLPrice<=SLPrice) continue;
         //If the distance between the current price and the new stop loss is not enough then skip to next order
         //This allows to avoid error 130 when trying to update the order
         if(Bid-NewSLPrice<StopLevel) continue;
         //Submit the update
         ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSLPrice,NewTPPrice);         
      }
      //If it is a sell order then trail stop for sell orders
      if(OrderType()==OP_SELL){
         //Include code to trail the stop for sell orders
         double NewSLPrice=0;
         
         //This is where you should include the code to assign a new value to the STOP LOSS
         double PSARCurr=iSAR(Symbol(),PERIOD_CURRENT,PSARStopStep,PSARStopMax,0);
         NewSLPrice=PSARCurr;
         
         double NewTPPrice=TPPrice;
         //Normalize the price before the submission
         NewSLPrice=NormalizeDouble(NewSLPrice,Digits);
         //If there is no new stop loss set then skip to next order
         if(NewSLPrice==0) continue;
         //If the new stop loss price is higher than the previous then skip to next order, we only move the stop closer to the price and not further away
         if(NewSLPrice>=SLPrice) continue;
         //If the distance between the current price and the new stop loss is not enough then skip to next order
         //This allows to avoid error 130 when trying to update the order
         if(NewSLPrice-Ask<StopLevel) continue;
         //Submit the update
         ModifyOrder(OrderTicket(),OrderOpenPrice(),NewSLPrice,NewTPPrice);         
      }
   }
   return;
}


//Check and return if the spread is not too high
void CheckSpread(){
   //Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   int SpreadCurr=(int)MarketInfo(Symbol(),MODE_SPREAD);
   if(SpreadCurr<=MaxSpread){
      IsSpreadOK=true;
   }
   else{
      IsSpreadOK=false;
   }
}


//Check and return if it is operation hours or not
void CheckOperationHours(){
   //If we are not using operating hours then IsOperatingHours is true and I skip the other checks
   if(!UseTradingHours){
      IsOperatingHours=true;
      return;
   }
   //Check if the current hour is between the allowed hours of operations, if so IsOperatingHours is set true
   if(TradingHourStart==TradingHourEnd && Hour()==TradingHourStart) IsOperatingHours=true;
   if(TradingHourStart<TradingHourEnd && Hour()>=TradingHourStart && Hour()<=TradingHourEnd) IsOperatingHours=true;
   if(TradingHourStart>TradingHourEnd && ((Hour()>=TradingHourStart && Hour()<=23) || (Hour()<=TradingHourEnd && Hour()>=0))) IsOperatingHours=true;
}


//Check if it is a new bar
datetime NewBarTime=TimeCurrent();
void CheckNewBar(){
   //NewBarTime contains the open time of the last bar known
   //if that open time is the same as the current bar then we are still in the current bar, otherwise we are in a new bar
   if(NewBarTime==Time[0]) IsNewCandle=false;
   else{
      NewBarTime=Time[0];
      IsNewCandle=true;
   }
}


//Check if there was already an order open this bar
datetime LastBarTraded;
void CheckTradedThisBar(){
   //LastBarTraded contains the open time the last trade
   //if that open time is in the same bar as the current then IsTradedThisBar is true
   if(iBarShift(Symbol(),PERIOD_CURRENT,LastBarTraded)==0) IsTradedThisBar=true;
   else IsTradedThisBar=false;
}


//Lot Size Calculator
void LotSizeCalculate(double SL=0){
   //If the position size is dynamic
   if(RiskDefaultSize==RISK_DEFAULT_AUTO){
      //If the stop loss is not zero then calculate the lot size
      if(SL!=0){
         double RiskBaseAmount=0;
         //TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
         TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);    
         //Define the base for the risk calculation depending on the parameter chosen    
         if(RiskBase==RISK_BASE_BALANCE) RiskBaseAmount=AccountBalance();
         if(RiskBase==RISK_BASE_EQUITY) RiskBaseAmount=AccountEquity();
         if(RiskBase==RISK_BASE_FREEMARGIN) RiskBaseAmount=AccountFreeMargin();
         //Calculate the Position Size
         LotSize=(RiskBaseAmount*MaxRiskPerTrade/100)/(SL*TickValue);
      }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0){
         LotSize=DefaultLotSize;
      }
   }
   //Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   LotSize=MathFloor(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
   //Limit the lot size in case it is greater than the maximum allowed by the user
   if(LotSize>MaxLotSize) LotSize=MaxLotSize;
   //Limit the lot size in case it is greater than the maximum allowed by the broker
   if(LotSize>MarketInfo(Symbol(),MODE_MAXLOT)) LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
   //If the lot size is too small then set it to 0 and don't trade
   if(LotSize<MinLotSize || LotSize<MarketInfo(Symbol(), MODE_MINLOT)) LotSize=0;
}


//Stop Loss Price Calculation if dynamic
double StopLossPriceCalculate(){
   double StopLossPrice=0;
   //Include a value for the stop loss, ideally coming from an indicator
   double PSARCurr=iSAR(Symbol(),PERIOD_CURRENT,PSARStopStep,PSARStopMax,0);
   StopLossPrice=PSARCurr;
   
   return StopLossPrice;
}


//Take Profit Price Calculation if dynamic
double TakeProfitCalculate(){
   double TakeProfitPrice=0;
   //Include a value for the take profit, ideally coming from an indicator
   return TakeProfitPrice;
}


//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, datetime Expiration=0){
   //Retry a number of times in case the submission fails
   for(int i=1; i<=OrderOpRetry; i++){
      //Set the color for the open arrow for the order
      color OpenColor=clrBlueViolet;
      if(Command==OP_BUY){
         OpenColor=clrChartreuse;
      }
      if(Command==OP_SELL){
         OpenColor=clrDarkTurquoise;
      }
      //Calculate the position size, if the lot size is zero then exit the function
      double SLPoints=0;
      //If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
      if(SLPrice>0) MathCeil(MathAbs(OpenPrice-SLPrice)/Point);
      //Call the function to calculate the position size
      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit
      if(LotSize==0) return;
      //Submit the order
      int res=OrderSend(Instrument,Command,LotSize,OpenPrice,Slippage,NormalizeDouble(SLPrice,Digits),NormalizeDouble(TPPrice,Digits),OrderNote,MagicNumber,Expiration,OpenColor);
      //If the submission is successful print it in the log and exit the function
      if(res){
         Print("TRADE - OPEN SUCCESS - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);
         break;
      }
      //If the submission failed print the error
      else{
         Print("TRADE - OPEN FAILED - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Stop ",SLPrice," Take ",TPPrice," Expiration ",Expiration);
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - NEW - error sending order, return error: ",Error," - ",ErrorText);
      } 
   }
   return;
}


//Modify Order Function adjusted to handle errors and retry multiple times
void ModifyOrder(int Ticket, double OpenPrice, double SLPrice, double TPPrice){
   //Try to select the order by ticket number and print the error if failed
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false){
      int Error=GetLastError();
      string ErrorText=GetLastErrorText(Error);
      Print("ERROR - SELECT TICKET - error selecting order ",Ticket," return error: ",Error);
      return;
   }
   //Normalize the digits for stop loss and take profit price
   SLPrice=NormalizeDouble(SLPrice,Digits);
   TPPrice=NormalizeDouble(TPPrice,Digits);
   //Try to submit the changes multiple times
   for(int i=1; i<=OrderOpRetry; i++){
      //Submit the change
      bool res=OrderModify(Ticket,OpenPrice,SLPrice,TPPrice,0,Blue);
      //If the change is successful print the result and exit the function
      if(res){
         Print("TRADE - UPDATE SUCCESS - Order ",Ticket," new stop loss ",SLPrice," new take profit ",TPPrice);
         break;
      }
      //If the change failed print the error with additional information to troubleshoot
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - UPDATE FAILED - error modifying order ",Ticket," return error: ",Error," - ERROR - ",ErrorText," - Open=",OpenPrice,
               " Old SL=",OrderStopLoss()," Old TP=",OrderTakeProfit(),
               " New SL=",SLPrice," New TP=",TPPrice," Bid=",MarketInfo(OrderSymbol(),MODE_BID)," Ask=",MarketInfo(OrderSymbol(),MODE_ASK));
      } 
   }
   return;
}


//Close Single Order Function adjusted to handle errors and retry multiple times
void CloseOrder(int Ticket, double Lots, double CurrentPrice){
   //Try to close the order by ticket number multiple times in case of failure
   for(int i=1; i<=OrderOpRetry; i++){
      //Send the close command
      bool res=OrderClose(Ticket,Lots,CurrentPrice,Slippage,Red);
      //If the close was successful print the resul and exit the function
      if(res){
         Print("TRADE - CLOSE SUCCESS - Order ",Ticket," closed at price ",CurrentPrice);
         break;
      }
      //If the close failed print the error
      else{
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - CLOSE FAILED - error closing order ",Ticket," return error: ",Error," - ",ErrorText);
      } 
   }
   return;
}


//Close All Orders of a specified type
const int OP_ALL=-1; //Constant to define the additional OP_ALL command which is the reference to all type of orders
void CloseAll(int Command){
   //If the command is OP_ALL then run the CloseAll function for both BUY and SELL orders
   if(Command==OP_ALL){
      CloseAll(OP_BUY);
      CloseAll(OP_SELL);
      return;
   }
   double ClosePrice=0;
   //Scan all the orders to close them individually
   //NOTE that the for loop scans from the last to the first, this is because when we close orders the list of orders is updated
   //hence the for loop would skip orders if we scan from first to last
   for(int i=OrdersTotal()-1; i>=0; i--) {
      //First select the order individually to get its details, if the selection fails print the error and exit the function
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      }
      //Check if the order is for the current symbol and was opened by the EA and is the type to be closed
      if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==Command) {
         //Define the close price
         RefreshRates();
         if(Command==OP_BUY) ClosePrice=Bid;
         if(Command==OP_SELL) ClosePrice=Ask;
         //Get the position size and the order identifier (ticket)
         double Lots=OrderLots();
         int Ticket=OrderTicket();
         //Close the individual order
         CloseOrder(Ticket,Lots,ClosePrice);
      }
   }
}


//Scan all orders to find the ones submitted by the EA
//NOTE This function is defined as bool because we want to return true if it is successful and false if it fails
bool ScanOrders(){
   //Scan all the orders, retrieving some of the details
   for(int i=0;i<OrdersTotal();i++) {
      //If there is a problem reading the order print the error, exit the function and return false
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return false;
      }
      //If the order is not for the instrument on chart we can ignore it
      if(OrderSymbol()!=Symbol()) continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(OrderMagicNumber()!=MagicNumber) continue;
      //If it is a buy order then increment the total count of buy orders
      if(OrderType()==OP_BUY) TotalOpenBuy++;
      //If it is a sell order then increment the total count of sell orders
      if(OrderType()==OP_SELL) TotalOpenSell++;
      //Increment the total orders count
      TotalOpenOrders++;
      //Find what is the open time of the most recent trade and assign it to LastBarTraded
      //this is necessary to check if we already traded in the current candle
      if(OrderOpenTime()>LastBarTraded || LastBarTraded==0) LastBarTraded=OrderOpenTime();
   }
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Get_TimeFrame(int BTF, bool mins = false)
  {
   int Periodo, Minutes;
   if(BTF==1)
     {
      Periodo = PERIOD_M1;
      Minutes = 1;
     }
   if(BTF==1)
     {
      Periodo = PERIOD_M5;
      Minutes = 5;
     }
   if(BTF==2)
     {
      Periodo = PERIOD_M15;
      Minutes = 15;
     }
   if(BTF==3)
     {
      Periodo = PERIOD_M30;
      Minutes = 30;
     }
   if(BTF==4)
     {
      Periodo = PERIOD_H1;
      Minutes = 60;
     }
   if(BTF==5)
     {
      Periodo = PERIOD_H4;
      Minutes = 240;
     }
   if(BTF==6)
     {
      Periodo = PERIOD_D1;
      Minutes = 1440;
     }
   if(BTF==7)
     {
      Periodo = PERIOD_W1;
      Minutes = 10080;
     }
   if(BTF==8)
     {
      Periodo = PERIOD_MN1;
      Minutes = 43200;
     }
   if(mins)
      return(Minutes);
   else
      return(Periodo);
  }
  
  