#include <stdio.h>

/* For now, use the USB cable instead of bluetooth. */

int door_state = 0;

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

// Defined here to reduce binary size.
char STR_HIGH[] =  "High";
char STR_LOW[] = "Low";

/**
 * @brief Recieve a character of input from the input source
 * @details This particular implementation is a wrapper for the Serial.read()
 *  command. It is written in an I/O file to allow orthogonal code to be written
 *  when an interface might need to be quickly re-implemented. These functions
 *  should all return one byte of data to the user.
 * @returns a single byte of data from an input source.
 */
char get_input(void)
{
  return Serial.read();
}

void output(const char *message)
{
  Serial.println(message);
}

void output(char letter)
{
  Serial.print(letter);
}

int input_ready(void)
{
  return Serial.available();
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

void ack(const char* message)
{
  output((char)1);
  output(message);
}

void nak(const char message[])
{
  output((char)0);
  output(message);
}

void setup()
{
  int i;
  Serial.begin(9600);
  for (i=0; i < 4; ++i)
  {
    pinMode(relay_pins[i],OUTPUT);
  }
  
}

void loop()
{
  if(input_ready())
  {
    int in_value = get_input();
    /* Replace a series of If-ElseIf-Else with a simple switch.
     * This code is the sum of the following bits:
     * 8: 1 iff the request state and door state mismatch, 0 if they match.
     * 4: 1 iff a query was part of the request, 0 otherwise
     * 2: 1 iff the query should change door state
     * 1: 1 iff the end state should be closed.
     */
    in_value = in_value | ((door_state ^ (in_value & 1)) << 3);
    Serial.print(in_value);
    switch(in_value)
    {
      /* Sent NAK, door is open. */
      case 0:
      /* Sent NAK, door is closed. */
      case 8:
        nak("Not Acknowledged.");
        break;
      /* Sent ACK, door is open. */
      case 1:
      /* Sent ACK, door is closed. */
      case 9:
        ack("Acknowledged");
        break;
      /* Sent Open, door is open. */
      case 2:
        nak("Door is already open.");
        break;
      /* Sent Close, door is already closed. */
      case 3:
        nak("Door is already closed.");
        break;
      /* Sent query, door is open. */
      case 4:
      /* Sent Query And Open, door is open - No action, return true. */
      case 6:
        ack("Door is open.");
        break;
      /* Sent Query closed, door is closed */
      case 5:
        ack("Door is closed.");
        break;
      /* Sent Query and Open, door is closed - Open door, return true. */
      case 7:
        ack("Door is closing.");
        relay_action(3,2);
        delay(200);
        relay_action(3,2);
        door_state = !door_state;
        break;
      /* Force Open, door is closed. */
      case 10:
      /* Query and open, door is closed. */
      case 14:
        ack("Door is opening.");
        relay_action(3,2);
        delay(200);
        relay_action(3,2);
        door_state = !door_state;
        break;
      /* Force Close, door is open. */
      case 11:
      /* Query and close, door is open. */
      case 15:
        ack("Door is closing.");
        relay_action(3,2);
        delay(200);
        relay_action(3,2);
        door_state = !door_state;
        break;
      /* Query, Door is closed. */
      case 12:
        nak("Door is closed.");
        break;
      /* Query closed, door is open. */
      case 13:
        nak("Door is open.");
        break;
    }
  }
}
