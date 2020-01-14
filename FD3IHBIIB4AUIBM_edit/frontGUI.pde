ControlP5 cp5;
PFont font;

// Matirx array constant.
int NUM_COLUMN = 32;
int NUM_ROW =64;
int NUM_SENSOR = NUM_COLUMN * NUM_ROW;


Serial myPort;               // The serial port
int[] serialInArray = new int[256];    // Where we'll put what we receive
int[][] data = new int[NUM_ROW][NUM_COLUMN];
int[] temp = new int[16];

Table table;

//Set-up interval saving time
int savedTime;
int minInterval = 500; //1s = 1000
int passedTime;

int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller
int render=0;

// Variables for current date & time.
int d;    // Values from 1 - 31
int m;  // Values from 1 - 12
int y;   // 2003, 2004, 2005, etc.
int s;  // Values from 0 - 59
int mn;  // Values from 0 - 59
int h;    // Values from 0 - 23

//layout
int sideSpace = 80;
int upperSpace = 80;
int belowSpace = 20;
int recSize_space = 13;
float recSize = 12.9;
int radius = 0;
int firstyLayer1 = 40;

//button
int sBtnX;
int sBtnY;
int rBtnX;
int rBtnY;
int reBtnX;
int reBtnY;
int sBtnWidth = 60;
int sBtnHeight = 30;
int btnSpace = 10;
int minBtnX;
int minBtnY;
int minBtnWidth;
int minBtnHeight;
int timeTextX;
int timeTextY;

String portName;
String COMlist [] = new String[Serial.list().length];

int multiplyConst = 20;
int loadingTime = 2500;

void settings() {
  // Set size of window : size(width, Height)
  size(sideSpace + recSize_space * NUM_COLUMN, upperSpace + belowSpace + recSize_space * NUM_ROW);

  //button location assignment
  sBtnX = sideSpace/2 + (recSize_space * NUM_COLUMN-(sBtnWidth*3+10))/2;
  sBtnY = firstyLayer1-10;
  rBtnX = sBtnX+sBtnWidth+btnSpace;
  rBtnY = sBtnY;
  reBtnX = rBtnX+sBtnWidth+btnSpace;
  reBtnY = sBtnY;
  minBtnX =reBtnX+sBtnWidth+btnSpace+width/12;
  minBtnY = sBtnY;
  minBtnWidth = sBtnWidth*2/3;
  minBtnHeight = sBtnHeight*1/2;
  timeTextX = minBtnX;
  timeTextY = height/40;
}

void button() {
  // draw save button
  Button saveBtn= cp5.addButton("SAVE")
    .setPosition(sBtnX, sBtnY)
    .setSize(sBtnWidth, sBtnHeight);
  saveBtn.getCaptionLabel().setFont(font).setSize(13);

  // draw reset button
  Button resetBtn= cp5.addButton("RESET")
    .setPosition(rBtnX, rBtnY)
    .setSize(sBtnWidth, sBtnHeight);
  resetBtn.getCaptionLabel().setFont(font).setSize(13);

  Button connectBtn= cp5.addButton("CONNECT")
    .setPosition(reBtnX, reBtnY)
    .setSize(sBtnWidth, sBtnHeight);
  resetBtn.getCaptionLabel().setFont(font).setSize(13);

  // draw minInterval slider button
  cp5.addSlider("minInterval").setCaptionLabel("Min_Interval")
    .setRange(100, 1000)
    .setPosition(minBtnX, minBtnY)
    .setSize(minBtnWidth, minBtnHeight);

  // draw Sensitivity slider button  
  cp5.addSlider("multiplyConst").setCaptionLabel("Sensitivity")
    .setRange(1, 40)
    .setPosition(minBtnX, minBtnY+20)
    .setSize(minBtnWidth, minBtnHeight);
}
