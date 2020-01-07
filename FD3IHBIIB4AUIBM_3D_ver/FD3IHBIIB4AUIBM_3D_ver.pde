// This example code is in the public domain.

import processing.serial.*;
import processing.opengl.*;


int bgcolor;                 // Background color
int fgcolor;                 // Fill color
Serial myPort;                       // The serial port
int[] serialInArray = new int[256];    // Where we'll put what we receive
int[] pastInArray = new int [256];
float[][] colorTarget   = new float[3][255];
float[][] currentColor   = new float[3][255];
PVector[][] vertices = new PVector[16][16];
float[] verticesTZ = new float[16];
float w = 30;
float ease = 0.75; 

int serialCount = 0;                 // A count of how many bytes we receive
int xpos, ypos;                  // Starting position of the ball
boolean firstContact = false;        // Whether we've heard from the microcontroller
int tiempoant;
int render=0;
int dif=0;

void setup() {
  size(960, 750, OPENGL);  // Stage size
  noStroke();      // No border on the next thing draw
  
  
  // Print a list of the serial ports, for debugging purposes:
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  
  //depending on computers.. select port
  myPort = new Serial(this, Serial.list()[0], 115200);
  
  for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 16; i++) {
            vertices[i][j] = new PVector( i*w, j*w, 0); //w=30
          //16x16
        }
    }
      
}

void draw() {

  if (render==1) {
    
    translate(width/4, 100); // moving reference coordinates, move x -> width/4, move y -> 100
    rotateX(0.5);//x-yis a bit rotate
    //rotateX(PI/10);
    background(0);
    for (int j=0; j<15; j++) { //j can be used for row or col. 0~14 rotated. so, 64 line: by row, 71 line : col
      beginShape(QUAD_STRIP);
      for (int i=0; i<16; i++) { //maybe i can be used for row or col. 0~15 rotated. so, 64 line : by col, 71 line :row
          stroke(255);
     
          fill(serialInArray[j*16+i], 0, 0); //draw[16][16], 14*16+16 = 240,why???????fu**  16*16 = 256 

          verticesTZ[i] = serialInArray[j*16+i];// data moved. put the x array(->verticesTZ[16])
          // every each one row saved
          vertices[i][j].z += (verticesTZ[i]-vertices[i][j].z)*ease; //ease = 0.75
                            // verticesTZ[i] : is the lastest Serial saved data  vs vertices[i][j].z : is the last data saved 
          vertex( vertices[i][j].x, vertices[i][j].y, vertices[i][j].z); //2 vertex -> in x-axis, draw line between x and x+1  
          vertex( vertices[i][j+1].x, vertices[i][j+1].y, vertices[i][j+1].z);
        }
         endShape(CLOSE);
        //        println();
      }
      render=0;
  }
}

void serialEvent(Serial myPort) {
  
  // read a byte from the serial port:
  int inByte = myPort.read();
  //println(inByte);
  //println("serial ok"+inByte);
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller. 
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('A');       // ask for more
    }
  } else {
    // Add the latest byte from the serial port to array:

      serialInArray[serialCount] = inByte;

    serialCount++;

    // If we have 3 bytes:
    if (serialCount >= 256 ) {
      println(millis()-tiempoant);
      tiempoant = millis();
      
      render = 1;
    
      // Send a capital A to request new sensor readings:
      myPort.write('A');
      // Reset serialCount:
      serialCount = 0;
    }
  }
}
