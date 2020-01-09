// i'm edtting  1. changing from 3D to 2D using 32x32 source, 2. add dump,

import processing.serial.*;
import processing.opengl.*;
import java.util.Date;
import controlP5.*;
import static javax.swing.JOptionPane.*;

ControlP5 cp5;
PFont font;

// Matirx array constant.
int NUM_COLUMN = 16;
int NUM_ROW =16;
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
int one_recSize_space = 14;
float one_recSize = 11.5;
int firstyLayer1 = 40;

//button
int sBtnX;
int sBtnY;
int rBtnX;
int rBtnY;
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

//dev mode ->false, when testing -> true
final boolean serialConn = true;

void settings() {
  // Set size of window : size(width, Height)
  size(sideSpace + one_recSize_space * NUM_COLUMN, upperSpace + belowSpace + one_recSize_space * NUM_ROW);

  //button location assignment
  sBtnX = sideSpace/2 + (one_recSize_space * NUM_COLUMN-(sBtnWidth*2+10))/2;
  sBtnY = firstyLayer1-10;
  rBtnX = sBtnX+sBtnWidth+btnSpace;
  rBtnY = sBtnY;
  minBtnX = rBtnX+sBtnWidth+width/8;
  minBtnY = sBtnY;
  minBtnWidth = sBtnWidth*2/3;
  minBtnHeight = sBtnHeight*1/2;
  timeTextX = minBtnX;
  timeTextY = height/40;
}

void setup() {
  // Set frame rate.
  frameRate(100);
  surface.setResizable(true);
  //colormode rgb -> HSB
  //colorMode(HSB, 360, 100, 100);

  font = createFont("Arial Bold", 48);
  //Create csv first row's column
  table = new Table();
  table.addColumn("TimeStamp");

  for (int i=0; i<NUM_ROW; i++) {
    for (int j=0; j<NUM_COLUMN; j++) {
      String columnName = "(" + i + "," + j + ")";
      table.addColumn(columnName);
    }
  }
  //save current time
  savedTime = millis();

  // create a new button 
  cp5 = new ControlP5(this);

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

  // Select serial port.
  if (serialConn) {
    try {
      printArray(Serial.list());// Show up all possible serial ports.
      int i = Serial.list().length;
      if (i != 0) {
        // need to check which port the inst uses , for now we'll just let the user decide
        for (int j = 0; j < i; j++ ) {
          COMlist[j] = Serial.list()[j];
          println(COMlist[j]);
        }

        portName = (String)showInputDialog(null, "포트를 선택해 주세요.", "메시지", INFORMATION_MESSAGE, null, COMlist, COMlist[0]);
        println("portName : "+portName);
        if (portName == null) exit();
        if (portName.isEmpty()) exit();

        if (serialConn) println(portName);
        myPort = new Serial(this, portName, 115200); // change baud rate to your liking
        
        // for restart throw A
        println("restart");
        myPort.write('A');
        firstContact=true;
        myPort.clear();
        
      } else {
        showMessageDialog(frame, "PC에 연결된 포트가 없습니다");
        exit();
      }
    }
    catch (Exception e)
    { //Print the type of error 
      showMessageDialog(frame, "COM port 를 사용할 수 없습니다. \n (maybe in use by another program)");
      println("Error:", e);
      exit();
    }
  }
}

void draw() {
  if (render==1 || serialConn == false ) {
    // Set background color as gray.
    background(100);

    // Set font size and color.
    textFont(font, 11);
    fill(255);
    getDate();
    text(str(y)+"."+str(m)+"."+str(d)+". "+str(h)+":"+str(mn)+":"+str(s), timeTextX, timeTextY);

    // Set font size and color.
    textFont(font, 10);
    fill(255);
    //text(progVer, width-70, height-15);
    text("FPS :"+int(frameRate), 20, 60);
    text("Connected port: " + portName, 20, 40);

    //Draw rectangular for sensor indication.
    for (int i=0; i<NUM_ROW; i++) {
      for (int j=0; j<NUM_COLUMN; j++) {
        fill(data[i][j]*multiplyConst, 0, 0);
        rect(sideSpace/2+j*one_recSize_space, upperSpace+i*one_recSize_space, one_recSize, one_recSize, 3);
        //if(i==32&&j==31){text("1", 33+j*one_recSize_space, 68+i*one_recSize_space);}
        //if(i==0&&j==15){text("16", 20+j*one_recSize_space, 65+i*one_recSize_space);}
      }
    }
    render=0;
  }
}

int multiplyConst = 18;
int loadingTime = 2500;

void serialEvent(Serial myPort) {
  if (serialConn) {
    // read a byte from the serial port:
    int inByte = myPort.read();
    println("inByte : "+ inByte);
    println(firstContact);
    println(serialCount);
    //println("serial ok"+inByte);
    // if this is the first byte received, and it's an A,
    // clear the serial buffer and note that you've
    // had first contact from the microcontroller. 
    // Otherwise, add the incoming byte to the array:
    
    if (firstContact == false) {
      
      if (inByte == 'A') { 
        println("탄다");
        myPort.clear();          // clear the serial port buffer
        firstContact = true;     // you've had first contact from the microcontroller
        myPort.write('A');       // ask for more
      }
    } else {
      
      // Add the latest byte from the serial port to array:
      // In here, no 'A', because in arduino, if found 'A', send again 'Serial.write(valor);' so i think pure number in data. 
      serialInArray[serialCount] = inByte;
      serialCount++;

      // If we have 
      if (serialCount >= 256 ) {
        println("datawr");
        render = 1; // allow to render !!

        passedTime = millis() - savedTime;
        //if loadingtime, minInterval, then create a row
        if (millis()>loadingTime && passedTime > minInterval) {
          TableRow newRow = table.addRow();  
          newRow.setString("TimeStamp", timeStamp(millis()));
          for (int i=0; i<NUM_ROW; i++) {
            for (int j=0; j<NUM_COLUMN; j++) {
              temp[j] = serialInArray[i*16+j]; //array 1 dimension -> 2 dimension
              data[i][j] = temp[j];
              String columnName = "(" + i + "," + j + ")";
              newRow.setInt(columnName, data[i][j]);
            }
          }
          savedTime = millis();
          // Send a capital A to request new sensor readings:
          myPort.write('A');
          // Reset serialCount:
          serialCount = 0;
        } else { //just draw, not write
          for (int i=0; i<NUM_ROW; i++) {
            for (int j=0; j<NUM_COLUMN; j++) {
              temp[j] = serialInArray[i*16+j]; //array 1 dimension -> 2 dimension
              data[i][j] = temp[j];
            }
          }
          myPort.write('A');
          serialCount = 0;
        }
      }
    }
  }
}

//SAVE button click event
public void SAVE() {
  println("data saved");
  getDate();
  saveTable(table, "data/"+str(y)+"_"+str(m)+"_"+str(d)+"_"+str(h)+"_"+str(mn)+"_"+str(s)+".csv");
  String dataPath = dataPath(""); 
  showMessageDialog(null, "저장되었습니다"+"\n 저장경로: "+dataPath, "메시지", INFORMATION_MESSAGE);
  table.clearRows();
}

//RESET button click event
public void RESET() {
  println("data reset");
  showMessageDialog(null, "데이터 로우를 초기화합니다", "메시지", INFORMATION_MESSAGE);
  table.clearRows();
}

// Set escape event for terminate program.
void keyPressed() {
  if (key == 27) { // 27 means ESC key
    getDate();
    saveTable(table, "data/"+str(y)+"_"+str(m)+"_"+str(d)+"_"+str(h)+"_"+str(mn)+"_"+str(s)+".csv");
    //myPort.dispose();
    exit(); // Stops the program
  }
}

// Get current date and hours.
void getDate() {
  d = day();    // Values from 1 - 31
  m = month();  // Values from 1 - 12
  y = year();   // 2003, 2004, 2005, etc.
  s = second();  // Values from 0 - 59
  mn = minute();  // Values from 0 - 59
  h = hour();    // Values from 0 - 23
}

//first column in csv file.
String timeStamp(int MS) {
  float seconds = float(nfs((MS % 60000)/1000f, 2, 2));
  int minutes = (MS / (1000*60)) % 60;
  int hours = ((MS/(1000*60*60)) % 24);                      
  return hours+": " +minutes+ ": "+ seconds;
}
