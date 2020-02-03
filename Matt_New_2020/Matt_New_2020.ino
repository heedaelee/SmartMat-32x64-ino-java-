// 2/3 여기에서 write 기능하고 checkSum 달아서 processing하고 연동 시켜야 구현됨!!

//놀라운 코드
int col_en[2] = {43, 45};
int col_s[4] = {2, 3, 4, 5};

int pulse = 11;
int row_en[4] = {47, 49, 51, 53};
int row_s[4] = {6, 7, 8, 9};

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
  // put your main code here, to run repeatedly:
  for (int i = 0; i < 32; i++) {
    RowSelect(i);
    for (int j = 0; j < 32 ; j++) {
      ColSelect(j);

      digitalWrite(pulse, HIGH);
      int data = analogRead(A0);
      //delay(1000);

      //digitalWrite(pulse, LOW);

      Serial.print(data);
      Serial.print(' ');
    }
    Serial.println(' ');
  }
  Serial.println(' ');
  Serial.println(' ');
  Serial.println(' ');
  Serial.println(' ');
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
