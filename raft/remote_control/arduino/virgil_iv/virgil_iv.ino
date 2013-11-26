
#include "pins.h"
#include "Motor.h"
#include "hmc6343.h"
#include <Wire.h>

Motor motor0(motor0_in_a, motor0_in_b, motor0_in_pwm);
Motor motor1(motor1_in_a, motor1_in_b, motor1_in_pwm);
Motor motor2(motor2_in_a, motor2_in_b, motor2_in_pwm);
Motor motor3(motor3_in_a, motor3_in_b, motor3_in_pwm);
Motor motor4(motor4_in_a, motor4_in_b, motor4_in_pwm);

hmc6343 compass;
//Xbee bee = Xbee(9600);

byte s[5];
byte d[5];

byte buffer[128];
int index=0;
int unreadSize=0;

float heading,roll,pitch;

long cycleTime = 0;
unsigned long cycleStart = 0;
unsigned long lastReceived = 0;  // safety: kill all motors if no packet is received in more than one second
const unsigned long cyclePeriod = 10;
void setup()  
{ 
  digitalWrite(13, HIGH);
  delay(10000);
  
  Serial.begin(115200);
  Serial.println("Serial 1 ready.");
  
  delay(10);
  Serial3.begin(57600);
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
  
  Serial.println("Testing compass");
  
     compass.readHeading(heading, roll, pitch);
        
     Serial.print("Heading: ");
     Serial.println(heading);
     Serial.print("Roll: ");
     Serial.println(roll);
     Serial.print("Pitch: ");
     Serial.println(pitch);
  
  Serial.println("Setup complete");
    digitalWrite(13, LOW);
} 

void loop()  
{   
  cycleStart = millis();
//  Serial.print(millis());
//  Serial.print(": ");
//  Serial.println(index);
  if(millis() - lastReceived > 500)
  {
    motor0.set(0, 0);
    motor1.set(0, 0);
    motor2.set(0, 0);
    motor3.set(0, 0);
    motor4.set(0, 0);
  }
  
  unreadSize = Serial3.available();
  
  if(unreadSize>0)
  {
    if(index + unreadSize > 127)
    {
      Serial.print('*');
      index = 0; 
    }
    
    for(int i = 0; i < unreadSize; i++)
    {
      buffer[index + i] = (byte)Serial3.read();
    }
    index = index + unreadSize;
  }

  if(index > 15)
  {
    int startIndex=-1; 
    int stopIndex=-1;
    
    // look for header & footer
    for (int i=0; i < index-3; i++) 
    {
      if ((buffer[i] == '<') && (buffer[i+1] == '[') && (buffer[i+2] == '(')) 
      {
        startIndex = i;
        break;
      }  
    }
    if(startIndex>-1)
    {
      for (int i=startIndex; i < index-2; i++) 
      {
        if (buffer[i] == ')' && buffer[i+1] == ']' && buffer[i+2] == '>') 
        {
          stopIndex = i;
          break;
        }
      }
    }
    
    if ( (startIndex != -1) && (stopIndex != -1)) 
    {
      if(stopIndex > startIndex )
      {
        // got packet, update last received!
        lastReceived = millis();      
        
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
        
        int delta = index - (stopIndex + 3);
      
        for(int i=0; i<delta; i++)
        {
          buffer[i] = buffer[stopIndex + 3 + i];
        }
        index = delta;            
      }
    } 
  } 
  
  compass.readHeading(heading, roll, pitch);      
      
  Serial3.print("H:");
  Serial3.print(heading);
  Serial3.print("!R:");
  Serial3.print(roll);
  Serial3.print("!P:");
  Serial3.print(pitch);
  Serial3.print('!');
  
  cycleTime = millis() - cycleStart;
  if (cycleTime < 0)
  {
    //handle rollover!
  }
  else if ( cycleTime < cyclePeriod )
  {
    delay(cyclePeriod - cycleTime);  
    //Serial.println(cycleTime);
  }
  else
  {
    Serial.print('!'); // missed deadline!
  }
}



