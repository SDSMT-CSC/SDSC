#include <stdio.h>

enum STATES
{
  OPEN,
  OPENING,
  CLOSED,
  CLOSING,
  PARTIAL    
};

unsigned long time;
STATES current_state = OPEN;


void setup()
{
  Serial.begin(9600);
  pinMode(7, OUTPUT );
}


void loop()
{
  if( Serial.available() )
  {
    char value = Serial.read();
    
    if( value == '1' )
    {
      digitalWrite( 7, HIGH );
      delay(200);
      digitalWrite( 7, LOW );
      time = millis();
      if( current_state == OPEN || current_state == PARTIAL )
      {
        current_state = CLOSING;
      }
      else if( current_state == CLOSED || current_state == CLOSING )
      {
        current_state = OPENING;
      }
      else// current_state == OPENING
      {        
        current_state = PARTIAL;
      }
    }
    
    if( value == '2' )
      Serial.println( current_state );
  }

  //if it has been nine and a half seconds and
  //the garage door is opeinging or closing
  if( (millis() - time) > 9500 && 
      (current_state == OPENING || current_state == CLOSING) )
  {
    if( current_state == OPENING )
    {
      current_state = OPEN;
    }
    else// current_state == CLOSING
    { 
      current_state = CLOSED;
    }
  }
}
