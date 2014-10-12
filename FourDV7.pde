
         /*

 18
 20
 6,5
 7,4,1
 8,3,2,17,16
 9,12
 10,11,19
 13,14,15
 */
/**************************************************************
 * POWDERLY - NASA FACTORY - URBANTAINER                       *
 * Octagon Lounge Lighting System Control S/W V0.1             *
 * 2011 - 2013                                                 *
 * No Rights Reserved                                          *
 ***************************************************************/

//using the entec DMX Pro
//on OSX 10.7 Lion
//install the ftdi USD driver
//and unlock the port using these commands
//sudo mkdir -p /var/lock
//sudo chmod 777 /var/lock

/********************************************************************************** LIBRARIES
 */
//IMPORT LIBRARIES

//DMX CONTROL LIBRARIES
import dmxP512.*; //DMX Libraries
import processing.serial.*; // Serial control library for DMX

//GUI ELEMENTS LIBRARIY
import controlP5.*;

//COLOR/GRADIENT LIBRARIES
import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;

//SOUND LIBRARY
import ddf.minim.*; //sound input
import ddf.minim.analysis.*; //FFT analysis for the beat detection

//color wheel class
ColorPicker cp;

/************************************************************************************  VARIABLES
 */
//SOUND RELATED VARIABLES
private static final long serialVersionUID = 5454L;
int config_SAMPLERATE = 44100; //important var
int config_BUFFERSIZE = 512; //important var
int config_BPM = 140; //fine tune this var
int config_FFT_BAND_PER_OCT = 12; 
int config_FFT_BASE_FREQ = 55;
private boolean scaleEq = true;
public boolean onBeat = false;
public boolean oscOnBeat = false;
public boolean autoBeatSense = true;
public float beatSense = 8;
public float beatSenseSense = 1;
private long lastbeatTimestamp = 0;
private float level = 0;
private float leveldB = -100;
private int lastBand = 0;
private int lastBandCount = 0;
private int nbAverage = config_SAMPLERATE / config_BUFFERSIZE * 2; // one second
private float modulationSmooth = 0.30f;
private int nbAverageLongTerm = 8 * config_SAMPLERATE / config_BUFFERSIZE;
private int nbAverageShortTerm = config_SAMPLERATE / config_BUFFERSIZE / 3;
// skip beat for a quarter of beat
private int repeatDelay = (int) ((60f / config_BPM / 4f) * (config_SAMPLERATE / config_BUFFERSIZE));
private FFT fft;
private AudioInput input;
// private int bufferSize;
private Minim minim;
// private boolean localOnBeat = false;
private int playhead = 0;
private int playheadShortTerm = 0;
private int playheadLongTerm = 0;
private int skipFrames = 0;
public int numZones = 0;
public boolean zoneEnabled[];
private float score2 = 0;
// private float avg=0;
private float modulation = 0;
private float[][] zoneEnergy;
private float[][] zoneEnergyShortTerm;
private float[][] zoneScore;
private float[] score = new float[nbAverage];
private float[] scoreLongTerm = new float[nbAverageLongTerm];

private float[] zoneEnergyVuMeter;
private float[] zoneEnergyPeak;
private int[] zoneEnergyPeakHoldTimes;
private int peakHoldTime = 30; // hold longer
private float peakDecayRate = 0.98f; // decay slower
private float linearEQIntercept = 0.8f; // reduced gain at lowest frequency
private float linearEQSlope = 0.2f; // increasing gain at higher frequencies

//our beat boolean *VERY IMPORTANT*
boolean gotBeat = false;

//DMX OBJECTS AND LED DATA
DmxP512 dmxOutput;
boolean LANBOX=false;
boolean DMXPRO=true;
//THIS IS MY USB PORT BUT YOU WILL SEE YOURS LISTED IN THE DEBUG WINDOW ON STARTUP
String DMXPRO_PORT="/dev/tty.usbserial-EN093272";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

//THE LIGHTING SYSTEM VARIABLES AND DATA STRUCTURES
int universeSize=400;
int stripNum = 80;
int unitNum = 20;
int _SQUARE = 0;
int _OCTAGON = 1;
int[] DMXarray = new int[universeSize];
ArrayList strips;
ArrayList units;
ArrayList locs;

//test value I forget what this is...
PVector v1 = new PVector(40, 20);

//INTERFACE BOOLEANS TO TOGGLE DIFFERENT UI MODES
boolean shiftPressed = false; //to hide/unihide (on rollover and keydown) the DMX output value monitor for each unit 
boolean spacePressed = false; //To hide/unhide the master on/of checkboxes
boolean beatMode = false; //toggle to beat-reactive mode
boolean diagMode = false; // toggle to diagnostic mode to test each light
boolean waveTog = false;
boolean dessertMode = false;
boolean colorPickerMode = false;

//diag GUI controls for diagnostic
ControlP5 cp5;
ControlP5 ss1; // object for just the master speed
ControlP5 buttons;

controlP5.Button b;

int buttonValue = 1;

//diag GUI element variables
//Sliders for color and speed
int EdgeRed=0;
int EdgeBlue = 0;
int EdgeGreen = 0;
int EdgeSpeed = 0;

int DownwardRed=0;
int DownwardBlue = 0;
int DownwardGreen = 0;
int DownwardSpeed = 0;

int ReflectiveRed=0;
int ReflectiveBlue=0;
int ReflectiveGreen=0;
int ReflectiveSpeed = 0;

int StripeRed=0;
int StripeBlue = 0;
int StripeGreen = 0;
int StripeSpeed = 0;

// master speed slider experiment
int MasterSpeed = 0;
int Activity = 5;

//checkboxes for mask and direction
CheckBox EdgeCheckBox;
CheckBox EdgeMode;
CheckBox DownwardCheckBox;
CheckBox DownwardMode;
CheckBox ReflectiveCheckBox;
CheckBox ReflectiveMode;
CheckBox StripeCheckBox;
CheckBox StripeMode;

CheckBox allToggle;

CheckBox manualColorMode;

//LIGHTING UNIT AND LED STRIP SPECIFIC INFORMATION
//THIS IS THE ARRAY THAT HOLDS THE MASTER LIST OF STRIPE SUBSTRIPS FOR THE OCTAGON STAGE
int[] subStripArray = { 
  1, 1, 2, 2, 3, 
  2, 1, 2, 2, 2, 
  2, 1, 0, 2, 2, 
  2, 1, 2, 1, 2,
};

//THIS IS THE ARRAY THAT HOLDS THE MASTER LIST OF TYPES FOR THE OCTAGON STAGE
int[] typeArray = { 
  _OCTAGON, _SQUARE, _OCTAGON, _SQUARE, _OCTAGON, 
  _OCTAGON, _SQUARE, _OCTAGON, _SQUARE, _OCTAGON, 
  _OCTAGON, _OCTAGON, _SQUARE, _OCTAGON, _OCTAGON, 
  _SQUARE, _OCTAGON, _OCTAGON, _SQUARE, _OCTAGON
};

//THIS IS THE MASK FOR CONTROLLING UP TO 8 SUB-STRIPS ON ANY FACE
int mask0 = 0;
int mask1 = 1;
int mask2 = 2;
int mask3 = 4;
int mask4 = 8;
int mask5 = 16;
int mask6 = 32;
int mask7 = 64;
int mask8 = 128;

//COLOR RELATED VARIABLES AND OBJECTS
//COLOR PALETTES AND GRADIENTS
Palette  whiteBlack;
Gradient fade1;
ArrayList Palettes;
ArrayList Gradients;
Palette  startPalette;
Gradient startGradient;
Palette sp;
int colorNum = 5;
boolean skip = false;
int step = 0;
color manualColor;

//THE FONT. THE GODDAMN FONT
PFont sysFont;

//TIMER VARIABLES
int startTime; 
PVector eTime;
//AUDIO DELAY TIMER VARIABLE
int delay=0; 
int waveTimer=0;
int moveTime = 30;
int directionTog = 1;
int fadeDir = 1;
int testVal=0;


/********************************************************************************************** THE SETUP
 */
//SET IT UP HACKA
void setup() {
  //STAGE SIZE
  size(1440, 900, P2D);  
  //DMX CONSTRUCTOR
  dmxOutput=new DmxP512(this, universeSize, true);  

  pGenerate();

  ss1 = new ControlP5(this);

  ss1.addSlider("MasterSpeed")
    .setPosition(400, 60)
      .setRange(1, 50)
        ;

  ss1.addSlider("Activity")
    .setPosition(400, 70)
      .setRange(30, 0)
        .setNumberOfTickMarks(30)
          ;


  allToggle = ss1.addCheckBox("All Toggle")
    .setPosition(600, 70)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(4)
                .setSpacingColumn(100)
                  //     .setSpacingRow(20)
                  .addItem("stripe", 1)
                    .addItem("edge", 1)
                      .addItem("downward", 1)
                        .addItem("reflective", 1)
                          ;

  //initialize the Diagnostic Mode GUI ELements
  cp5 = new ControlP5(this);

  /*EDGE*/
  //red slider for the edge face
  cp5.addSlider("EdgeRed")
    .setPosition(10, 250)
      .setRange(0, 255)
        ;
  //checkboxes for the edge face
  EdgeCheckBox = cp5.addCheckBox("EdgeMaskCheck")
    .setPosition(200, 250)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("e1", mask1)
                    .addItem("e2", mask2)
                      .addItem("e4", mask3)
                        .addItem("e8", mask4)
                          .addItem("e16", mask5)
                            .addItem("e32", mask6)
                              .addItem("e64", mask7)
                                .addItem("e128", mask8)
                                  ;
  //green slider for the edge face
  cp5.addSlider("EdgeGreen")
    .setPosition(10, 260)
      .setRange(0, 255)
        ;

  //blue slider for the edge face
  cp5.addSlider("EdgeBlue")
    .setPosition(10, 270)
      .setRange(0, 255)
        ;

  //edge face speed checkboxes
  cp5.addSlider("EdgeSpeed")
    .setPosition(10, 280)
      .setRange(0, 50)
        ;

  //edge face mode check boxes
  EdgeMode = cp5.addCheckBox("EdgeModeCheck")
    .setPosition(200, 280)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("eDot", 1)
                    .addItem("eDirection", 127)
                      ;

  /*DOWNWARD*/
  //red slider for downward face
  cp5.addSlider("DownwardRed")
    .setPosition(10, 300)
      .setRange(0, 255)
        ;

  //checkboxes for the mask of downward face
  DownwardCheckBox = cp5.addCheckBox("DownwardMaskCheck")
    .setPosition(200, 300)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("d1", mask1)
                    .addItem("d2", mask2)
                      .addItem("d4", mask3)
                        .addItem("d8", mask4)
                          ;

  //green slider for downward face
  cp5.addSlider("DownwardGreen")
    .setPosition(10, 310)
      .setRange(0, 255)
        ;

  //blue slider for downward face
  cp5.addSlider("DownwardBlue")
    .setPosition(10, 320)
      .setRange(0, 255)
        ;

  //speed slider for downward face
  cp5.addSlider("DownwardSpeed")
    .setPosition(10, 330)
      .setRange(0, 50)
        ;

  // checkboxes for mode and direction for downward face     
  DownwardMode = cp5.addCheckBox("DownwardModeCheck")
    .setPosition(200, 330)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("dDot", 1)
                    .addItem("dDirection", 127)
                      ;

  /*REFLECTIVE*/
  cp5.addSlider("ReflectiveRed")
    .setPosition(10, 350)
      .setRange(0, 255)
        ;

  ReflectiveCheckBox = cp5.addCheckBox("ReflectiveMaskCheck")
    .setPosition(200, 350)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("r1", mask1)
                    .addItem("r2", mask2)
                      .addItem("r4", mask3)
                        .addItem("r8", mask4)
                          .addItem("r16", mask5)
                            .addItem("r32", mask6)
                              .addItem("r64", mask7)
                                .addItem("r128", mask8)
                                  ;

  cp5.addSlider("ReflectiveGreen")
    .setPosition(10, 360)
      .setRange(0, 255)
        ;

  cp5.addSlider("ReflectiveBlue")
    .setPosition(10, 370)
      .setRange(0, 255)
        ;

  cp5.addSlider("ReflectiveSpeed")
    .setPosition(10, 380)
      .setRange(0, 50)
        ;

  ReflectiveMode = cp5.addCheckBox("ReflectiveModeCheck")
    .setPosition(200, 380)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("rDot", 1)
                    .addItem("rDirection", 127)
                      ;

  /*STRIPE*/
  cp5.addSlider("StripeRed")
    .setPosition(10, 400)
      .setRange(0, 255)
        ;

  StripeCheckBox = cp5.addCheckBox("StripMaskCheck")
    .setPosition(200, 400)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("s1", mask1)
                    .addItem("s2", mask2)
                      .addItem("s4", mask3)

                        ;
  cp5.addSlider("StripeGreen")
    .setPosition(10, 410)
      .setRange(0, 255)
        ;

  cp5.addSlider("StripeBlue")
    .setPosition(10, 420)
      .setRange(0, 255)
        ;

  cp5.addSlider("StripeSpeed")
    .setPosition(10, 430)
      .setRange(0, 50)
        ;

  StripeMode = cp5.addCheckBox("StripeModeCheck")
    .setPosition(200, 430)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(10, 10)
              .setItemsPerRow(8)
                .setSpacingColumn(25)
                  //     .setSpacingRow(20)
                  .addItem("sDot", 1)
                    .addItem("sDirection", 127)
                      ;

  //THIS HIDES THE GUI ELEMENTS UNTIL THE .show is called
  cp5.hide();

  //INIT PALETTES AND GRADIENT  
  //old 80 color library
  //initColors();

  //new 5 color library
  initSelectColors();

  //DETERMINE LANBOX OR DMXPRO -- we use the pro  
  if (DMXPRO) {
    dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);
  }

  //INITIALIZE OUT STRIPS AND UNITS
  initLocs(); 
  initStrips();
  initUnits();
  //INITIALIZE COLOR PALETTES AND GRADIENTS
  initPalettes();  
  //INITIALIZE GIU ELEMENTS
  initGUI();

  //AUDIO SETUP
  minim = new Minim(this);  
  input = minim.getLineIn(Minim.STEREO, config_BUFFERSIZE, 
  config_SAMPLERATE);
  input.addListener(new Listener());

  fft = new FFT(config_BUFFERSIZE, config_SAMPLERATE);
  fft.logAverages(config_FFT_BASE_FREQ, config_FFT_BAND_PER_OCT);
  // fft.noAverages();
  // fft.linAverages(128);
  fft.window(FFT.HAMMING);
  System.out.println("Sound Control: FFT on " + fft.avgSize()
    + " log bands. samplerate: " + config_SAMPLERATE + "Hz. "
    + config_SAMPLERATE / config_BUFFERSIZE + " buffers of "
    + config_BUFFERSIZE + " samples per second.");
  numZones = fft.avgSize();//

  zoneEnergy = new float[numZones][];
  zoneEnergyShortTerm = new float[numZones][];
  zoneScore = new float[numZones][];
  zoneEnabled = new boolean[numZones];

  zoneEnergyVuMeter = new float[numZones];
  zoneEnergyPeak = new float[numZones];
  zoneEnergyPeakHoldTimes = new int[numZones];

  for (int i = 0; i < numZones; i++) {
    zoneEnergy[i] = new float[nbAverage];
    zoneScore[i] = new float[nbAverage];
    zoneEnergyShortTerm[i] = new float[nbAverageShortTerm];
    zoneEnabled[i] = true;
  }
  //colorpicker init
  
  cp = new ColorPicker( 1000, 300, 400, 400, 255 );

  //TIMER SETUP AND FRAMERATE
  frameRate(60);
  startTime = millis();
  eTime = elapsedTime(startTime);
}

void pGenerate()
{   
  sp = new Palette(this);

  for (int i = 0; i < 5; i++) {
    sp.addColor( color(random(255), random(255), random(255) ) );
  }
  sp.sortByLuminance();
}

void draw() {   
  //updateUNITS;
  //old random 80 colors library
  //initColors();
  //new 5 color library
  initSelectColors();
  updateStrips();
  updateDMXarray();
  sendDMX();
  updateScreen();
  eTime=elapsedTime(startTime);
  //random reseed the color generator every 30 seconds
  if ((eTime.z == 0  || eTime.z == 30) && skip == false) {
    pGenerate();
    skip = true;
  }
  if (eTime.z == 2  || eTime.z == 32) {
    skip = false;
  }
  //  currentSwatch+=looper;
  if(colorPickerMode){
    cp.render();
  }
}

void drawColorSwatches() {
  pushMatrix();
  translate(1000, 100);
  sp.drawSwatches();
  popMatrix();
}   

void initColors() {
  Palettes = new ArrayList();
  Gradients = new ArrayList();

  //create 20 palettes
  for (int i=0; i < colorNum; i++) { 
    Palettes.add(new Palette(this));
  }
  // add 2 colors to each palette
  for (int i=0; i < stripNum; i++) {
    Palette tp = (Palette)Palettes.get(i);
    tp.addColor(color(random(0, 255), random(0, 255), random(0, 255)));
    tp.addColor(color(0, 0, 0));
    Gradients.add(new Gradient(tp, 120));
  }
}

void initSelectColors() {
  Palettes = new ArrayList();
  Gradients = new ArrayList();

  //create 20 palettes
  for (int i=0; i < stripNum; i++) { 
    Palettes.add(new Palette(this));
  }
  // add 2 colors to each palette
  for (int i=0; i < stripNum; i++) {
    Palette tp = (Palette)Palettes.get(i);
    tp.addColor(sp.getColor(i%colorNum));
    tp.addColor(color(0, 0, 0));
    Gradients.add(new Gradient(tp, 120));
  }
}



//FUNCTION TO UPDATE THE DMXARRAY WITH NEW VALUES
void updateDMXarray() {

  for (int i=0;i<stripNum;i++) {
    //DMXarray[i]=(int)random(10)+((i%2==0)?mouseX:mouseY);
    Strip ts = (Strip)strips.get(i);
    DMXarray[i*5]=ts.rChan;
    DMXarray[i*5+1]=ts.gChan;
    DMXarray[i*5+2]=ts.bChan;
    DMXarray[i*5+3]=ts.modeChan;
    DMXarray[i*5+4]=ts.maskChan;
  }
}

void initPalettes() {
  whiteBlack = new Palette(this);
  whiteBlack.addColor( color(255, 255, 255));
  whiteBlack.addColor(color(0, 0, 0));
  initGradients();
}

void initGradients() {
  fade1 = new Gradient(whiteBlack, moveTime*4+1);
}

void initGUI() {
  sysFont = loadFont("Helvetica.vlw");
  textFont(sysFont, 24);
  fill(255, 255, 255);
}

//SEND DMX OUT USING THE DMXARRAY[]
void sendDMX() {

  for (int i=1;i<universeSize+1;i++) {
    dmxOutput.set(i, DMXarray[i-1]);
  }
}

void updateScreen() {
  //MAKE THE SCREEN BLACK
  background(0);
  //DRAW FFT< SOUND LEVEL AND BEAT DETECTION TO THE SCREEN
  CalcBeatAndDrawSoundViz(-3, 550);
  //DRAW THE UNITS
  drawOctagonGUI();
  //PUT SOME TEXT
  drawMisc();
  drawColorSwatches();
}

//int r = (argb >> 16) & 0xFF;  // Faster way of getting red(argb)
//int g = (argb >> 8) & 0xFF;   // Faster way of getting green(argb)
//int b = argb & 0xFF;          // Faster way of getting blue(argb)

void updateStrips() {

  if (beatMode) {
    boolean beatControl = control();
    //println(beatControl);
    //testing parameter
    //beatControl=true;

    for (int i=0; i < stripNum; i++) {
      Strip ts = (Strip)strips.get(i);
      Gradient tg = (Gradient)Gradients.get(i);
        color tc = color(0,0,0);
      if(colorPickerMode){
        tc = manualColor;
      }else{
        tc = color(tg.getColor(0));
      }
      int beatrandomizer = (int)(random(0, Activity));
      int directionrandomizer = (int)(random(0, 1));
      int speedrandomizer = (int)(random(0, 10));
      if (ts.tog>0 && beatControl == true && beatrandomizer == 1) {
        int at = (int)allToggle.getArrayValue()[i%4];
        if (at==1) {    
          ts.rChan = (tc >> 16) & 0xFF;
          ts.gChan = (tc >> 8) & 0xFF;
          ts.bChan = tc & 0xFF;
          ts.modeChan = 0;
          ts.maskChan = 255;
        }
        //else{
        //   ts.rChan = 0;
        //   ts.gChan = 0;
        //   ts.bChan = 0;
        //   if(directionrandomizer>0){
        //     ts.modeChan = MasterSpeed + speedrandomizer;
        //   }else{
        //     ts.modeChan = MasterSpeed+ (speedrandomizer + 127);
        //   }
        //   ts.maskChan = 255;
        // }
        //println(MasterSpeed);
        gotBeat = false;
      } 
      else if (ts.tog==0 || beatControl == false) {
        ts.rChan = 0;
        ts.gChan = 0;
        ts.bChan = 0;
        if (directionrandomizer>0) {
          ts.modeChan = MasterSpeed + speedrandomizer;
        }
        else {
          ts.modeChan = MasterSpeed+ (speedrandomizer + 127);
        }
        ts.maskChan = 255;
      }
    }
  } 
  else if (diagMode) {
    //make the manual arrays of colors, modes and masks for all four strips according to the diag sliders and checkboxes
    color[] diagc=  new color[4];
    int[] dmode = {
      0, 0, 0, 0
    };
    int[] dmask = {
      0, 0, 0, 0
    };
    //fill the arrays based on the values from the sliders
    diagc[0] = color(StripeRed, StripeGreen, StripeBlue);
    diagc[1] = color(EdgeRed, EdgeGreen, EdgeBlue);
    diagc[2] = color(DownwardRed, DownwardGreen, DownwardBlue);
    diagc[3] = color(ReflectiveRed, ReflectiveGreen, ReflectiveBlue);

    //calculate the values of the checkboxes.
    //MASK CHECKBOXES
    for (int i=0;i<StripeCheckBox.getArrayValue().length;i++) {
      int n = (int)StripeCheckBox.getArrayValue()[i];
      if (n==1) {
        dmask[0] += StripeCheckBox.getItem(i).internalValue();
      }
    }

    for (int i=0;i<EdgeCheckBox.getArrayValue().length;i++) {
      int n = (int)EdgeCheckBox.getArrayValue()[i];
      if (n==1) {
        dmask[1] += EdgeCheckBox.getItem(i).internalValue();
      }
    }

    for (int i=0;i<DownwardCheckBox.getArrayValue().length;i++) {
      int n = (int)DownwardCheckBox.getArrayValue()[i];
      if (n==1) {
        dmask[2] += DownwardCheckBox.getItem(i).internalValue();
      }
    }

    for (int i=0;i<ReflectiveCheckBox.getArrayValue().length;i++) {
      int n = (int)ReflectiveCheckBox.getArrayValue()[i];
      if (n==1) {
        dmask[3] += ReflectiveCheckBox.getItem(i).internalValue();
      }
    }
    //MODE CHECK BOXES
    for (int i=0;i<StripeMode.getArrayValue().length;i++) {
      int s = (int)StripeMode.getArrayValue()[i];
      if (s==1) {
        dmode[0] += StripeMode.getItem(i).internalValue();
      }
    }
    if (dmode[0]>0) {
      dmode[0] += StripeSpeed;
    }
    for (int i=0;i<EdgeMode.getArrayValue().length;i++) {
      int e = (int)EdgeMode.getArrayValue()[i];
      if (e==1) {
        dmode[1] += EdgeMode.getItem(i).internalValue();
      }
    }
    if (dmode[1]>0) {
      dmode[1] += EdgeSpeed;
    }
    for (int i=0;i<DownwardMode.getArrayValue().length;i++) {
      int d = (int)DownwardMode.getArrayValue()[i];
      if (d==1) {
        dmode[2] += DownwardMode.getItem(i).internalValue();
      }
    }
    if (dmode[2]>0) {
      dmode[2] += DownwardSpeed;
    }
    for (int i=0;i<ReflectiveMode.getArrayValue().length;i++) {
      int r = (int)ReflectiveMode.getArrayValue()[i];
      if (r==1) {
        dmode[3] += ReflectiveMode.getItem(i).internalValue();
      }
    }
    if (dmode[3]>0) {
      dmode[3] += ReflectiveSpeed;
    }

    //send them to the strips using modulus (%) to split the strips into groups of four to correspond to the [4] arrays



    for (int i=0; i < stripNum; i++) {
      Strip ts = (Strip)strips.get(i);
      if (ts.stripDiagToggle) {
        ts.rChan = (diagc[i%4] >> 16) & 0xFF;
        ts.gChan = (diagc[i%4] >> 8) & 0xFF;
        ts.bChan = diagc[i%4] & 0xFF;
        ts.modeChan = dmode[i%4];
        ts.maskChan = dmask[i%4];
      }
    }
  } 
  else if ((!diagMode && !beatMode) && !waveTog) {
    for (int i=0; i < stripNum; i++) {
      Strip ts = (Strip)strips.get(i);
      if (ts.tog==0) {
        ts.rChan = (0 >> 16) & 0xFF;
        ts.gChan = (0 >> 8) & 0xFF;
        ts.bChan = 0 & 0xFF;
        ts.modeChan = 0;
        ts.maskChan = 255;
      }
    } 
  }  else if (waveTog == true) {
       int tempTimer = millis()-waveTimer;
       if(tempTimer > 0 && tempTimer <moveTime){
         //tc = color(0,0,0);
         //println("off");
       }else if (tempTimer > (moveTime*2) && tempTimer < moveTime*3) {
         //tc = color(255,255,255);
         //println("on");
       }else if (tempTimer > moveTime*4){
         waveTimer = millis();
         step+=directionTog;
       }
       
    //println(tempTimer);
    for (int i=0; i < unitNum; i++) {
       
      //if(testVal == 0){
      //   fadeDir = 1;
       //}
       
      // if(testVal == 10){
      //   fadeDir = -1;
       //} 
      
       //testVal+=fadeDir;
       
       println(testVal);
       color tc = color(0,0,0);
       Unit u = (Unit)units.get(i);
       int tempID = u.unit_ID;
       //println(tempID);
       Strip ts1 = (Strip)u.stripe;
       
       Strip ts2 = (Strip)u.edge;
       Strip ts3 = (Strip)u.downward;
       Strip ts4 = (Strip)u.reflective;
       
       println("step= "+ step + " Unit ID= " + tempID);
//moveTime*4-(millis()%(moveTime*4))
       
       if(step==1 && tempID == 18){
        tc = fade1.getColor(0); 
        //println("there");
       }
       
       if(step==2 && tempID == 20){
        tc = fade1.getColor(0); 
        //println("there");
       }
       
       if(step==3 && (tempID == 6 || tempID  == 5)){
        tc = fade1.getColor(0); 
       }
       
       if(step==4 && (tempID ==7 || tempID == 4 || tempID == 1) ){
        tc = fade1.getColor(0); 
       }
       
       if(step==5 && (tempID ==8 || tempID == 3 || tempID == 2 || tempID == 17 || tempID == 16)){
        tc = fade1.getColor(0);
       }
      
       if(step==6 && (tempID == 9 || tempID  == 12)){
        tc = fade1.getColor(0); 
       }
       
       if(step==7 && (tempID ==10 || tempID == 11 || tempID == 19 )){
        tc = fade1.getColor(0); 
       }
       
       if(step==8 && (tempID ==13 || tempID == 14 || tempID == 15) ){
        tc = fade1.getColor(0); 
       }

      if (step == 9){
        tc = color(0,0,0); 
         directionTog=-1;
       }
       
      if (step == 0){
        tc = color(0,0,0); 
        directionTog=1;
        step=1;
       }
       
       //int at = (int)allToggle.getArrayValue()[i%4];
       ts1.rChan = (tc >> 16) & 0xFF;
       ts1.gChan = (tc >> 8) & 0xFF;
       ts1.bChan = tc & 0xFF;
       ts1.modeChan = 0;
       ts1.maskChan = 0;
       ts2.rChan = (tc >> 16) & 0xFF;
       ts2.gChan = (tc >> 8) & 0xFF;
       ts2.bChan = tc & 0xFF;
       ts2.modeChan = 0;
       ts2.maskChan = 0;
       ts3.rChan = (tc >> 16) & 0xFF;
       ts3.gChan = (tc >> 8) & 0xFF;
       ts3.bChan = tc & 0xFF;
       ts3.modeChan = 0;
       ts3.maskChan = 0;
       ts4.rChan = (tc >> 16) & 0xFF;
       ts4.gChan = (tc >> 8) & 0xFF;
       ts4.bChan = tc & 0xFF;
       ts4.modeChan = 0;
       ts4.maskChan = 255;
      //units.add(new Unit(i, (Strip)strips.get(i*4), (Strip)strips.get(i*4+1), (Strip)strips.get(i*4+2), (Strip)strips.get(i*4+3), subStripArray[i], typeArray[i], (PVector)locs.get(i)));
    }
   // println("wave");
  }
  //do the wave
}

/* CREATES THE STRIP OBJECTS.
 
 */
void initStrips() {
  strips = new ArrayList();
  //int testVal=0;
  int tog=100;
  boolean diag = false;
  for (int i=0; i < stripNum; i++) {
    strips.add(new Strip(0, 0, 0, 0, 255, tog, diag));
  }
}

void initUnits() {
  units = new ArrayList();
  for (int i=0; i < unitNum; i++) {
    units.add(new Unit(i, (Strip)strips.get(i*4), (Strip)strips.get(i*4+1), (Strip)strips.get(i*4+2), (Strip)strips.get(i*4+3), subStripArray[i], typeArray[i], (PVector)locs.get(i)));
  }
}


//THE MASTER ARRAY FOR THE ON-SCREEN LOCATION OF THE OCTAGONS IN THE GUI. IF YOU CHANGE THESE VALUES EVERYTHING ELSE MOVES RELATIVE TO THESE CORDS 
//SO LAY OUT THE INTERFACE HOWEVER YOU LIKE. BECAUSE I LOVE YOU.

void initLocs() {
  locs = new ArrayList();
  locs.add(new PVector(700, 600));//1
  locs.add(new PVector(800, 500));//2
  locs.add(new PVector(700, 400));//3
  locs.add(new PVector(600, 500));//4
  locs.add(new PVector(500, 600));//5
  locs.add(new PVector(300, 600));//6
  locs.add(new PVector(400, 500));//7
  locs.add(new PVector(500, 400));//8
  locs.add(new PVector(600, 300));//9
  locs.add(new PVector(700, 200));//10
  locs.add(new PVector(900, 200));//11
  locs.add(new PVector(900, 400));//12
  locs.add(new PVector(1000, 300));//13
  locs.add(new PVector(1100, 200));//14
  locs.add(new PVector(1200, 850));//15
  locs.add(new PVector(850, 700));//16
  locs.add(new PVector(900, 600));//17
  locs.add(new PVector(450, 800));//18
  locs.add(new PVector(1100, 750));//19
  locs.add(new PVector(300, 700));//20
}


//CHECK TO SEE IF CLICKED A TOGGLE BOX TO TURN A OCTAGON FACE OFF OR ON. THIS ENABLES FULL MANUAL CONTROL OF WHICH UNITS ARE ACTIVE

void mouseClicked() {
  if (!diagMode) {
    for (int i=0; i < unitNum; i++) {
      Unit tu = (Unit)units.get(i);
      tu.checkManCon();
    }
  }
}


// OPENS UP A DIAGNOSTIC WINDOW WHEN YOU ROLL OVER THE AN OCTAGONS TOGGLE BOX
void keyPressed() {
  if (key == CODED && keyCode == SHIFT) {
    shiftPressed = true;
    println("SHIFT");
  }

  if (key ==' ') {
    spacePressed = !spacePressed;
  }
  if (key =='c'){
    colorPickerMode = !colorPickerMode;
  }
  
  if (key =='b') {
    beatMode = !beatMode;
    if (beatMode) {
      diagMode = false;
    }
  }

  if (key == 'd') {
    diagMode = !diagMode;
    if (diagMode) {
      beatMode = false;
    }
  }

  if (key == 'w') {
    waveTog = !waveTog;
    directionTog=1;
    beatMode = false;
    diagMode = false;
    waveTimer = millis();

  }

  if (key == 'g') {
    pGenerate();
  }
}

void keyReleased() {
  shiftPressed = false;
}


//SOUND FUNCTIONS BELOW -- FUCK WITH THEM AT YOUR OWN DISCRETION. SOMETHINGS IN LIFE ARE BEST LEFT ALONE.

PVector elapsedTime(int startTime) {
  int end = millis();
  int timeSpent = (end - startTime) / 1000; // Seconds spent
  int h = timeSpent / 3600;
  timeSpent -= h * 3600;
  int m = timeSpent / 60;
  timeSpent -= m * 60;
  //println("Spent: " +h + " hours, " +m + " minutes, " +timeSpent + " seconds");
  PVector r = new PVector(h, m, timeSpent);
  return r;
} 

private float average(float[] array) {
  float sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return (sum / array.length);
}


private float[] sum(float[] array, float[] array2) {
  float[] array3 = new float[array.length];
  for (int i = 0; i < array.length; i++) {
    array3[i] += array[i] + array2[i];
  }
  return (array3);
}

private void analyse() {

  // update our round robins heads
  int playhead2 = (playhead + 1) % nbAverage;
  int playheadLongTerm2 = (playheadLongTerm + 1) % nbAverageLongTerm;
  int playheadShortTerm2 = (playheadShortTerm + 1) % nbAverageShortTerm;

  int localAvg = 0;
  for (int i = 0; i < numZones; i++) {
    // get energy
    zoneEnergy[i][playhead2] = fft.getAvg(i)
      * (linearEQIntercept + i * linearEQSlope);
    // zoneEnergy[i][playhead2] = fft.getBand(i);

    // compute peaks
    if (zoneEnergy[i][playhead2] >= zoneEnergyPeak[i]) {
      // save new peak level, also reset the hold timer
      zoneEnergyPeak[i] = zoneEnergy[i][playhead2];
      zoneEnergyPeakHoldTimes[i] = peakHoldTime;
    } 
    else {
      // current average does not exceed peak, so hold or decay the
      // peak
      if (zoneEnergyPeakHoldTimes[i] > 0) {
        zoneEnergyPeakHoldTimes[i]--;
      } 
      else {
        zoneEnergyPeak[i] *= peakDecayRate;
      }
    }

    zoneEnergyVuMeter[i] = zoneEnergy[i][playhead2];

    zoneEnergyShortTerm[i][playheadShortTerm2] = zoneEnergy[i][playhead2];
    // System.out.println(zoneEnergy[i][playhead2]+" "+average(zoneEnergy[i]));

    // compute a per band score
    if (zoneEnergy[i][playhead2] > 0.3 && average(zoneEnergy[i]) > 0.1)
      zoneScore[i][playhead2] = zoneEnergy[i][playhead2]
        / average(zoneEnergy[i])
        * zoneEnergyShortTerm[i][playheadShortTerm2]
          / average(zoneEnergyShortTerm[i]);
    else
      zoneScore[i][playhead2] = 0;

    if (zoneEnabled[i]) {
      // println(zoneEnergy[i][playhead2]);
      localAvg += zoneEnergy[i][playhead2];
      if (zoneScore[i][playhead2] < 100) {
        score[playhead2] += zoneScore[i][playhead2];
      } 
      else {
        score[playhead2] += 100;
      }
      // if(zoneScore[i][playhead2]>25)
      // System.out.println(zoneScore[i][playhead2]);
    }
  }

  // pitch detect
  float maxE = 0;
  int bandmaxE = 0;
  int minBand = 0;
  int thres = 0;
  for (int i = minBand; i < numZones; i++) {
    if (zoneEnergy[i][playhead2] > maxE && zoneEnabled[i]) {
      bandmaxE = i;
      maxE = zoneEnergy[i][playhead2];
    }
  }

  if (bandmaxE != lastBand) {

    if (lastBandCount > thres) {
      // System.out.print(".\n");
    }
    lastBandCount = 0;
    // app.layers[0].sizee.v=0;
  } 
  else {
    if (thres == lastBandCount) {
      // System.out.print(bandmaxE+" "+fft.getBandWidth()*bandmaxE+"Hz ");
      if (bandmaxE > 0) {
        for (int i = 0; i <= bandmaxE; i++) {
          // System.out.print("#");
        }
      }
    }
    if (lastBandCount > thres) {
      // System.out.print(".");
    }
    lastBandCount++;
    // app.layers[0].sizee.v=bandmaxE%24/24f*4;
    // app.layers[0].sizee.v=bandmaxE%36/36f*4;
  }
  // app.layers[0].sizee.v=bandmaxE%12/12f*4;
  if (bandmaxE != lastBand) {
    //System.out.print(noteNames[(bandmaxE-3+12)%config_FFT_BAND_PER_OCT]+" "+bandmaxE/12+"\n");
  }

  lastBand = bandmaxE;

  // compute a global score
  int numZoneEnabled = 0;
  for (int ii = 0; ii < numZones; ii++)
    numZoneEnabled += (zoneEnabled[ii]) ? 1 : 0;
  if (numZoneEnabled == 0) {
    score[playhead2] = 0;
    scoreLongTerm[playheadLongTerm2] = 0;
  } 
  else {
    score[playhead2] = score[playhead2] / numZoneEnabled;
    scoreLongTerm[playheadLongTerm2] = score[playhead2]
      / numZoneEnabled;
  }

  // if(numZoneEnabled>0)
  // avg=localAvg/(1.0f*numZoneEnabled);
  // else
  // avg=0;
  float smooth = 0.9f;
  if (score2 * smooth < score[playhead2]) {
    score2 = score[playhead2];
  } 
  else {
    score2 *= smooth;
  }

  // are we on the beat ?
  if (skipFrames <= 0 && score[playhead2] > beatSense) {// &&
    // score[playhead2]>max-(max-min)/4){
    onBeat = true;
    skipFrames = repeatDelay;
  }
  if (skipFrames > 0)
    skipFrames--;

  // compute auto beat sense
  float max = max(score);
  if (max > 30)
    max = 30;
  // float min = min(score);
  float avg = average(scoreLongTerm);
  if (avg < 1.5)
    avg = 1.5f;
  if (autoBeatSense && max > 1.1) {
    // beatSense = beatSense*0.99 +0.01*max*0.6;
    beatSense = beatSense * 0.995f + 0.002f * max * beatSenseSense
      + 0.003f * avg * beatSenseSense;
    // if(variance(score)>1)
    // beatSense=0.99*beatSense + beatSenseSense*(0.01*variance(score));
    if (beatSense < 1.1)
      beatSense = 1.1f;
  }

  // System.out.println(" max:"+max+" min:"+min+" avg:"+avg+" var:"+average(score));

  // make our round robin heads public
  playhead = playhead2;
  playheadShortTerm = playheadShortTerm2;
  playheadLongTerm = playheadLongTerm2;

  //System.out.println("threshold : "+this.beatSense);
  //System.out.println("current score : "+this.score2);
  //System.out.println("on Beat : "+this.onBeat);
}

void CalcBeatAndDrawSoundViz(int ratio, int wSize) {
  int my=250;
  int VoffSet = 600;
  //background(0, 0, 0);

  int bandWidth = wSize / numZones;

  //beat block
  if (onBeat||delay>0) {
    if (onBeat) {
      delay=5;
      onBeat=false;
    }
    delay--;
    fill(255, 0, 0);
    noStroke();
    rect(800, 15+VoffSet+100, 100, 100);
    textSize(24);
    text("BEAT", 800, 15+VoffSet+100);
  }

  //score
  if (score2>beatSense) {
    fill(score2 * 10 + 55, 0, 0);
  }
  else {
    fill(0, 0, score2 * 10 + 55);
  }
  rect(15, 15+VoffSet+100, (int)score2*30/2, 15);
  fill(0, 0, score2 * 200 + 55);
  rect(15, 35+VoffSet+100, beatSense*30, 15);

  // general level
  fill(level * level * level * 200 + 55, 50, 50);
  noStroke();
  rect(numZones + 10 + (numZones * bandWidth + 1), (10+my)+(VoffSet), 
  bandWidth*3, ratio * (scaleEq ? ScaleIEC(leveldB) : level));



  if (numZones != 0) {
    // vumeter
    for (int i = 0; i < numZones; i++) {

      int r = 50;
      int g = 50;
      int b = 50;

      if (zoneEnabled[i]) {
        r = (int) zoneScore[i][playhead] * 25 + 50;
      }
      if (i == lastBand) {
        g = 255;
      } 
      else if (i % config_FFT_BAND_PER_OCT == lastBand % config_FFT_BAND_PER_OCT) {
        b = 255;
      }
      fill(r, g, b);
      noStroke();
      rect(i + 10 + (i * bandWidth + 1), (10+my)+VoffSet, bandWidth, 
      ratio
        * ((scaleEq ? ScaleIEC(10f * (float) Math
        .log(zoneEnergyVuMeter[i] / 250f))
        : zoneEnergy[i][playhead])));

      // average
      noStroke();
      if (zoneEnabled[i]) {
        fill(200, 200, 200);
      } 
      else {
        fill(80, 80, 80);
      }
      rect(i + 10 + (i * bandWidth + 1), (10 +my
        + ratio
        * (scaleEq ? ScaleIEC(10 * (float) Math
        .log(average(zoneEnergy[i]) / 250))
        : average(zoneEnergy[i])))+VoffSet, bandWidth, 1);

      // peaks
      noStroke();
      fill(0, 0, 200);
      rect(i + 10 + (i * bandWidth + 1), (10+my
        + ratio
        * (scaleEq ? ScaleIEC(10 * (float) Math
        .log(zoneEnergyPeak[i] / 250))
        : zoneEnergyPeak[i]))+VoffSet, bandWidth, 1);

      // zone score (at the bottom
      if (zoneEnergy[i][playhead] > average(zoneEnergy[i])) {
        fill(zoneScore[i][playhead]
          / average(zoneScore[i]) * 50);
        noStroke();
        rect(i + 10 + (i * bandWidth + 1), (13+my)+VoffSet, 
        bandWidth, 5);
      }
    }

    //sum per octave
    for (int i = 0; i < numZones&i<config_FFT_BAND_PER_OCT; i++) {

      int r = 50;
      int g = 50;
      int b = 50;

      float sum = 0;
      float sumScore = 0;
      int count=0;
      for (int j=0 ;i+j*config_FFT_BAND_PER_OCT < numZones; j++) {
        if (zoneEnabled[i+j*config_FFT_BAND_PER_OCT]) {
          sum+=zoneEnergy[i+j*config_FFT_BAND_PER_OCT][playhead];
          //zoneEnergyVuMeter[j*12]
          sumScore+=zoneScore[i+j*config_FFT_BAND_PER_OCT][playhead];
          count++;
        }
      }
      if (count>0) {
        sum = sum /count;
        sumScore = sumScore /count;
      }
      else {
        sum=0;
        sumScore=0;
      }

      r = (int) sumScore* 25 + 50;
      if (i % config_FFT_BAND_PER_OCT == lastBand % config_FFT_BAND_PER_OCT) {
        g = 255;
      }
      fill(r, g, b);
      noStroke();
      rect(bandWidth*2+i + 10 + (i * bandWidth + 1)+ (numZones + 10 + (numZones * bandWidth + 1)), (10+my)+VoffSet, bandWidth, 
      ratio
        * ((scaleEq ? ScaleIEC(10f * (float) Math
        .log(sum / 250f))
        :sum )));
    }
  }
}

//CLOSE THE SOUND PORT IF YOU DONT IT WILL CRASH YOUR MACHINE

public void stop() {
  input.close();
  minim.stop();
}

/*
used to control stuff with the sound :)
 use on beat and score2.
 	 */
boolean control() {

  // sound control :)
  boolean localOnBeat = false;

  if (onBeat) {
    float minimumSpace = (1000 / config_BPM * 60.0f / 2.0f);
    long space = System.currentTimeMillis() - lastbeatTimestamp;
    lastbeatTimestamp = System.currentTimeMillis();
    //onBeat = false;
    if (space > minimumSpace) {
      localOnBeat = true;
      //System.out.println("beat");
    } 
    else {
      // int a=1;
      System.out.println(space+" : skipped. shorter than" +
        minimumSpace+"ms");
    }
  }


  float v = score2 * score2 / beatSense / beatSense / 3f;
  //System.out.println(v);

  if (modulation * (1f-modulationSmooth) > v)
    modulation *= (1f-modulationSmooth);
  else
    modulation = (1f-modulationSmooth) * v + modulationSmooth * modulation;
  if (modulation > 1f)
    modulation = 1f;

  return localOnBeat;
}

private float ScaleIEC(float db) {
  float pct = 0.0f;

  if (db < -70.0)
    pct = 0.0f;
  else if (db < -60.0)
    pct = (db + 70.0f) * 0.25f;
  else if (db < -50.0)
    pct = (db + 60.0f) * 0.5f + 2.5f;
  else if (db < -40.0)
    pct = (db + 50.0f) * 0.75f + 7.5f;
  else if (db < -30.0)
    pct = (db + 40.0f) * 1.5f + 15.0f;
  else if (db < -20.0)
    pct = (db + 30.0f) * 2.0f + 30.0f;
  else if (db < 0.0)
    pct = (db + 20.0f) * 2.5f + 50.0f;
  else
    pct = 100.0f;

  return pct;
}

void drawOctagonGUI() {
  for (int i=0; i < unitNum; i++) {
    Unit tu = (Unit)units.get(i);
    if (spacePressed) {
      tu.toggleToggle=true;
    }
    else {
      tu.toggleToggle=false;
    }
    tu.display();
  }
}


void drawMisc() {
  fill(255, 255, 255);
  textSize(32);
  text("OCTAGON 4D LIGHTING", 10, 80);
  textSize(18);
  text("Hours: "+(int)eTime.x +"  Minutes: "+(int)eTime.y+"  Seconds: "+(int)eTime.z, 10, 100);
  text("Audio Input and Beat Detection", 10, 700);
  if (spacePressed) {
    //println("Octagon Manual Control");
    fill(255, 255, 255);
    textSize(18);
    text("Simple Manual Control of Octagons ON  -- PRESS SPACEBAR", 10, 120);
  }
  else {
    //println("Octagon Manual Control");
    fill(255, 255, 255);
    textSize(18);
    text("Simple Manual Control of Octagons OFF -- press SPACEBAR", 10, 120);
  }

  if (beatMode) {
    //println("Octagon Beat Control");
    fill(255, 255, 255);
    textSize(18);
    text("Beat control is ON  -- PRESS 'b'", 10, 140);
  }
  else {
    //println("Octagon Beat Control");
    fill(255, 255, 255);
    textSize(18);
    text("Beat control is OFF  -- PRESS 'b'", 10, 140);
  }


  if (diagMode) {
    // println("Octagon Diagnostic Control");
    fill(255, 255, 255);
    textSize(18);
    text("Diagnostic Mode is ON  -- PRESS 'd'", 10, 160);
  }
  else {
    //println("Octagon Diagnostic Control");
    fill(255, 255, 255);
    textSize(18);
    text("Diagnostic Mode is OFF  -- PRESS 'd'", 10, 160);
    /*int EdgeRed=0;
     int EdgeBlue = 0;
     int EdgeGreen = 0;
     
     int DownwardRed=0;
     int DownwardBlue = 0;
     int DownwardGreen = 0;
     
     int ReflectiveRed=0;
     int ReflectiveBlue = 0;
     int ReflectiveGreen = 0;
     
     int StripeRed=0;
     int StripeBlue = 0;
     int StripeGreen = 0;*/

    cp5.getController("EdgeRed").setValue(0);
    cp5.getController("EdgeGreen").setValue(0);
    cp5.getController("EdgeBlue").setValue(0);
    cp5.getController("EdgeSpeed").setValue(0);

    cp5.getController("DownwardRed").setValue(0);
    cp5.getController("DownwardGreen").setValue(0);
    cp5.getController("DownwardBlue").setValue(0);
    cp5.getController("DownwardSpeed").setValue(0);

    cp5.getController("ReflectiveRed").setValue(0);
    cp5.getController("ReflectiveGreen").setValue(0);
    cp5.getController("ReflectiveBlue").setValue(0);
    cp5.getController("ReflectiveSpeed").setValue(0);

    cp5.getController("StripeRed").setValue(0);
    cp5.getController("StripeGreen").setValue(0);
    cp5.getController("StripeBlue").setValue(0);
    cp5.getController("StripeSpeed").setValue(0);

    cp5.hide();
  }

  textSize(8);
  text("* Roller-over an Octagon while holding TAB for more DMX Data", 10, 180);
  text("* Roller-over an Octagon and click the  to open/close the manual diagnostic input", 10, 190);
  textSize(12);
}

void drawDiagGUI() {
  fill(100, 100, 100);
  textSize(12);
  text("Diagnostic Window", 10, 225);
  cp5.show();
}


public class ColorPicker 
{
  int x, y, w, h, c;
  PImage cpImage;
  
  public ColorPicker ( int x, int y, int w, int h, int c )
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    
    cpImage = new PImage( w, h );
    
    init();
  }
  
  private void init ()
  {
    // draw color.
    int cw = w - 60;
    for( int i=0; i<cw; i++ ) 
    {
      float nColorPercent = i / (float)cw;
      float rad = (-360 * nColorPercent) * (PI / 180);
      int nR = (int)(cos(rad) * 127 + 128) << 16;
      int nG = (int)(cos(rad + 2 * PI / 3) * 127 + 128) << 8;
      int nB = (int)(Math.cos(rad + 4 * PI / 3) * 127 + 128);
      int nColor = nR | nG | nB;
      
      setGradient( i, 0, 1, h/2, 0xFFFFFF, nColor );
      setGradient( i, (h/2), 1, h/2, nColor, 0x000000 );
    }
    
    // draw black/white.
    drawRect( cw, 0,   30, h/2, 0xFFFFFF );
    drawRect( cw, h/2, 30, h/2, 0 );
    
    // draw grey scale.
    for( int j=0; j<h; j++ )
    {
      int g = 255 - (int)(j/(float)(h-1) * 255 );
      drawRect( w-30, j, 30, 1, color( g, g, g ) );
    }
  }

  private void setGradient(int x, int y, float w, float h, int c1, int c2 )
  {
    float deltaR = red(c2) - red(c1);
    float deltaG = green(c2) - green(c1);
    float deltaB = blue(c2) - blue(c1);

    for (int j = y; j<(y+h); j++)
    {
      int c = color( red(c1)+(j-y)*(deltaR/h), green(c1)+(j-y)*(deltaG/h), blue(c1)+(j-y)*(deltaB/h) );
      cpImage.set( x, j, c );
    }
  }
  
  private void drawRect( int rx, int ry, int rw, int rh, int rc )
  {
    for(int i=rx; i<rx+rw; i++) 
    {
      for(int j=ry; j<ry+rh; j++) 
      {
        cpImage.set( i, j, rc );
      }
    }
  }
  
  public void render ()
  {
    image( cpImage, x, y );
    if( mousePressed &&
  mouseX >= x && 
  mouseX < x + w &&
  mouseY >= y &&
  mouseY < y + h )
    {
      c = get( mouseX, mouseY );
    }
    fill( c );
    rect( x, y+h+10, 20, 20 );
    manualColor = c;
  }
}
