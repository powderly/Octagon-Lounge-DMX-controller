#include "driver_config.h"
#include "target_config.h"

#include "gpio.h"
#include "small_gpio.h"
#include "timer32.h"

#include "dmx.h"
#include "WS2801.h"
#include "WS2801_utils.h"
#include "switch.h"
#include "strip.h"

#include <math.h>

#define INDICATOR_LED_PORT 3
#define INDICATOR_LED_BIT 5

// Channel Info
// 1st - Red
// 2nd - Green
// 3nd - Blue
// 4th - Mode for animation
// 5th - Substrips Select [1..8]

#define RED_CHANNEL 0
#define GREEN_CHANNEL 1
#define BLUE_CHANNEL 2
#define MODE_CHANNEL 3
#define SUBSTRIP_CHANNEL 4

// animation mode
#define DIRECT 0
#define DOTFLOW 1
#define RAINBOW 32
#define NOISE 124
#define SINEWAVE_DIMMING  125

// for dotflow speed
#define DOTFLOW_DEFAULT_SPEED 20

// start DMX channel
uint16_t DMX_channel;

//OCTAGON OR SQUARE DEFINE
#define SQUARE 1;
//// SETUP
void Strip_setup() {
        strips[0] = Strip_new(50, 0,1);
        strips[1] = Strip_new(160, 2,3);
        strips[2] = Strip_new(160, 4,5);
        strips[3] = Strip_new(160, 6,7);

        //set the strip face manually for the UNIT programming

        // strip face
        //UNIT 1 -- A1
        //strips[0]->substrips = 1; // number of substrips
        //strips[0]->substrip_pixels = (uint8_t*) malloc(strips[0]->substrips
* sizeof(uint8_t));
        //strips[0]->substrip_pixels[0] = 50;
    //UNIT 1 END

        //UNIT 2 -- B7
        //strips[0]->substrips = 1; // number of substrips
    //strips[0]->substrip_pixels = (uint8_t*)
malloc(strips[0]->substrips * sizeof(uint8_t));
        //strips[0]->substrip_pixels[0] = 16;
        //UNIT 2 END

        //UNIT 3 -- A5
        //strips[0]->substrips = 2; // number of substrips
        //strips[0]->substrip_pixels = (uint8_t*) malloc(strips[0]->substrips
* sizeof(uint8_t));
    //strips[0]->substrip_pixels[0] = 44;
    //strips[0]->substrip_pixels[1] = 38;
    //UNIT 3 END

        //UNIT 4 B1
    //strips[0]->substrips = 2; // number of substrips
    //strips[0]->substrip_pixels = (uint8_t*)
malloc(strips[0]->substrips * sizeof(uint8_t));
    //strips[0]->substrip_pixels[0] = 14;
    //strips[0]->substrip_pixels[1] = 13;
    //UNIT 4 END

    //UNIT 5 A8
    //strips[0]->substrips = 3; // number of substrips
    //strips[0]->substrip_pixels = (uint8_t*)
malloc(strips[0]->substrips * sizeof(uint8_t));
    //strips[0]->substrip_pixels[0] = 45;
    //strips[0]->substrip_pixels[1] = 39;
    //strips[0]->substrip_pixels[2] = 43;
    //UNIT 5 END

         //UNIT 6 A9
         strips[0]->substrips = 2; // number of substrips
         strips[0]->substrip_pixels = (uint8_t*) malloc(strips[0]->substrips
* sizeof(uint8_t));
         strips[0]->substrip_pixels[0] = 28;
         strips[0]->substrip_pixels[1] = 50;
         //UNIT 6 END

        //choose either square of octagon unit for the rest of the faces

        //OCTAGON UNIT
        // edge
                strips[1]->substrips = 8;
                strips[1]->substrip_pixels = (uint8_t*) malloc(strips[1]->substrips
* sizeof(uint8_t));
                strips[1]->substrip_pixels[0] = 17;
                strips[1]->substrip_pixels[1] = 17;
                strips[1]->substrip_pixels[2] = 17;
                strips[1]->substrip_pixels[3] = 17;
                strips[1]->substrip_pixels[4] = 17;
                strips[1]->substrip_pixels[5] = 17;
                strips[1]->substrip_pixels[6] = 17;
                strips[1]->substrip_pixels[7] = 17;

                // face
                strips[2]->substrips = 4;
                strips[2]->substrip_pixels = (uint8_t*) malloc(strips[2]->substrips
* sizeof(uint8_t));
                strips[2]->substrip_pixels[0] = 24;
                strips[2]->substrip_pixels[1] = 42;
                strips[2]->substrip_pixels[2] = 42;
                strips[2]->substrip_pixels[3] = 24;

                // reflective back
                strips[3]->substrips = 8;
                strips[3]->substrip_pixels = (uint8_t*) malloc(strips[3]->substrips
* sizeof(uint8_t));
                strips[3]->substrip_pixels[0] = 20;
                strips[3]->substrip_pixels[1] = 20;
                strips[3]->substrip_pixels[2] = 20;
                strips[3]->substrip_pixels[3] = 20;
                strips[3]->substrip_pixels[4] = 20;
                strips[3]->substrip_pixels[5] = 20;
                strips[3]->substrip_pixels[6] = 20;
                strips[3]->substrip_pixels[7] = 20;
  /*
        //SQUARE UNIT
        // edge
                strips[1]->substrips = 8;
                strips[1]->substrip_pixels = (uint8_t*) malloc(strips[1]->substrips
* sizeof(uint8_t));
                strips[1]->substrip_pixels[0] = 13;
                strips[1]->substrip_pixels[1] = 13;
                strips[1]->substrip_pixels[2] = 13;
                strips[1]->substrip_pixels[3] = 13;
                strips[1]->substrip_pixels[4] = 13;
                strips[1]->substrip_pixels[5] = 13;
                strips[1]->substrip_pixels[6] = 13;
                strips[1]->substrip_pixels[7] = 13;

                // down face
                strips[2]->substrips = 4;
                strips[2]->substrip_pixels = (uint8_t*) malloc(strips[2]->substrips
* sizeof(uint8_t));
                strips[2]->substrip_pixels[0] = 12;
                strips[2]->substrip_pixels[1] = 12;
                strips[2]->substrip_pixels[2] = 11;
                strips[2]->substrip_pixels[3] = 11;

                // reflective back
                strips[3]->substrips = 8;
                strips[3]->substrip_pixels = (uint8_t*) malloc(strips[3]->substrips
* sizeof(uint8_t));
                strips[3]->substrip_pixels[0] = 16;
                strips[3]->substrip_pixels[1] = 16;
                strips[3]->substrip_pixels[2] = 16;
                strips[3]->substrip_pixels[3] = 16;
                strips[3]->substrip_pixels[4] = 16;
                strips[3]->substrip_pixels[5] = 16;
                strips[3]->substrip_pixels[6] = 16;
                strips[3]->substrip_pixels[7] = 16;
*/
}

void Status_led_setup()
{
         GPIOSetDir(INDICATOR_LED_PORT, INDICATOR_LED_BIT, 1 );
         GPIOSetValue(INDICATOR_LED_PORT, INDICATOR_LED_BIT, ON);
}

void Timer_setup()
{
        init_timer32(0, TIME_INTERVAL); // raise interrupt per 2.5 ms
}

void DMX_setup()
{
        DMXInit(250000);
        DMX_channel = get_dmx_channel();
}

void Setup()
{
        GPIOInit();

        Strip_setup();
        Timer_setup();
        DMX_setup();
}


//// Set DMX data to strips!
void toggle_status_led()
{
        ToggleGPIOBit(INDICATOR_LED_PORT,INDICATOR_LED_BIT);
}

void Set_animation_mode(Strip** strips)
{
        uint8_t i;
        for (i=0; i<NUMBER_OF_STRIP; i++) {
                strips[i]->mode = DMX_buf[DMX_channel+(5*i)+MODE_CHANNEL];  // 5 is
channel size of one strip.
        }
}

void Set_substrip(Strip** strips)
{
        uint8_t i;
        for (i=0; i<NUMBER_OF_STRIP; i++) {
                strips[i]->mask = DMX_buf[DMX_channel+(5*i)+SUBSTRIP_CHANNEL];
        }
}

void set_substrip_color(Strip* strip,uint8_t strip_index, uint32_t color) {
        uint8_t j;
        uint8_t start_index = 0;

        for (j=0; j< strip_index; j++) {
                start_index += strip->substrip_pixels[j];
        }

        for (j=0; j< strip->substrip_pixels[strip_index]; j++) {
                Strip_setPixel(strip,start_index + j,color);
        }
}

void Strip_setDirect(Strip* strip) {
        uint8_t k;

        for (k=0; k<strip->substrips; k++) {
                if ((strip->mask & (int) pow(2,k)) >= 1) {
                        set_substrip_color(strip, k,strip->color); // turn on substrips
                }
        }
}

void dotflow(Strip* strip, uint8_t tails)
{
        uint8_t i;

        for (i=0; i<tails; i++) {
                Strip_setPixel(strip,strip->cursor+(strip->cursor_direction*i),strip->color);
        }
}

void Strip_setDotflow(Strip* strip)
{
          strip->cursor_speed = (int) strip->mode & 127;
          if (strip->cursor_speed < DOTFLOW_DEFAULT_SPEED) {
                  dotflow(strip,5); // 5 is default tail length.
          } else {
                  dotflow(strip,strip->cursor_speed-DOTFLOW_DEFAULT_SPEED+5);
          }
}

uint8_t Get_stripMode(Strip* strip)
{
        if(strip->mode & 128)
        {
                strip->cursor_direction = BACKWARD;
        } else {
                strip->cursor_direction = FORWARD; // FORWARD direction!
        }

        if (strip->mode == DIRECT) return DIRECT;
        if ((strip->mode & 127) < DOTFLOW+31) return DOTFLOW;
}

void Set_pixel(Strip** strips)
{
          uint8_t i;
          uint8_t mode;

          for(i=0; i<NUMBER_OF_STRIP; i++)
          {
                  strip = strips[i];
                  mode = Get_stripMode(strip);
                  if (mode == DIRECT) {
                          Strip_setDirect(strip);
                  } else if (mode == DOTFLOW) {
                          Strip_setDotflow(strip);
                  }
          }
}

void nextCursor(Strip* strip)
{
        if (strip->cursor_direction == BACKWARD) {
                strip->cursor = strip->cursor - 1;
                if (strip->cursor <= 0) {
                        strip->cursor = strip->length;
                }
        }else {
                strip->cursor = strip->cursor + 1;
                if (strip->cursor >= strip->length)
                {
                        strip->cursor=0;
                }
        }
}

void nextCursor_fast(Strip* strip)
{
        if (strip->cursor_direction == BACKWARD) {

                strip->cursor = strip->cursor + strip->cursor_direction *
(strip->cursor_speed - DOTFLOW_DEFAULT_SPEED + 1);
                if (strip->cursor <= 0) {
                        strip->cursor = strip->length;
                }
        } else {
                strip->cursor = strip->cursor + strip->cursor_direction *
(strip->cursor_speed - DOTFLOW_DEFAULT_SPEED + 1);
                if (strip->cursor >= strip->length)
                {
                        strip->cursor=0;
                }
        }
}


void Set_speed(Strip** strips)
{
        uint8_t i;
        for(i=0; i<NUMBER_OF_STRIP; i++)
        {
                strip = strips[i];

                if (strip->cursor_speed < DOTFLOW_DEFAULT_SPEED) { // 20 is threshold speed
                        if (strip->frame_count >= (DOTFLOW_DEFAULT_SPEED - strip->cursor_speed)) {
                                nextCursor(strip);
                                strip->frame_count = 0;
                        } else {
                                strip->frame_count++;
                        }
                } else {
                        nextCursor_fast(strip);
                }
        }
}

uint32_t get_DMX_color(uint8_t strip_index) {
        return color(DMX_buf[DMX_channel+(strip_index*5)],DMX_buf[DMX_channel+(strip_index*5)+1],DMX_buf[DMX_channel+(strip_index*5)+2]);
}

void Set_color(Strip** strips)
{
        uint8_t i;
        for(i=0; i<NUMBER_OF_STRIP; i++)
        {
                strips[i]->color = get_DMX_color(i);
        }
}

int main (void) {
        Setup();

        while (1)
        {
                if (rx_count !=0) {
                        Set_color(strips);
                        Set_substrip(strips); // get sub strip channel!
                        Set_animation_mode(strips);
                }
                Set_pixel(strips);
                Set_speed(strips);
                Strip_shows(strips);
  }

  Strip_free(strips[0]);
  Strip_free(strips[1]);
  Strip_free(strips[2]);
  Strip_free(strips[3]);
  return 0;
}