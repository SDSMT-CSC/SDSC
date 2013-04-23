/***************************************************************************//**
 * serial_switches.cpp
 * @description Sample code to show how a relay can be set or cleared using 
 * serial commands.  This does not conform to the protocol which is being 
 * developed for the system, but does give the general concepts necessary for 
 * controlling the relay boards over a serial connection. This file will be 
 * depricated once we have the protocol finalized, and will probably not see 
 * much use. Committed to the repo because we're required to commit regularly, 
 * and this is what I've done in the last few days.
 * @author Christopher Jensen
 ******************************************************************************/
#include <stdio.h>

// Defined here to reduce binary size.
char STR_HIGH[] =  "High";
char STR_LOW[] = "Low";

/* The relay pins are not 0-based. They're technically pins 4-7 instead of 0-3.
 * This array lets us use 0-based indices anyway, and makes the code slightly
 * more readable.
 */
unsigned char relay_pins[] = {4,5,6,7};
/* Each pin has a state which we need to track. The states should be read-only
 * outside of this file. In the actual library, I think private members of a
 * class with accessors may be called for. For now, simply know that they need
 * to reflect the state of each pin correctly. All updates to one MUST update
 * the other. The values should be 0 or 1, otherwise undefined behavior MAY
 * occur.
 */
unsigned char relay_states[] = {0,0,0,0};

/* Initialization routine. This is always called setup() in the arduino 
 * environment.*/
void setup()
{
  int i;
  Serial.begin(9600);
  for ( i = 0; i < 4; ++i)
  {
    pinMode(relay_pins[i],OUTPUT);
  }
}

/* Wrapper function for reading input. This is used so the proposed library
 * functions can be implemented, along with the next few functions. I figure out
 * my API best by actually trying to code something (Proof by prototyping, I
 * guess?), so these functions will become the first ones in the library.
 */
char get_input()
{
  return Serial.read();
}

void output(char message[])
{
  Serial.println(message);
}

void output(char letter)
{
  Serial.print(letter);
}

int input_ready()
{
  return Serial.available();
}

int get_buffer_size()
{
  int size = buffer_end - buffer_begin;
  return (size >= 0 ? size : 80);
}

/**
 * @brief Perform an action on a relay: Set to set high, clear to set low, or toggle to change value.
 * @param relay_number Number of the relay to be modified.
 * @param action Action to be performed: 
 * 0: clear
 * 1: set
 * 2: toggle (Technically, read then toggle.)
 * 3: clear (Technically, set then toggle.)
 * Other action values may cause undefined behavior.
 */
 void relay_action(int relay_number, int action)
{
  int a = (action & 2) >> 1;                // Second bit in action
  int b = action & 1;                       // First bit in action
  int c = ~(relay_states[relay_number]) & 1;// Complement of first bit in relay state of corresponding relay number
  char message[80];
  // Use a K-map if you don't understand the logic here.
  relay_states[relay_number] = (b | (c & a)) & 1;
  digitalWrite(relay_pins[relay_number], (relay_states[relay_number] ? HIGH : LOW));
  sprintf(message, "Setting Pin %d %s.", relay_number, (relay_states[relay_number] ? STR_HIGH : STR_LOW));
  output(message);
}

/**
 * @description Iteratively polls for input, then takes corresponding actions.
 * I hope to replace most of this with a call to a function array for the "real"
 * implementation, but this is set up to prototype the relays and allow me to
 * quickly debug. 
 ******************************************************************************/
void loop()
{
  int i;
  char message[80];
  if(input_ready())
  {
    int next_element = buffer_end + 1;
    char in_value = get_input();
    switch(in_value)
    {
      /* Newline flushes the buffer. */
      
      /* Values 1:4 toggle individual values. */
      case 1:
      case 2:
      case 3:
      case 4:
          relay_action(in_value - 1, 2);
        break;
      case 'C':
      case 'c':
        sprintf(message, "Setting all pins low.\n");
        output(message);
        for (i = 0; i < 4; ++i)
        {
          relay_action(i, 0);
        }
        break;
      case 'S':
      case 's':
        sprintf(message, "Setting all pins high.\n");
        for(i = 0; i < 4; ++i)
        {
          relay_action(i, 1);
        }
        break;
      case 'T':
      case 't':
        sprintf(message, "Toggling all pins.\n");
        for(i = 0; i < 4; ++i)
        {
          relay_action(i, 2);
        }
        break;
      case 'q':
      case 'Q':
        for(i = 0; i < 4; ++i)
        {
          sprintf(message, "Relay %d is in state %d", i, relay_states[i]);
          output(message);
        }
    } /* End of switch statement */
  }   /* End of available serial check */
}     /* End of main */
