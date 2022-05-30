
#include <CapacitiveSensor.h>
#define buzzer 0

// Set the Send Pin & Receive Pin.
CapacitiveSensor   cs_12_11 = CapacitiveSensor(12, 11);
CapacitiveSensor   cs_12_10 = CapacitiveSensor(12, 10);
CapacitiveSensor   cs_12_9 = CapacitiveSensor(12, 9);
CapacitiveSensor   cs_12_8 = CapacitiveSensor(12, 8);
CapacitiveSensor   cs_12_7 = CapacitiveSensor(12, 7);
CapacitiveSensor   cs_12_6 = CapacitiveSensor(12, 6);
CapacitiveSensor   cs_12_5 = CapacitiveSensor(12, 5);
//CapacitiveSensor   cs_12_4 = CapacitiveSensor(12, 4);



int stato =0;
int pressure = 1000;



void setup() {
  // turn off autocalibrate on channel 1 - just as an example
  Serial.begin(9600);
  cs_12_11.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_10.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_9.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_8.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_7.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_6.set_CS_AutocaL_Millis(0xFFFFFFFF);
  cs_12_5.set_CS_AutocaL_Millis(0xFFFFFFFF);
  //cs_12_4.set_CS_AutocaL_Millis(0xFFFFFFFF);

  


}

void loop() {
  // put your main code here, to run repeatedly:
  // Set the sensitivity of the sensors.
  long touch11 =  cs_12_11.capacitiveSensor(pressure); 
  long touch10 =  cs_12_10.capacitiveSensor(pressure);
  long touch9 =  cs_12_9.capacitiveSensor(pressure);
  long touch8 =  cs_12_8.capacitiveSensor(pressure);
  long touch7 =  cs_12_7.capacitiveSensor(pressure);
  long touch6 =  cs_12_6.capacitiveSensor(pressure);
  long touch5 =  cs_12_5.capacitiveSensor(pressure);
  //long touch4 =  cs_12_4.capacitiveSensor(pressure);
  
  




  // When we touched the sensor, the buzzer will produce a tone.
  if (touch11 > pressure && stato!=1) {
    
    Serial.print(0);
    stato=1;
  }
  
  if (touch10 > pressure && stato!=2) {  
    
    Serial.print(1);
     stato=2;


  }
 
  if (touch9 > pressure && stato!=3) {
    
    Serial.print(2);
    stato=3;

  }
  if (touch8> pressure && stato!=4) {
    
    Serial.print(3);
    stato=4;

  }

  if (touch7 > pressure && stato!=5) {
    
    Serial.print(4);
    stato=5;

  }
  if (touch6 > pressure && stato!=6) {
    
    Serial.print(5);
    stato=6;

  }

  if (touch5 > pressure && stato!=7) {
    
    Serial.print(6);
    stato=7 ;
  }
  /*
  if (touch4 > pressure && stato!=8) {
    
    Serial.print(7);
    stato =8;
    
  }
  */
  
  
  
  
 
  

  // When we didn't touch it, no tone is produced.
  //if (touch11 <= pressure  &  touch10 <= pressure &  touch9 <= pressure &  touch8 <= pressure &  touch7 <= pressure &  touch6 <= pressure &  touch5 <= pressure /*&  touch4 <= pressure*/)
    if(touch11 <= pressure  &  touch10 <= pressure &  touch9 <= pressure &  touch8 <= pressure &  touch7 <= pressure &  touch6 <= pressure &  touch5 <= pressure )
    stato=0;
    delay(100);

}
