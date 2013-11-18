//#pragma once

#include "Arduino.h"

class Motor
{

  private:
    int m_pinInA;
    int m_pinInB;
    int m_pinPWM;

  public:

    Motor();

    Motor(const int& inA, const int& inB, const int& pwm)
    {
      m_pinInA = inA;
      m_pinInB = inB;
      m_pinPWM = pwm;
      
      pinMode(m_pinInA, OUTPUT);
      pinMode(m_pinInB, OUTPUT);

      analogWrite(m_pinPWM, 0);
    };

    ~Motor()
    {};

    void set(byte speed, byte mode)
    {
      if (0==mode)
      {
         // Brake to GND
         digitalWrite(m_pinInA, LOW);
         digitalWrite(m_pinInB, LOW);
      }
      else if (1==mode)
      {
          digitalWrite(m_pinInA, HIGH);
          digitalWrite(m_pinInB, LOW);
      }
      else if (2==mode)
      {
        // CCW
        digitalWrite(m_pinInA, LOW);
        digitalWrite(m_pinInB, LOW);
      }
      else if (3==mode)
      {
        // Brake to VCC
        digitalWrite(m_pinInA, LOW);
        digitalWrite(m_pinInB, HIGH);
      }
      else
      {
          digitalWrite(m_pinInA, LOW);
          digitalWrite(m_pinInB, LOW);
      }

      // TO DO: compensate for battery voltage variation

      analogWrite(m_pinPWM, speed);
    }
};


