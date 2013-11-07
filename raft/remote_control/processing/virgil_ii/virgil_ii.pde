import procontroll.*;
import java.util.Vector;
import processing.serial.*;
//import java.nio.ByteBuffer;

//import cc.arduino.*;

// TO DO:
// - udp
// - usar plugs para o handling dos eventos (screenshot)
// - passar GUI para controlP5
// - telemetria

Serial port;  // xbee

ControllIO controll;
ControllDevice controller;
ControllCoolieHat dpad;
Vector<ControllSlider> sliders = new Vector<ControllSlider>();  // 5 sliders
Vector<ControllButton> buttons = new Vector<ControllButton>();  // 11 buttons
Vector<String> sliders_names = new Vector<String>();
Vector<String> buttons_names = new Vector<String>(); //

void setup() 
{
  size(620, 220);
  background(127);
  smooth();
  frameRate(30);

  println(Serial.list());
  
  port = new Serial(this, Serial.list()[1], 9600);
  
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
  // 3 - Y
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

//public static byte [] floatToByteArray (float value)
//{  
//     return ByteBuffer.allocate(4).putFloat(value).array();
//}

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
  v[4] = -255*sliders.get(4).getValue();
  println(v);
  
  // telecommand data packet
  byte[] packet = new byte[16];
  // header
  packet[0] = '<';
  packet[1] = '<';
  packet[2] = '<';
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
  packet[13] = '>';
  packet[14] = '>';
  packet[15] = '>';
  
  port.write(packet);
  println("sent:");
  
  delay(50);  // 20Hz should be fine

  println("received:");
  while (port.available() > 0) {
    byte inByte = (byte)port.read();
    print(inByte+" ");
  }
  println("");
}

