/*

A STRIP IS A DATA STRUCTURE. IT CORRESPONDS TO A LINEAR STRIP OF CONNECTED LEDS. THERE ARE FOUR TYPES OF STRIPS PER LIGHTING UNIT: EDGE FACE, DOWN FACE, STRIPE FACE AND REFLECTIVE FACE

Each Strip is 24bits

8 bits for red  = 9
8 bits for green  = 16
8 bits for blue = 24
8 bit for the mode channel (00000000 = direct mode, 1-127 = various speeds of dot flow and 127-255 = reverse dot flow at various speeds)
8 bits for the mask channel (where 11111111 is all channels on and 000000000 all channels off) = 32

1) EDGE FACE STRIPS ARE PHYSICALLY ON THE SIDES OF THE UNITS AND CAN BE MASKED INTO 8 SUB STRIPS THAT CAN BE INDIVIDUALLY CONTROLLED

  The masks are 0x10000000, 0x010000000, 0x00100000, 0x00010000, 0x00001000, 0x00000100 0x00000010, 0x00000001
  
2) REFLECTIVE FACE STRIPS ARE PHYSICALLY ON THE TOP OF THE UNITS (ROUGHLY SIMILAR TO THE EDGE FACE) AND CAN BE MASKED INTO 8 SUB STRIPS THAT CAN BE INDIVIDUALLY CONTROLLED
  The masks are 0x10000000, 0x010000000, 0x00100000, 0x00010000, 0x00001000, 0x00000100 0x00000010, 0x00000001

3) DOWNWARD FACE STRIPS ARE PHYSICALLY ON THE BOTTOM OF THE UNITS AND CAN BE MASKED INTO 4 SUB STRIPS THAT CAN BE INDIVIDUALLY CONTROLLED
  The masks are 0x10000000, 0x010000000, 0x00100000, 0x00010000, 0x00001000, 0x00000100 0x00000010, 0x00000001

4) STRIPE FACE STRIPS ARE PHYSICALLY ON THE BOTTOM OF THE UNITS/ EACH UNIT HAS A DIFFERNT NUMBER OF STRIPE STRIPS (FROM 0-3) THAT RUN IN IRREGULAR ANGLES ACROSS THE DOWNWARD FACE OF THE UNIT. EACH STRIPE IS A FACE.
  The masks are 0x10000000, 0x010000000, 0x00100000
  
THE STRIP OBJECT IS ACTUALLY THE DATA STRUCTURE THAT HOLDS THE VALUES THAT ARE SENT OUT DMX TO THE LIGHTS.
*/
 class Strip {
  
  int rChan;
  int gChan;
  int bChan;
  int modeChan;
  int maskChan;
  int tog; // THIS IS A MASTER ON/OFF BOOLEAN THAT ALLOWS YOU TO MANUALLY TURN THE STRIP OF ON THE PHYSICAL OCTAGON UNIT
  boolean stripDiagToggle;
  
  Strip(int tempr, int tempg, int tempb, int tempMo, int tempMa, int sTog, boolean dTog ) {
    rChan = tempr;
    gChan = tempg;
    bChan = tempb;
    modeChan = tempMo;
    maskChan = tempMa;
    tog=sTog;
    stripDiagToggle = dTog;
  }
}
