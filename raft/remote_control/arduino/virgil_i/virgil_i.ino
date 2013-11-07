#include "pins.h"
#include "Motor.h"

Motor motor1(motor1_in_a, motor1_in_b, motor1_in_pwm);
Motor motor2(motor2_in_a, motor2_in_b, motor2_in_pwm);
Motor motor3(motor3_in_a, motor3_in_b, motor3_in_pwm);
Motor motor4(motor4_in_a, motor4_in_b, motor4_in_pwm);

byte s[4];
byte d[4];

byte buffer[128];
int index=0;
int unreadSize=0;

void setup()  
{ 
  delay(1000);
  
  Serial.begin(9600);
  Serial3.begin(9600);
  delay(1000);
  
  Serial.println("testing motors - CW");
  
  motor1.set(100, 1);
  motor2.set(100, 1);
  motor3.set(100, 1);
  motor4.set(100, 1);
  delay(1000);
  Serial.println("testing motors - CCW");
  delay(1000);
  motor1.set(100, 3);
  motor2.set(100, 3);
  motor3.set(100, 3);
  motor4.set(100, 3);
  delay(1000);
  motor1.set(0, 1);
  motor2.set(0, 1);
  motor3.set(0, 1);
  motor4.set(0, 1);
  Serial.println("Setup complete");
} 

void loop()  
{ 
  unreadSize = Serial3.available();
  if(index + unreadSize > 127)
  {
    Serial.println("Buffer overflow!");
    index = 0; 
  }
  for(int i = 0; i < unreadSize; i++)
  {
    buffer[index+i] = (byte)Serial3.read();
  }
  index+=unreadSize;
  
  if(index > 14)
  {
    Serial.println("");
    for(int i = 0; i< index; i++)
    {
      Serial.print((char)buffer[i]);
    }
    
    int startIndex=-1; 
    int stopIndex=-1;
    
    // look for header & footer
    for (int i=0; i < index-3; i++) 
    {
      if ((buffer[i] == '<') && (buffer[i+1] == '<') && (buffer[i+2] == '<')) 
      {
        startIndex = i;
      }
      
    }
     for (int i=startIndex; i < index-3; i++) 
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
        for(int i=0; i<8; i+=2)
        {
          s[i] = buffer[startIndex + i + 3];
          d[i] = buffer[startIndex + i + 4];
        }
        Serial.println("M");
        motor1.set(s[0], d[0]);
        motor2.set(s[1], d[1]);
        motor3.set(s[2], d[2]);
        motor4.set(s[3], d[3]);
        
        int delta = index - stopIndex + 2;
      
        for(int i=0; i<delta; i++)
        {
          buffer[startIndex + i] = buffer[stopIndex+3+i];
        }
      
        index-=14;
      }
    } 
  } 
 delay(10); 
}
