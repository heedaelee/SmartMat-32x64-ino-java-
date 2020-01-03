//Mux control pins for analog signal (SIG_pin) default for arduino mini pro
//디지털 입출력 핀 
const byte s0 = 10;
const byte s1 = 16;
const byte s2 = 14;
const byte s3 = 15;

//Mux control pins for Output signal (OUT_pin) default for arduino mini pro
//디지털 입출력 핀 
const byte w0 = 9; 
const byte w1 = 8; 
const byte w2 = 7;
const byte w3 = 6;                                                                           
     
//Mux in "SIG" pin default for arduino mini pro 
//col 아날로그 데이터 입력핀 mc : 0번핀(A0)
const byte SIG_pin = A0; 

//Mux out "SIG" pin default for arduino mini pro
//row 아날로그 데이터 입력핀 mc : 4번핀(A6)
const byte OUT_pin = A3;

//Row and Column pins default for arduino mini pro
//STATUS_pin 상황핀, setup에서 HIGH 줌,  if mc : 디지털 입출력 2,3 핀 사용
//COL_pin 데이터 최종 Serial.write 후 LOW->HIGH !
const byte STATUS_pin = 3;
const byte COL_pin = 2;

const boolean muxChannel[16][4]={
    {0,0,0,0}, //channel 0 ex: {pin1, pin2, pin3, pin4}
    {1,0,0,0}, //channel 1
    {0,1,0,0}, //channel 2
    {1,1,0,0}, //channel 3
    {0,0,1,0}, //channel 4
    {1,0,1,0}, //channel 5
    {0,1,1,0}, //channel 6
    {1,1,1,0}, //channel 7
    {0,0,0,1}, //channel 8
    {1,0,0,1}, //channel 9
    {0,1,0,1}, //channel 10
    {1,1,0,1}, //channel 11
    {0,0,1,1}, //channel 12
    {1,0,1,1}, //channel 13
    {0,1,1,1}, //channel 14
    {1,1,1,1}  //channel 15 //15x15 so, unused
  };


//incoming serial byte
int inByte = 0;

int valor = 0;               //variable for sending bytes to processing
int calibra[16][16];         //Calibration array for the min values of each od the 225 sensors.
int minsensor=254;          //Variable for staring the min array
int multiplier = 254;
//int pastmatrix[16][16];

void setup(){
    
  pinMode(s0, OUTPUT); 
  pinMode(s1, OUTPUT); 
  pinMode(s2, OUTPUT);  
  pinMode(s3, OUTPUT); 
  
  pinMode(w0, OUTPUT); 
  pinMode(w1, OUTPUT); 
  pinMode(w2, OUTPUT); 
  pinMode(w3, OUTPUT); 
  
  pinMode(OUT_pin, OUTPUT); 
  
  pinMode(STATUS_pin, OUTPUT);
  pinMode(COL_pin, OUTPUT);

  
  digitalWrite(s0, LOW);
  digitalWrite(s1, LOW);
  digitalWrite(s2, LOW);
  digitalWrite(s3, LOW);
  
  digitalWrite(w0, LOW);
  digitalWrite(w1, LOW);
  digitalWrite(w2, LOW);
  digitalWrite(w3, LOW);
  
  digitalWrite(OUT_pin, HIGH);
  digitalWrite(STATUS_pin, HIGH);
  digitalWrite(COL_pin, HIGH);
  
 
  
  Serial.begin(115200);
  
  Serial.println("\n\Calibrating...\n");
  
  // Full of 0's of initial matrix
  for(byte j = 0; j < 16; j ++){ 
    writeMux(j);
    for(byte i = 0; i < 16; i ++){
      calibra[j][i] = 0; //초기값 0 주입
//      Serial.println("cali 확인"); 
//      Serial.print(calibra[j][i]);
      }
  }
  
  // Calibration
  for(byte k = 0; k < 50; k++){  //50번 돌림
    for(byte j = 0; j < 16; j ++){ 
      writeMux(j);
      for(byte i = 0; i < 16; i ++)
        calibra[j][i] = calibra[j][i] + readMux(i); // 0 + col 기본값
    }
  }
  
  //Print averages
  for(byte j = 0; j < 16; j ++){ 
    writeMux(j); //초기 test, row
    for(byte i = 0; i < 16; i ++){
      calibra[j][i] = calibra[j][i]/50; //calibra 후 기본값/50 해서 대입 -> 작은수로 만듦      
      if(calibra[j][i] < minsensor)
        minsensor = calibra[j][i]; //센서 최소값
      Serial.print(calibra[j][i]); //최소값 출력
      Serial.print("\t");
    }
  Serial.println(); 
  }
  
  Serial.println();
  Serial.print("Minimum Value: ");
  Serial.println(minsensor);
  Serial.println();
  
  establishContact();// send a byte to establish contact until receiver responds
 
  digitalWrite(COL_pin, LOW);
}


void loop(){
  //Loop through and read all 16 values
  //Reports back Value at channel 6 is: 346
  if (Serial.available() > 0){
    Serial.println("test");
    inByte = Serial.read();//처음 start letter
    
    if(inByte == 'A'){
    
      for(int j = 15; j >= 0; j--){ //왜 15부터?? -> 16x16이니까.
        writeMux(j);
        
        for(int i = 0; i < 15; i++){
          valor = readMux(i); //int
          //Saturation sensors, 최대값 조절
          int limsup = 450;
          if(valor > limsup)
            valor = limsup;
            
          if(valor < calibra[j][i])//기본값이 calibra[][]
            valor = calibra[j][i];  
          
          valor = map(valor,minsensor, limsup,1,254); //1~254까지 calibration
          
          if(valor < 150)
            valor = 0; //값의 최소 최대 조절
          if(valor > 254) //150~254
            valor = 254;
          
          Serial.write(valor);
//          Serial.println(valor);
          digitalWrite(COL_pin,!digitalRead(COL_pin)); //column pin 반전,LOW->HIGH
        } 
      }
    }
        
  }
}


int readMux(byte channel){
  byte controlPin[] = {s0, s1, s2, s3};

  //loop through the 4 sig
  for(int i = 0; i < 4; i ++){
    digitalWrite(controlPin[i], muxChannel[channel][i]);
  }

  //read the value at the SIG pin
  
  int val = analogRead(SIG_pin);
  //  Serial.println(val);
  //return the value
  return val;
}

void writeMux(byte channel){//ch 0~14 for loop, mat row
  byte controlPin[] = {w0, w1, w2, w3}; //pin 9,8,7,6

  //loop through the 4 sig
  for(byte i = 0; i < 4; i ++){
    digitalWrite(controlPin[i], muxChannel[channel][i]);
  }              //pin 9,8,7,6     [] 0,1,2,3
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.write('A');   // send a capital A
    delay(300);
  }
}
