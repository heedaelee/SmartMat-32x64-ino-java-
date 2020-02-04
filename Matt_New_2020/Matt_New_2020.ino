// 2/3 여기에서 write 기능하고 checkSum 달아서 processing하고 연동 시켜야 구현됨!!

//놀라운 코드
int col_en[2] = {43, 45};
int col_s[4] = {2, 3, 4, 5};

int pulse = 11;
int row_en[4] = {47, 49, 51, 53};
int row_s[4] = {6, 7, 8, 9};

boolean print = false; //print test하려면 true, 프로세싱 통신 하려면 false

//incoming serial byte
int inByte = 0;

int valor = 0;               //variable for sending bytes to processing
int calibra[16][16];         //Calibration array for the min values of each od the 225 sensors.
int initMaximum = 0;        //Variable for starting the min array

void setup() {
  // put your setup code here, to run once:
  for (int i = 2; i < 12; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
  for (int i = 43; i < 54; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
  Serial.begin(115200);
}


void loop() {
  if (Serial.available() > 0) {
    inByte = Serial.read();//처음 start letter
    if (inByte == 'C') { //1. 프로세싱에서 connect 버튼 누르면 'C'받음
      Serial.write('A');   // 2.'A'를 프로세싱에 보냄
      delay(300);
    }
    if (inByte == 'A') {//3.프로세싱에서 port.clear 후 'A' 전송해주면 데이터 전송 시작
      for (int i = 0; i < 32; i++) {
        RowSelect(i);
        for (int j = 0; j < 32 ; j++) {
          ColSelect(j);

          digitalWrite(pulse, HIGH);
          int data = analogRead(A0);

          //delay(1000);
          //digitalWrite(pulse, LOW);

          int maximum = 1024;
          valor = map(valor, initMaximum, maximum, 0, 100);//data 조절
          if (valor < 0)
            valor = 0; //값의 최소 최대 조절
          if (valor > 100) //0~100
            valor = 100;

          if (!print) {
            Serial.write(data);
          }

          if (print) {
            Serial.print(data);
            Serial.print(' ');
          }
        }
        if (print) {
          Serial.println(' ');
        }
      }
      if (print) {
        Serial.println(' ');
        Serial.println(' ');
        Serial.println(' ');
        Serial.println(' ');
      }
    }
  }
}

void ColSelect(int ch_num) {
  if (ch_num < 16) {
    digitalWrite(col_en[0], LOW);
    digitalWrite(col_en[1], HIGH);
  }
  if (ch_num > 15) {
    digitalWrite(col_en[0], HIGH);
    digitalWrite(col_en[1], LOW);
  }


  for (int i = 0; i < 4; i++) {
    digitalWrite(col_s[i], bitRead(ch_num, i));
  }
}

void RowSelect(int ch_num) {
  if (ch_num < 16) {
    digitalWrite(row_en[0], LOW);
    digitalWrite(row_en[1], HIGH);
    digitalWrite(row_en[2], HIGH);
    digitalWrite(row_en[3], HIGH);
  }
  if (ch_num > 15 && ch_num < 32) {
    digitalWrite(row_en[0], HIGH);
    digitalWrite(row_en[1], LOW);
    digitalWrite(row_en[2], HIGH);
    digitalWrite(row_en[3], HIGH);
  }
  if (ch_num > 31 && ch_num < 48) {
    digitalWrite(row_en[0], HIGH);
    digitalWrite(row_en[1], HIGH);
    digitalWrite(row_en[2], LOW);
    digitalWrite(row_en[3], HIGH);
  }
  if (ch_num > 47 && ch_num < 64) {
    digitalWrite(row_en[0], HIGH);
    digitalWrite(row_en[1], HIGH);
    digitalWrite(row_en[2], HIGH);
    digitalWrite(row_en[3], LOW);
  }

  for (int i = 0; i < 4; i++) {
    digitalWrite(row_s[i], bitRead(ch_num, i));
  }
}
