// i'm edtting  1. changing from 3D to 2D using 32x32 source, 2. add dump,

import processing.serial.*;
import processing.opengl.*;
import java.util.Date;
import controlP5.*;
import static javax.swing.JOptionPane.*;

//switch
boolean changeToHsb = true;
boolean serialConn = true; //dev mode ->false, when testing -> true

//To tab frontGUI..


void setup() {
  // Set frame rate.
  frameRate(100);
  surface.setResizable(true);
  //colormode rgb -> HSB
  if (changeToHsb) colorMode(HSB, 360, 100, 100);

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

  // above, all button method
  button();

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

        //dump data 
        if (!serialConn) data[i][j]=j;

        if (changeToHsb) fill(0, data[i][j]*multiplyConst, 100);//HSB white ->red
        //if (changeToHsb) fill(240-data[i][j]*multiplyConst, 100, 100);//HSB  adjust Hue, ref) blue (240) -> red (0)
        else fill(data[i][j]*multiplyConst, 0, 0); //RGB color mode

        noStroke();
        //origin
        //rect(sideSpace/2+j*recSize_space, upperSpace+i*recSize_space, recSize, recSize, radius);
        //->[test]no white space
        rect(sideSpace/2+j*recSize_space, upperSpace+i*recSize_space, recSize, recSize, radius);
      }
    }
    render=0;
  }
}

void serialEvent(Serial myPort) {
  if (serialConn) {

    // read a byte from the serial port:
    println("test");
    int inByte = myPort.read();
    //println("inByte : "+ inByte);
    //println(firstContact);
    println(serialCount);
    // Add the latest byte from the serial port to array:
    // In here, no 'A', because in arduino, if found 'A', send again 'Serial.write(valor);' so i think pure number in data. 
    serialInArray[serialCount] = inByte;

    serialCount++;

    // If we have 
    if (serialCount >= 256 ) {
      println("datawr");
      render = 1; // allow to render !!

      passedTime = millis() - savedTime;
      //if >loadingtime, >minInterval, then create a row
      if (millis()>loadingTime && passedTime > minInterval) {
        TableRow newRow = table.addRow();  
        newRow.setString("TimeStamp", timeStamp(millis()));
        for (int i=0; i<NUM_ROW; i++) {
          for (int j=0; j<NUM_COLUMN; j++) {
            temp[j] = serialInArray[i*16+j]; //array 1 dimension -> 2 dimension, how? : each row put in temp[], and put temp[] in data[][]
            data[i][j] = temp[j];
            String columnName = "(" + i + "," + j + ")";
            newRow.setInt(columnName, data[i][j]);
          }
        }
        savedTime = millis();
        myPort.write('A');// Send a capital A to request new sensor readings:
        serialCount = 0;// Reset serialCount:
      } else { //just draw, not write
        for (int i=0; i<NUM_ROW; i++) {
          for (int j=0; j<NUM_COLUMN; j++) {
            temp[j] = serialInArray[i*16+j]; 
            data[i][j] = temp[j];
          }
        }
        myPort.write('A');
        serialCount = 0;
      }
    }
  }
}

void exit() {
  //  println("stop");//do your thing on exit here
  super.exit();//let pro-cessing carry with it's regular exit routine
  //  //myPort.write('E');
}


//To tab frontValue..
