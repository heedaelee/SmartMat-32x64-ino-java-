
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

public void CONNECT() {
  println("connect");
  table.clearRows();
  // for connecting throw A
  println("restart");
  println(serialCount);
  myPort.clear();
  myPort.write('A');
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
