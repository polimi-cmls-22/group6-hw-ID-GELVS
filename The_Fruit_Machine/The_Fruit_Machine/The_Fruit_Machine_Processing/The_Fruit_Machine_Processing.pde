/*===============================================================================*/
// oscP5 is an OSC implementation for the programming environment processing.
import oscP5.*;
//A network library for processing which supports UDP, TCP and Multicast.
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress Supercollider;

/*=================================================================================*/
int pulsante_x= 480;
int pulsante_y= 270;
int smusso =10;
int key_x=50;
int key_y=50;
/*.................................................................................*/
int button = -1;
int angle = 0;
int scv = -1;
int buttonState = 100;
int loop = 0;
int bpm = 128;

int[] kickArr = {0,0,0,0};
int[] snareArr = {0,0,0,0};
int[] clapArr = {0,0,0,0};
int[] hitHatArr = {0,0,0,0};
/*--------------------------------------------------------------------------------*/
boolean drum = true;
/*--------------------------------------------------------------------------------*/
float graphicsValue = 100;
/*--------------------------------------------------------------------------------*/
/*===============================================================================*/
void setup() {
     size(1200, 700);
     String[] fontList = PFont.list();
     printArray(fontList);
     frameRate(25);
     oscP5 = new OscP5(this,12000);
     Supercollider = new NetAddress("127.0.0.1",57120);
}

void draw() {
  
  background(0);
  int i=1;
  int j=1;
  //float col = random (255);
  
  while (i<2)
  { 
    while (j<2){  
    blendMode(DIFFERENCE);
    fill (255,0,0);
    rect(i*170,j*200, 150, 100);
    fill(0,255,0);
    rect( i*150+5, j*205+5, 150, 100);
    fill(0,0,255);
    rect( i*160+10, j*210+10, 150, 100);
    
    fill (255,0,0);
    rect(i*430,j*200, 150, 100);
    fill(0,255,0);
    rect( i*410+5, j*205+5, 150, 100);
    fill(0,0,255);
    rect( i*420+10, j*210+10, 150, 100);
     j=j+1;}
    i= i+1;  
  }
  
  /* TITLE */
  fill(255);
  textSize(65);
  text("THE FRUITMACHINE", 30, 120);
  PFont font;
  font = createFont("Verdana Grassetto Corsivo",20);
  textFont(font);
  
  
  /* DRUM - PIANO MODE */
  if(drum){
      fill(#ffff00);
      text("Drums",190,270);
      fill(50,50,50);
      text("Instrument", 435, 270);
      
      fill(255);
      textSize(15);
      text("KICK",100, 550);
      text("SNARE",180, 550);
      text("CLAP",260, 550);
      text("HIT-HAT",330, 550);
      text("BGLASS",420, 550);
      text("BELL",510, 550);
      text("LASER",580, 550);
  }else{
      fill(50,50,50);
      text("Drums",190,270);
      fill(#ffff00);
      text("Instrument", 435, 270);
      
      fill(255);
      textSize(15);
      text("C5",110, 550);
      text("D5",190, 550);
      text("E5",270, 550);
      text("F5",350, 550);
      text("G5",430, 550);
      text("A5",520, 550);
      text("B5",590, 550);
  }
  
  /* KEYBOARD BUTTONS */
  /*Button 0*/
  if(button == 0){
    fill(#ff0000); //rosso
    rect(100, 450, key_x, key_y, 10);
  }else{
    fill(255);
    rect(100, 450, key_x, key_y, 10);
  }
  /*Button 1*/
  if(button == 1){
    fill(#ffff00); //giallo
    rect(180, 450, key_x, key_y, 10);
  }else{
    fill(255);
    rect(180, 450, key_x, key_y, 10);
  }
  /*Button 2*/
   if(button == 2){
    fill(#ff00ff); //fucsia
    rect(260, 450, 50, 50, 10);
  }else{
    fill(255);
    rect(260, 450, 50, 50, 10);
  }
  /*Button 3*/
 if(button == 3){
  fill(#0000ff); //blu
  rect(340, 450, 50, 50, 10);
  }else{
    fill(255);
    rect(340, 450, 50, 50, 10);
  }
  /*Button 4*/
  if(button == 4){
  fill(#00ffff); //celeste
  rect(420, 450, 50, 50, 10);
  }else{
    fill(255);
    rect(420, 450, 50, 50, 10);
  }
  /*Button 5*/
  if(button == 5){
  fill(#00ff00); //verde
  rect(500, 450, 50, 50, 10);
  }else{
    fill(255);
    rect(500, 450, 50, 50, 10);
  }
  /*Button 6*/
  if(button == 6){
  fill(100,100,100);
  rect(580, 450, 50, 50, 10);
}else{
    fill(255);
    rect(580, 450, 50, 50, 10);
  }
  
  /* BUTTONS FOR INSTRUMENTS */ 
  fill(255);
  textSize(20);
  text("INSTRUMENTS", 830, 150);
  
  if(buttonState == 100){fill(0,255,0);  textSize(12);  text("BASS SIMPLE", 860, 180);}     else{fill(255);}  rect(800, 200, 50, 50);   
  if(buttonState == 101){fill(0,255,0);  textSize(12);  text("RING", 890, 180);}            else{fill(255);}  rect(860, 200, 50, 50);  
  if(buttonState == 102){fill(0,255,0);  textSize(12);  text("BASS TRANCE", 860, 180);}     else{fill(255);}  rect(920, 200, 50, 50);  
  if(buttonState == 103){fill(0,255,0);  textSize(12);  text("PIANO", 890, 180);}           else{fill(255);}  rect(980, 200, 50, 50);
  //not used
  /*
  if(buttonState == 104){fill(0,255,0);} else{fill(255);}  rect(800, 260, 50, 50);   
  if(buttonState == 105){fill(0,255,0);} else{fill(255);}  rect(860, 260, 50, 50);  
  if(buttonState == 106){fill(0,255,0);} else{fill(255);}  rect(920, 260, 50, 50);  
  if(buttonState == 107){fill(0,255,0);} else{fill(255);}  rect(980, 260, 50, 50);
  /*
  //not used
  
  /* BUTTONS FOR LOOP MACHINE */ 
  fill(255);
  textSize(20);
  text("LOOP MACHINE", 830,380);
  
  if(loop == 0){fill(0,255,0); textSize(12);  text("PLAY", 1060, 390);} else{fill(255,0,0); textSize(12);  text("STOP", 1060, 390);}  rect(1050, 400, 50, 50);
  
  /* BPM BUTTON */
  fill(255);
  textSize(15);
  text("BPM", 1060,500);
  rect(1050, 510, 50, 55);
  text(str(bpm), 1055,540);
  
  rect(1110, 510, 25, 25);
  textSize(15);
  text("+", 1115,527);
  
  fill(255);
  rect(1110, 540, 25, 25);
  textSize(15);
  text("-", 1120,557);
  /* ===================== */
  
  fill(255);
  textSize(15);
  text("KICK", 710,430);
  
  fill(255);
  textSize(15);
  text("SNARE", 710,490);
  
  fill(255);
  textSize(15);
  text("CLAP", 710,540);
  
  fill(255);
  textSize(15);
  text("HIT-HAT", 710,610);
  
  /*Kick buttons loop*/
  if(kickArr[0] == 1){fill(0,0,255);} else{fill(255);}  rect(800, 400, 50, 50);
  if(kickArr[1] == 1){fill(0,0,255);} else{fill(255);}  rect(860, 400, 50, 50);  
  if(kickArr[2] == 1){fill(0,0,255);} else{fill(255);}  rect(920, 400, 50, 50);  
  if(kickArr[3] == 1){fill(0,0,255);} else{fill(255);}  rect(980, 400, 50, 50); 
  /*Snare buttons loop*/
  if(snareArr[0] == 1){fill(0,0,255);} else{fill(255);}  rect(800, 460, 50, 50);
  if(snareArr[1] == 1){fill(0,0,255);} else{fill(255);}  rect(860, 460, 50, 50);  
  if(snareArr[2] == 1){fill(0,0,255);} else{fill(255);}  rect(920, 460, 50, 50);  
  if(snareArr[3] == 1){fill(0,0,255);} else{fill(255);}  rect(980, 460, 50, 50);
  
  /*Clap buttons loop*/
  if(clapArr[0] == 1){fill(0,0,255);} else{fill(255);}  rect(800, 520, 50, 50);
  if(clapArr[1] == 1){fill(0,0,255);} else{fill(255);}  rect(860, 520, 50, 50);  
  if(clapArr[2] == 1){fill(0,0,255);} else{fill(255);}  rect(920, 520, 50, 50);  
  if(clapArr[3] == 1){fill(0,0,255);} else{fill(255);}  rect(980, 520, 50, 50);
  
  /*HitHat buttons loop*/
  if(hitHatArr[0] == 1){fill(0,0,255);} else{fill(255);}  rect(800, 580, 50, 50);
  if(hitHatArr[1] == 1){fill(0,0,255);} else{fill(255);}  rect(860, 580, 50, 50);  
  if(hitHatArr[2] == 1){fill(0,0,255);} else{fill(255);}  rect(920, 580, 50, 50);  
  if(hitHatArr[3] == 1){fill(0,0,255);} else{fill(255);}  rect(980, 580, 50, 50);
  
  
  /* Draw graphics elements */
    if (button != -1) {
    // draw ellipses and rects
    stroke(1200-graphicsValue/2, 600-graphicsValue*abs(sin(graphicsValue)), 256-graphicsValue/4);
    strokeWeight(4);
    fill(256-graphicsValue/2, 256-graphicsValue, 256-graphicsValue*abs(sin(graphicsValue)));
    translate(width/2, height/2);
    rotate(graphicsValue%64);
    rect(graphicsValue%64, graphicsValue%64, random(100,200), random(100,200), 6);
    ellipse(graphicsValue%32, graphicsValue%32, random(100,200), graphicsValue*abs(sin(graphicsValue))%128);
    angle += 5;
    float val = cos(radians(angle)) * 12.0;
    for (int a = 0; a < 360; a += 75) {
        float xoff = cos(radians(a)) * val;
        float yoff = sin(radians(a)) * val;
        fill(random(0,255),random(0,255),100);
      ellipse(random(0,1000) + xoff, random(0,500) + yoff, val, val);
      ellipse(random(100,300) + xoff, random(0,500) + yoff, val, val);
      ellipse(random(100,500) + xoff, random(0,500) + yoff, val, val);
    }
    fill(0);
    ellipse(random(0,1200), random(0,600), 2, 2);
    ellipse(random(0,500), random(0,600), 500, 200);
    ellipse(random(0,400), random(0,600), 500, 500);
  }
}
/*============================================================================*/
/* Function OSC messages from Supercollider to Processing */
void oscEvent(OscMessage theOscMessage){
    scv = theOscMessage.get(0).intValue();
    switch(scv) {
      case -1: 
        drum = true;
        break;
      case -2: 
        drum = false;
        break;
      case 0:
          button = 0;
           graphicsValue = random(200,500);
          break;
      case 1:
          button = 1;
          graphicsValue = random(200,500);
          break;
      case 2:
          button = 2;
          graphicsValue = random(200,500);
          break;
      case 3:
          button = 3;
          graphicsValue = random(200,500);
          break;
      case 4:
          button = 4;
          graphicsValue = random(200,500);
          break;
      case 5:
          button = 5;
          graphicsValue = random(200,500);
          break;
       case 6:
          button = 6;
          graphicsValue = random(200,500);
          break;
      case -3:
          button = -1;
          break;
      default:
        drum = true;
        break;
    }
 }
 
 /* Function prepare OSC message */
 void sendMessage(int value ){
    OscMessage control = new OscMessage("/msgPro");
    control.add(value);
    oscP5.send(control,Supercollider);
  }
  
   /* Function prepare OSC message */
 void sendDrumMessage(int value){
    OscMessage control = new OscMessage("/msgDrum");
    control.add(value);
    oscP5.send(control,Supercollider);
  }
  
    /* Function sends BPM */
 void sendBPMMessage(int value){
    OscMessage control = new OscMessage("/msgBPM");
    control.add(value);
    oscP5.send(control,Supercollider);
  }
  
 /* Function for send the loop  */ 
  void sendMessageLoop(int go, int[] loopKickArray, int[] loopSnareArray, int[] loopClapArray, int[] loopHitHatArray){
    OscMessage message = new OscMessage("/msgLoopArray");
    message.add(go);
    message.add(loopKickArray);
    message.add(loopSnareArray);
    message.add(loopClapArray);
    message.add(loopHitHatArray);
    oscP5.send(message,Supercollider);
  };
  
  /*Function for set 0 or 1 */
  int onoff(int value){
    if(value == 0){return 1;}
    else{return 0;}
  }
   
/* Function for send messages from Processing GUI to Supercollider when a "button" is touched */ 
void mouseClicked() {
  
  /* Change Drum and Piano */
  if(mouseX>170 && mouseX <170+150 && mouseY>200 && mouseY <200+100){  drum = true;  sendDrumMessage(1);}
  if(mouseX>410 && mouseX <410+150 && mouseY>200 && mouseY <200+100){  drum = false;  sendDrumMessage(0);}
  
  /* Row 1 */
  if(mouseX>800 && mouseX <800+50 && mouseY>200 && mouseY <200+50){ sendMessage(0);buttonState= 100;}
  if(mouseX>860 && mouseX <860+50 && mouseY>200 && mouseY <200+50){ sendMessage(1);buttonState= 101;}
  if(mouseX>920 && mouseX <920+50 && mouseY>200 && mouseY <200+50){ sendMessage(2);buttonState= 102;}
  if(mouseX>980 && mouseX <980+50 && mouseY>200 && mouseY <200+50){ sendMessage(3);buttonState= 103;}
  /* Row 2 */
  //Not used
  /*
  if(mouseX>800 && mouseX <800+50 && mouseY>260 && mouseY <260+50){ sendMessage(0);buttonState= 104;}
  if(mouseX>860 && mouseX <860+50 && mouseY>260 && mouseY <260+50){ sendMessage(1);buttonState= 105;}
  if(mouseX>920 && mouseX <920+50 && mouseY>260 && mouseY <260+50){ sendMessage(2);buttonState= 106;}
  if(mouseX>980 && mouseX <980+50 && mouseY>260 && mouseY <260+50){ sendMessage(3);buttonState= 107;}
  */
  //Not used
  
  /*LOOP BUTTON*/
  if(mouseX>1050 && mouseX <1050+50 && mouseY>400 && mouseY <400+50){
    sendMessageLoop(loop,kickArr,snareArr,clapArr,hitHatArr);
    loop = onoff(loop);    
  }
  /* BPM */
  if(mouseX>1110 && mouseX <1110+25 && mouseY>510 && mouseY <510+25){   bpm = bpm +1;   sendBPMMessage(bpm);}
  if(mouseX>1110 && mouseX <1110+25 && mouseY>540 && mouseY <540+25){  bpm = bpm -1;    sendBPMMessage(bpm);}
  
  /*Kick LOOP*/
  if(mouseX>800 && mouseX <800+50 && mouseY>400 && mouseY <400+50 && loop == 0 ){kickArr[0] = onoff(kickArr[0]);}
  if(mouseX>860 && mouseX <860+50 && mouseY>400 && mouseY <400+50 && loop == 0){kickArr[1] = onoff(kickArr[1]);}
  if(mouseX>920 && mouseX <920+50 && mouseY>400 && mouseY <400+50 && loop == 0){kickArr[2] = onoff(kickArr[2]);}
  if(mouseX>980 && mouseX <980+50 && mouseY>400 && mouseY <400+50 && loop == 0){kickArr[3] = onoff(kickArr[3]);}
  
  /*Snare LOOP*/
  if(mouseX>800 && mouseX <800+50 && mouseY>460 && mouseY <460+50 && loop == 0 ){snareArr[0] = onoff(snareArr[0]);}
  if(mouseX>860 && mouseX <860+50 && mouseY>460 && mouseY <460+50 && loop == 0){snareArr[1] = onoff(snareArr[1]);}
  if(mouseX>920 && mouseX <920+50 && mouseY>460 && mouseY <460+50 && loop == 0){snareArr[2] = onoff(snareArr[2]);}
  if(mouseX>980 && mouseX <980+50 && mouseY>460 && mouseY <460+50 && loop == 0){snareArr[3] = onoff(snareArr[3]);}
  
  /*ClapLOOP*/
  if(mouseX>800 && mouseX <800+50 && mouseY>520 && mouseY <520+50 && loop == 0 ){clapArr[0] = onoff(clapArr[0]);}
  if(mouseX>860 && mouseX <860+50 && mouseY>520 && mouseY <520+50 && loop == 0){clapArr[1] = onoff(clapArr[1]);}
  if(mouseX>920 && mouseX <920+50 && mouseY>520 && mouseY <520+50 && loop == 0){clapArr[2] = onoff(clapArr[2]);}
  if(mouseX>980 && mouseX <980+50 && mouseY>520 && mouseY <520+50 && loop == 0){clapArr[3] = onoff(clapArr[3]);}
  
  /*HitHat LOOP*/
  if(mouseX>800 && mouseX <800+50 && mouseY>580 && mouseY <580+50 && loop == 0 ){hitHatArr[0] = onoff(hitHatArr[0]);}
  if(mouseX>860 && mouseX <860+50 && mouseY>580 && mouseY <580+50 && loop == 0){hitHatArr[1] = onoff(hitHatArr[1]);}
  if(mouseX>920 && mouseX <920+50 && mouseY>580 && mouseY <580+50 && loop == 0){hitHatArr[2] = onoff(hitHatArr[2]);}
  if(mouseX>980 && mouseX <980+50 && mouseY>580 && mouseY <580+50 && loop == 0){hitHatArr[3] = onoff(hitHatArr[3]);}
  }
  

 
