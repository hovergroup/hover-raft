
#include "pins.h"
#include "Motor.h"
#include "hmc6343.h"

Motor motor0(motor0_in_a, motor0_in_b, motor0_in_pwm);
Motor motor1(motor1_in_a, motor1_in_b, motor1_in_pwm);
Motor motor2(motor2_in_a, motor2_in_b, motor2_in_pwm);
Motor motor3(motor3_in_a, motor3_in_b, motor3_in_pwm);
Motor motor4(motor4_in_a, motor4_in_b, motor4_in_pwm);

//Xbee bee = Xbee(9600);

byte s[5];
byte d[5];

byte buffer[128];
int index=0;
int unreadSize=0;

void setup()  
{ 
  digitalWrite(13, HIGH);
  delay(1000);
  
  Serial.begin(9600);
  
  Serial.println("Serial 1 ready.");
  
  delay(10);
  Serial3.begin(9600);
  Serial.println("Serial 3 ready.");
  delay(1000);
  
  Serial.println("testing motors - CW");
  motor0.set(100, 1);
  motor1.set(100, 1);
  motor2.set(100, 1);
  motor3.set(100, 1);
  motor4.set(100, 1);
    
  delay(100);
  Serial.println("testing motors - CCW");
  delay(100);
  motor0.set(100, 3);
  motor1.set(100, 3);
  motor2.set(100, 3);
  motor3.set(100, 3);
  motor4.set(100, 3);
  
  delay(100);
  motor0.set(0, 0);
  motor1.set(0, 0);
  motor2.set(0, 0);
  motor3.set(0, 0);
  motor4.set(0, 0);
  
  Serial.println("Setup complete");
    digitalWrite(13, LOW);
} 

void loop()  
{ 
  unreadSize = Serial3.available();
  //Serial.println(index);
  if(index + unreadSize > 127)
  {
    Serial.println("Buffer overflow!");
    index = 0; 
  }
  for(int i = 0; i < unreadSize; i++)
  {
    buffer[index+i] = (byte)Serial3.read();
    //Serial.print(".");
  }
  index+=unreadSize;
  
  if(index > 16)
  {
    Serial.println(index);
    
    int startIndex=-1; 
    int stopIndex=-1;
    
    // look for header & footer
    for (int i=0; i < index-3; i++) 
    {
      if ((buffer[i] == '<') && (buffer[i+1] == '<') && (buffer[i+2] == '<')) 
      {
        startIndex = i;
        break;
      }
      
    }
    for (int i=startIndex; i < index-2; i++) 
    {
      if (buffer[i] == '>' && buffer[i+1] == '>' && buffer[i+2] == '>') 
      {
        stopIndex = i;
      }
    }
    
    if (startIndex != -1 && stopIndex != -1) 
    {
      if(stopIndex > startIndex )
      {
        Serial.println('P');
        for(int i=0; i<5; i+=1)
        {
          s[i] = buffer[startIndex + 3 + 2*i];
          d[i] = buffer[startIndex + 4 + 2*i];
        }
        Serial.println("M");
        motor1.set(s[0], d[0]);
        motor2.set(s[1], d[1]);
        motor3.set(s[2], d[2]);
        motor4.set(s[3], d[3]);
        motor0.set(s[4], d[4]);
        
        int delta = index - stopIndex + 2;
      
        for(int i=0; i<delta; i++)
        {
          buffer[startIndex + i] = buffer[stopIndex+3+i];
          //buffer[i] = buffer[stopIndex+3+i];
        }
        index-=16;
        //index = delta;
      }
    } 
  } 
 delay(10); 
}



