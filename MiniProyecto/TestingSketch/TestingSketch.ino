/*
  Serial Event example

 When new serial data arrives, this sketch adds it to a String.
 When a newline is received, the loop prints the string and
 clears it.

 A good test for this is to try it with a GPS receiver
 that sends out NMEA 0183 sentences.

 Created 9 May 2011
 by Tom Igoe

 This example code is in the public domain.

 http://www.arduino.cc/en/Tutorial/SerialEvent

 */

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete
byte menu = 0;

void setup() {
  pinMode(13, OUTPUT);
  // initialize serial:
  Serial.begin(9600);
  // reserve 200 bytes for the inputString:
  inputString.reserve(200);
  digitalWrite(13, LOW);
}

void loop() {
  // print the string when a newline arrives:
  if (stringComplete) {
    if(inputString == "Command1"){
      Serial.println("Received");
      digitalWrite(13, HIGH);
    }else if(inputString == "Command2"){
      Serial.println("Okay");
      digitalWrite(13, LOW);
    }else if(inputString == "Command3"){
      Serial.println("What?");
      digitalWrite(13, LOW);
      delay(1000);
      digitalWrite(13, HIGH);
      delay(1000);
      digitalWrite(13, LOW);
      delay(1000);
      digitalWrite(13, HIGH);
      delay(1000);
      digitalWrite(13, LOW);
    }
    // clear the string:
    inputString = "";
    stringComplete = false;
  }else{
    switch(menu){
      case 1:
        Serial.println("3.0");
        break;
      case 2:
        Serial.println("2.0");
        break;
      case 3:
        Serial.println("1.0");
        break;
    }
    delay(1000);
    menu++;
    if(menu == 4){
      menu = 0;
    }
  }
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }else{
      inputString += inChar;
    }
  }
}


