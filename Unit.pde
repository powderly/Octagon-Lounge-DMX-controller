class Unit {

  int unit_ID;
  Strip stripe;
  Strip edge;
  Strip downward;
  Strip reflective;
  int unit_type;
  int sub_strips;
  //SCREEN LOCATION FOR UNIT
  int xloc;
  int yloc;
  //PIXEL OFFSETS to MAKE GUI ELEMENTS DRAWN TO SCREEN
  int unitSize = 40;
  int indicatorSize = 20;
  int indicatorSize2 = 10;
  int textOffset=23;
  int textOffset2=96;
  int indicatorOffset=35;
  int indicatorOffset2=108;
  int offset = 52;
  int offset2 = 125;
  int octOffset = 29;
  int tog=100;
  color fillcolor = color(255,255,255);


  //TOGGLES FOR TURNING ON AND OFF STRIPS and UNITS
  boolean Utog = true;
  boolean Stog = true;
  boolean Etog = true;
  boolean Dtog = true;
  boolean Rtog = true;
  //ONSCREEN TOGGLE BOX LOCATION
  PVector Ubox; 
  PVector Sbox;
  PVector Ebox; 
  PVector Dbox; 
  PVector Rbox;
  //ONSREEN TOGGLE BOX DISPLAY TOGGLE ON/OFF
  boolean toggleToggle = true;
  boolean diagToggle = false;

  Unit (int UI, Strip temps, Strip tempe, Strip tempd, Strip tempr, int stripe_sub_Strips, int type, PVector screen_loc) {
    unit_ID=UI+1;
    stripe = temps;
    edge = tempe;
    downward = tempd;
    reflective = tempr;
    unit_type = type;
    sub_strips = stripe_sub_Strips;
    xloc = (int)screen_loc.x;
    yloc = (int)screen_loc.y;
    //PVectors for check boxes;
    Ubox = new PVector(xloc, yloc);
    Sbox = new PVector(xloc+indicatorOffset, yloc);
    Ebox = new PVector(xloc+indicatorOffset, yloc+30);
    Dbox = new PVector(xloc+indicatorOffset2, yloc);
    Rbox = new PVector(xloc+indicatorOffset2, yloc+30);
  }
  
  void checkManCon() {
    if (toggleToggle){
    if (mouseX>Ubox.x && mouseX<Ubox.x+indicatorSize && mouseY>Ubox.y && mouseY<Ubox.y+indicatorSize) {
      //weird hack for the toggle on and off face and unit boolean... its either
      //0 or 100 and the tog value is used for the fill color of the tog indicator... bizarre
      tog = abs(tog + (-100));
      Utog=!Utog;
      if (!Utog) {
        stripe.tog = 0;
        Stog=false;
        edge.tog = 0;
        Etog=false;
        downward.tog = 0;
        Dtog=false;
        reflective.tog = 0;
        Rtog=false;
      } 
      else {
        stripe.tog = 100;
        Stog=true;
        edge.tog = 100;
        Etog=true;
        downward.tog = 100;
        Dtog=true;
        reflective.tog = 100;
        Rtog=true;
      }
    }

    if (mouseX>Sbox.x && mouseX<Sbox.x+indicatorSize2 && mouseY>Sbox.y && mouseY<Sbox.y+indicatorSize2) {
      stripe.tog = abs(stripe.tog + (-100));
      Stog=!Stog;
    }

    if (mouseX>Ebox.x && mouseX<Ebox.x+indicatorSize2 && mouseY>Ebox.y && mouseY<Ebox.y+indicatorSize2) {
      edge.tog = abs(edge.tog + (-100));
      Etog=!Etog;
    }

    if (mouseX>Dbox.x && mouseX<Dbox.x+indicatorSize2 && mouseY>Dbox.y && mouseY<Dbox.y+indicatorSize2) {
      downward.tog = abs(downward.tog + (-100));
      Dtog=!Dtog;
    }

    if (mouseX>Rbox.x && mouseX<Rbox.x+indicatorSize2 && mouseY>Rbox.y && mouseY<Rbox.y+indicatorSize2) {
      reflective.tog = abs(reflective.tog + (-100));
      Rtog=!Rtog;
    }
    }  
  }

  public void display() {

    int borderSizeX=offset2+unitSize+6;
    int borderSizeY=unitSize+8;
    //CREATE UNIT INDICATOR AND STRIP SECTIONS
    strokeWeight(1);
    stroke(255, 0, 0);
    
    if(toggleToggle){
      pushMatrix();
      stroke(fillcolor);
      fill(255, 255, 255, 0);
      rect(xloc-4, yloc-4, borderSizeX, borderSizeY);
      fill(255, 255, 255, tog);
      popMatrix();
      stroke(255,0,0);
      rect(Ubox.x, Ubox.y, indicatorSize, indicatorSize);
      fill(255, 255, 255, stripe.tog);
      rect(Sbox.x, Sbox.y, indicatorSize2, indicatorSize2);
      fill(255, 255, 255, edge.tog);
      rect(Ebox.x, Ebox.y, indicatorSize2, indicatorSize2);
      fill(255, 255, 255, downward.tog);
      rect(Dbox.x, Dbox.y, indicatorSize2, indicatorSize2);
      fill(255, 255, 255, reflective.tog);
      rect(Rbox.x, Rbox.y, indicatorSize2, indicatorSize2);


         //WRITE NAME AND UNIT NUMBER AND TYPE TO THE SCREEN
      strokeWeight(1);
      fill(200);
      textSize(14);
      if (unit_type==_OCTAGON) {
        text("OCTAGON " + unit_ID, xloc, yloc-10);
      }
      else if (unit_type == _SQUARE) {
        text("SQUARE " + unit_ID, xloc, yloc-10);
      }
  
      //WRITE TOGGLE LABELS
      textSize(10);
      text("S: ", xloc+textOffset, yloc+9);
      text("E: ", xloc+textOffset, yloc+39);
      text("D: ", xloc+textOffset2, yloc+9);
      text("R: ", xloc+textOffset2, yloc+39);
    }
    
    //STRIPE (1-3)
    strokeWeight(2);
    int stripOffset = 10;
    //if mode = direct
    if (stripe.modeChan == 0) {
      for (int i=0;i<sub_strips;i++) {
        if ((stripe.maskChan & 1<<i) > 0) {
          stroke(stripe.rChan, stripe.gChan, stripe.bChan);
        }
        else {
          stroke(25, 25, 25);
        }   
        line(xloc+offset+stripOffset, yloc+3, xloc+offset+stripOffset, yloc+unitSize-3);
        stripOffset+=10;
      }
      //if mode = dotflow
    }
    else if (stripe.modeChan>0) {
      for (int i=0;i<sub_strips;i++) {
        stroke(stripe.rChan, stripe.gChan, stripe.bChan);
        line(xloc+offset+stripOffset, yloc+3, xloc+offset+stripOffset, yloc+unitSize-3);
        stripOffset+=10;
      }
    }

    //EDGE (4 or 8)
    strokeWeight(2);
    if (unit_type==_OCTAGON) {
      if (edge.modeChan==0) {
        //DIRECT
        //bottom
        if ((edge.maskChan & mask1) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset+octOffset, yloc+unitSize, xloc+unitSize+offset-octOffset, yloc+unitSize);
        //left angle
        if ((edge.maskChan & mask2) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset+octOffset, yloc+unitSize, xloc+unitSize+offset, yloc+octOffset);
        //left vertical
        if ((edge.maskChan & mask3) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset, yloc+unitSize-octOffset, xloc+unitSize+offset, yloc+octOffset);
        //left top angle
        if ((edge.maskChan & mask4) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset, yloc+unitSize-octOffset, xloc+offset+octOffset, yloc);
        //top
        if ((edge.maskChan & mask5) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }        
        line(xloc+unitSize+offset-octOffset, yloc, xloc+offset+octOffset, yloc);
        //right top angl
        if ((edge.maskChan & mask6) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset-octOffset, yloc, xloc+offset, yloc+unitSize-octOffset);
        //right vertical
        if ((edge.maskChan & mask7) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset, yloc+octOffset, xloc+offset, yloc+unitSize-octOffset);
        //bottom right angle
        if ((edge.maskChan & mask8) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset, yloc+octOffset, xloc+unitSize+offset-octOffset, yloc+unitSize);
      }
      else if (edge.modeChan>0) {
        //DOTFLOW
        //bottom
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset+octOffset, yloc+unitSize, xloc+unitSize+offset-octOffset, yloc+unitSize);
        //left angle
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset+octOffset, yloc+unitSize, xloc+unitSize+offset, yloc+octOffset);
        //left vertical
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset, yloc+unitSize-octOffset, xloc+unitSize+offset, yloc+octOffset);
        //left top angle
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset, yloc+unitSize-octOffset, xloc+offset+octOffset, yloc);
        //top
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset-octOffset, yloc, xloc+offset+octOffset, yloc);
        //right top angl
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset-octOffset, yloc, xloc+offset, yloc+unitSize-octOffset);
        //right vertical
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset, yloc+octOffset, xloc+offset, yloc+unitSize-octOffset);
        //bottom right angle
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset, yloc+octOffset, xloc+unitSize+offset-octOffset, yloc+unitSize);
      }
    }
    else if (unit_type == _SQUARE) {
      if (edge.modeChan==0) {
        if ((edge.maskChan & mask1) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset, yloc+unitSize, xloc+unitSize+offset, yloc+unitSize);
        if ((edge.maskChan & mask2) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset, yloc+unitSize, xloc+unitSize+offset, yloc);
        if ((edge.maskChan & mask3) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset, yloc, xloc+offset, yloc);
        if ((edge.maskChan & mask4) > 0) {
          stroke(edge.rChan, edge.gChan, edge.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset, yloc, xloc+offset, yloc+unitSize);
      }
      else if (edge.modeChan>0) {
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset, yloc+unitSize, xloc+unitSize+offset, yloc+unitSize);
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset, yloc+unitSize, xloc+unitSize+offset, yloc);
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+unitSize+offset, yloc, xloc+offset, yloc);
        stroke(edge.rChan, edge.gChan, edge.bChan);
        line(xloc+offset, yloc, xloc+offset, yloc+unitSize);
      }
    }


    //DOWN (4)
    strokeWeight(2);
    if (unit_type==_OCTAGON) {
      if(downward.modeChan==0){
        if ((downward.maskChan & mask1) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+7, yloc+3, xloc+offset2+7, yloc+unitSize-3);
        if ((downward.maskChan & mask2) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+16, yloc, xloc+offset2+16, yloc+unitSize);
        if ((downward.maskChan & mask3) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+24, yloc, xloc+offset2+24, yloc+unitSize);
        if ((downward.maskChan & mask4) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+33, yloc+3, xloc+offset2+33, yloc+unitSize-3);
      }else if(downward.modeChan>0){
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+7, yloc+3, xloc+offset2+7, yloc+unitSize-3);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+16, yloc, xloc+offset2+16, yloc+unitSize);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+24, yloc, xloc+offset2+24, yloc+unitSize);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+33, yloc+3, xloc+offset2+33, yloc+unitSize-3);
      }
    }
    else if (unit_type == _SQUARE) {
      if(downward.modeChan==0){
        if ((downward.maskChan & mask1) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2, yloc);
        if ((downward.maskChan & mask2) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2+unitSize, yloc);
        if ((downward.maskChan & mask3) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2+unitSize, yloc+unitSize);
        if ((downward.maskChan & mask4) > 0) {
          stroke(downward.rChan, downward.gChan, downward.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2, yloc+unitSize);
      }else if(downward.modeChan>0){
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2, yloc);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2+unitSize, yloc);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2+unitSize, yloc+unitSize);
        stroke(downward.rChan, downward.gChan, downward.bChan);
        line(xloc+offset2+unitSize/2, yloc+unitSize/2, xloc+offset2, yloc+unitSize);
      }
    }

    //REFLECTIVE (4 or 8)
    strokeWeight(2);
    if (unit_type==_OCTAGON) {
      if(reflective.modeChan==0){
        if ((reflective.maskChan & mask1) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+octOffset, yloc+unitSize, xloc+unitSize+offset2-octOffset, yloc+unitSize);
        //left angle
        if ((reflective.maskChan & mask2) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2+octOffset, yloc+unitSize, xloc+unitSize+offset2, yloc+octOffset);
        //left vertical
        if ((reflective.maskChan & mask3) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2, yloc+unitSize-octOffset, xloc+unitSize+offset2, yloc+octOffset);
        //left top angle
        if ((reflective.maskChan & mask4) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2, yloc+unitSize-octOffset, xloc+offset2+octOffset, yloc);
        //top
        if ((reflective.maskChan & mask5) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2-octOffset, yloc, xloc+offset2+octOffset, yloc);
        //right top angl
        if ((reflective.maskChan & mask6) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2-octOffset, yloc, xloc+offset2, yloc+unitSize-octOffset);
        //right vertical
        if ((reflective.maskChan & mask7) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2, yloc+octOffset, xloc+offset2, yloc+unitSize-octOffset);
        //bottom right angle
        if ((reflective.maskChan & mask8) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2, yloc+octOffset, xloc+unitSize+offset2-octOffset, yloc+unitSize);
      }else if(reflective.modeChan>0){
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2+octOffset, yloc+unitSize, xloc+unitSize+offset2-octOffset, yloc+unitSize);
        //left angle
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2+octOffset, yloc+unitSize, xloc+unitSize+offset2, yloc+octOffset);
        //left vertical
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+unitSize+offset2, yloc+unitSize-octOffset, xloc+unitSize+offset2, yloc+octOffset);
        //left top angle
        stroke(255, 255, 255);
        line(xloc+unitSize+offset2, yloc+unitSize-octOffset, xloc+offset2+octOffset, yloc);
        //top
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+unitSize+offset2-octOffset, yloc, xloc+offset2+octOffset, yloc);
        //right top angl
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+unitSize+offset2-octOffset, yloc, xloc+offset2, yloc+unitSize-octOffset);
        //right vertical
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2, yloc+octOffset, xloc+offset2, yloc+unitSize-octOffset);
        //bottom right angle
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2, yloc+octOffset, xloc+unitSize+offset2-octOffset, yloc+unitSize);      
      }
    }
    else if (unit_type == _SQUARE) {
      if(reflective.modeChan==0){  
        if ((reflective.maskChan & mask1) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2, yloc+unitSize, xloc+unitSize+offset2, yloc+unitSize);
        if ((reflective.maskChan & mask2) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2, yloc+unitSize, xloc+unitSize+offset2, yloc);
        if ((reflective.maskChan & mask3) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+unitSize+offset2, yloc, xloc+offset2, yloc);
        if ((reflective.maskChan & mask4) > 0) {
          stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        }
        else {
          stroke(25, 25, 25);
        }
        line(xloc+offset2, yloc, xloc+offset2, yloc+unitSize);
      }else if(reflective.modeChan>0){
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2, yloc+unitSize, xloc+unitSize+offset2, yloc+unitSize);
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+unitSize+offset2, yloc+unitSize, xloc+unitSize+offset2, yloc);
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+unitSize+offset2, yloc, xloc+offset2, yloc);
        stroke(reflective.rChan, reflective.gChan, reflective.bChan);
        line(xloc+offset2, yloc, xloc+offset2, yloc+unitSize);        
      }
    }

   

    //WRITE MODE, SPEED and MASK LABEL GUI
    textSize(12);
    if (mouseX>xloc-4 && mouseX<xloc-4+borderSizeX && mouseY>yloc-4 && mouseY<yloc-4+borderSizeY && mousePressed == true ){
      println("Toggled on an Units Manual Diagnostics Permission --------------------------->");
      diagToggle = !diagToggle;
      if (diagToggle){
        fillcolor = color(255,0,0);
        fill(0,0,255);
        ellipse(xloc,yloc,5,5);
        edge.stripDiagToggle = true;
        stripe.stripDiagToggle = true;
        downward.stripDiagToggle = true;
        reflective.stripDiagToggle = true;
      }else if(!diagToggle){
        fillcolor = color(255,255,255);
        fill(0,0,0);
        ellipse(xloc,yloc,5,5);
        edge.stripDiagToggle = false;
        stripe.stripDiagToggle = false;
        downward.stripDiagToggle = false;
        reflective.stripDiagToggle = false;
      }
    }else if (mouseX>xloc-4 && mouseX<xloc-4+borderSizeX && mouseY>yloc-4 && mouseY<yloc-4+borderSizeY && shiftPressed){
      stroke(255); 
      fill(0, 0, 0, 100);
      rect(xloc-25, yloc-10, borderSizeX+175, borderSizeY+35);
      //STRIPE FACE
      fill(255, 255, 0);

      if (stripe.modeChan == 0) {
        text("SMode: dir", xloc-20, yloc+unitSize-35);
        text("Speed:  "+ stripe.modeChan, xloc+textOffset+24, yloc+unitSize-35);
        text("Mask: "+ stripe.maskChan, xloc+textOffset2+23, yloc+unitSize-35);
        text("sR: "+ stripe.rChan, xloc+textOffset2+85, yloc+unitSize-35);
        text("sG: "+ stripe.gChan, xloc+textOffset2+132, yloc+unitSize-35);
        text("sB: "+ stripe.bChan, xloc+textOffset2+180, yloc+unitSize-35);

      }
      else {
        text("SMode: dot", xloc-20, yloc+unitSize-35);
        text("Speed:  "+ stripe.modeChan, xloc+textOffset+24, yloc+unitSize-35);
        text("Mask: "+ stripe.maskChan, xloc+textOffset2+23, yloc+unitSize-35);
        text("sR: "+ stripe.rChan, xloc+textOffset2+85, yloc+unitSize-35);
        text("sG: "+ stripe.gChan, xloc+textOffset2+132, yloc+unitSize-35);
        text("sB: "+ stripe.bChan, xloc+textOffset2+180, yloc+unitSize-35);

      }

      //EDGE FACE
      fill(255, 255, 0);
      if (edge.modeChan == 0) {
        text("EMode: dir", xloc-20, yloc+unitSize-15);
        text("Speed:  "+ edge.modeChan, xloc+textOffset+24, yloc+unitSize-15);
        text("Mask: "+ edge.maskChan, xloc+textOffset2+23, yloc+unitSize-15);
        text("sR: "+ edge.rChan, xloc+textOffset2+85, yloc+unitSize-15);
        text("sG: "+ edge.gChan, xloc+textOffset2+132, yloc+unitSize-15);
        text("sB: "+ edge.bChan, xloc+textOffset2+180, yloc+unitSize-15);

      }
      else {
        text("EMode: dot", xloc-20, yloc+unitSize-15);
        text("Speed:  "+ edge.modeChan, xloc+textOffset+24, yloc+unitSize-15);
        text("Mask: "+ edge.maskChan, xloc+textOffset2+23, yloc+unitSize-15);
        text("sR: "+ edge.rChan, xloc+textOffset2+85, yloc+unitSize-15);
        text("sG: "+ edge.gChan, xloc+textOffset2+132, yloc+unitSize-15);
        text("sB: "+ edge.bChan, xloc+textOffset2+180, yloc+unitSize-15);

      }

      //DOWNWARD FACE
      fill(255, 255, 0);
      if (downward.modeChan == 0) {
        text("DMode: dir", xloc-20, yloc+unitSize+5);
        text("Speed:  "+ downward.modeChan, xloc+textOffset+24, yloc+unitSize+5);
        text("Mask: "+ downward.maskChan, xloc+textOffset2+23, yloc+unitSize+5);
        text("sR: "+ downward.rChan, xloc+textOffset2+85, yloc+unitSize+5);
        text("sG: "+ downward.gChan, xloc+textOffset2+132, yloc+unitSize+5);
        text("sB: "+ downward.bChan, xloc+textOffset2+180, yloc+unitSize+5);
      }
      else {
        text("DMode: dot", xloc-20, yloc+unitSize+5);
        text("Speed:  "+ downward.modeChan, xloc+textOffset+24, yloc+unitSize+5);
        text("Mask: "+ downward.maskChan, xloc+textOffset2+23, yloc+unitSize+5);
        text("sR: "+ downward.rChan, xloc+textOffset2+85, yloc+unitSize+5);
        text("sG: "+ downward.gChan, xloc+textOffset2+132, yloc+unitSize+5);
        text("sB: "+ downward.bChan, xloc+textOffset2+180, yloc+unitSize+5);
      }

      //REFLECTIVE FACE
      fill(255, 255, 0);
      if (reflective.modeChan == 0) {
        text("RMode: dir", xloc-20, yloc+unitSize+25);
        text("Speed:  "+ reflective.modeChan, xloc+textOffset+24, yloc+unitSize+25);
        text("Mask: "+ reflective.maskChan, xloc+textOffset2+23, yloc+unitSize+25);
        text("sR: "+ reflective.rChan, xloc+textOffset2+85, yloc+unitSize+25);
        text("sG: "+ reflective.gChan, xloc+textOffset2+132, yloc+unitSize+25);
        text("sB: "+ reflective.bChan, xloc+textOffset2+180, yloc+unitSize+25);
  
      }
      else {
        text("RMode: dot", xloc-20, yloc+unitSize+25);
        text("Speed:  "+ reflective.modeChan, xloc+textOffset+24, yloc+unitSize+25);
        text("Mask: "+ reflective.maskChan, xloc+textOffset2+23, yloc+unitSize+25);
        text("sR: "+ reflective.rChan, xloc+textOffset2+85, yloc+unitSize+25);
        text("sG: "+ reflective.gChan, xloc+textOffset2+132, yloc+unitSize+25);
        text("sB: "+ reflective.bChan, xloc+textOffset2+180, yloc+unitSize+25);
      }
    }
    
    if(diagMode){
      //println("POPUP DIAGNOSTIC SCREEN");
      drawDiagGUI();
    }
  } 
}

