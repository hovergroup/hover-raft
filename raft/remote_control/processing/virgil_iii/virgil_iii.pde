import procontroll.*;
import java.util.Vector;
import processing.serial.*;

Serial port;  // xbee

ControllIO controll;
ControllDevice controller;
ControllCoolieHat dpad;
Vector<ControllSlider> sliders = new Vector<ControllSlider>();  // 5 sliders
Vector<ControllButton> buttons = new Vector<ControllButton>();  // 11 buttons
Vector<String> sliders_names = new Vector<String>();
Vector<String> buttons_names = new Vector<String>(); //
Vector<Character> incomingBuffer = new Vector<Character>();
//String incomingBuffer;

void setup() 
{
  size(620, 220);
  background(127);
  smooth();
  frameRate(30);

  println(Serial.list());
  
  port = new Serial(this, Serial.list()[1], 57600);
  
  controll = ControllIO.getInstance(this);
  controller = controll.getDevice("Controller (Xbox 360 Wireless Receiver for Windows)");
  
  controller.setTolerance(0.0020f); // dead band: the Left Thumb X axis has a spot where it stays at 17% actuation with no input.

  // Add sliders
  //
  // 0 - Left thumb: +up, -down (Y Axis)
  // 1 - Left thumb: +left, -right (X Axis)
  // 2 - Right thumb: +up, -down (Y Rotation)
  // 3 - Right thumb: +left, -right (X Rotation)
  // 4 - Triggers: +rt, -lt (Z Axis)
  for (int i=0; i<5; i++)
  {
    sliders.add(controller.getSlider(i));
    sliders_names.add(controller.getSlider(i).getName());
  }

  // Add buttons
  //
  // 0 - A
  // 1 - B
  // 2 - X
  // 3 - Y``
  // 4 - LB
  // 5 - RB
  // 6 - Back
  // 7 - Start
  // 8 - Left thumb
  // 9 - Right thumb
  for (int i=0; i<10; i++)
  {
    buttons.add(controller.getButton(i));
    buttons_names.add(controller.getButton(i).getName());
  }

  // 10 - 
  dpad = controller.getCoolieHat(10);
  dpad.setMultiplier(20);
  
  //controller.plug(this, "handleAPress", ControllIO.ON_PRESS, 1);
}

byte unsign( float val ) 
{ 
  return (byte)( val > 127 ? val - 256 : val ); 
}

void draw() 
{
  // "fade" effect
  stroke(255);
  fill(255, 255, 255, 50); 
  rect(0, 0, width, height);

  fill(0);
  stroke(0);
  // sliders
  for (int i=0; i<5; i++)
  {
    text(sliders.get(i).getName(), 20, 20 + i*40);
    rect(200, 20 + i*40, 100*sliders.get(i).getValue(), 20);
  }

  // buttons
  for (int i=0; i<5; i++)
  {
    fill(0);
    text(buttons.get(i).getName(), 320+60*i, 100);
    if (buttons.get(i).pressed())
    {
      fill(255);
    }
    rect(320+60*i, 110, 20, 20);
  }
  for (int i=5; i<10; i++)
  {
    fill(0);
    text(buttons.get(i).getName(), 320+60*(i-5), 160);
    if (buttons.get(i).pressed())
    {
      fill(255);
    }
    rect(320+60*(i-5), 170, 20, 20);
  }
  
  fill(255);
  ellipse(520, 40, 40, 40);

  fill(0);
  text(dpad.getName(), 320, 20);
  ellipse(520+dpad.getX(), 40+dpad.getY(), 20, 20);

   println("");
  
  // mixing of control signals to get motor demands
  float[] v = new float[5];
  v[0] = 255*sliders.get(1).getValue();  
  v[1] = 255*sliders.get(0).getValue();
  v[2] = -255*sliders.get(3).getValue();
  v[3] = -255*sliders.get(2).getValue();
  v[4] = 255*sliders.get(4).getValue();
  //println(v);
  
  // dead zone (xbox controller has a deadzone of up to 20% of full axis)
  for(int i=0; i<5; i++)
  {
    if(abs(v[i])<20)
    {
     v[i]=0;
    } 
  }
  
  // telecommand data packet
  byte[] packet = new byte[16];
  // header
  packet[0] = '<';
  packet[1] = '[';
  packet[2] = '(';
  // payload
  for(int i = 0; i<5; i++)
  {
    packet[3+2*i] = unsign(v[i]);
    if(v[i]>0)
    {
      packet[3+2*i+1]= unsign(1);
    }
    else
    {
      packet[3+2*i] = unsign(-v[i]);
      packet[3+2*i+1] = unsign(3);
    }

  }
  // footer
  packet[13] = ')';
  packet[14] = ']';
  packet[15] = '>';
  
  port.write(packet);
  
  //delay(100);  // 20Hz should be fine

  print(second());
  print('.');
  print(millis());
  println(':');
  
  while (port.available() > 0) 
  {
    incomingBuffer.add((char)port.read());
  }
  //parse
  //println(incomingBuffer);
  incomingBuffer.clear(); 
 
 delay(50); 
}

