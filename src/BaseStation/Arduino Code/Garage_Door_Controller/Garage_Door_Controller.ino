#include <stdio.h>

enum STATES
{
  OPEN,
  OPENING,
  CLOSED,
  CLOSING,
  PARTIAL    
};

unsigned long time = -1;
unsigned long elapsed_time = 0;
STATES current_state;


void setup()
{
  Serial.begin(9600);
  pinMode(7, OUTPUT );
  pinMode(2, INPUT);
  pinMode(3, INPUT);
  
  //Find the current state of the garage door
  if( analogRead(2) > 1000 )
    current_state = OPEN;
  else if( analogRead(3) > 1000 )
    current_state = CLOSED;
  else
    current_state = PARTIAL; 
}


void loop()
{
  if( Serial.available() )
  {
    char value = Serial.read();
    Error( 0, "" );
    
    if( value == '0' )
    {      
      digitalWrite( 7, HIGH );
      delay(200);
      digitalWrite( 7, LOW );
      
      switch( current_state )
      {
        case OPEN:
          current_state = CLOSING;
          time = millis();
          break;
          
        case OPENING:
          current_state = PARTIAL;
          //set the time to the elapsed time
          elapsed_time = millis() - time;
          time = -1;
          break;
          
        case CLOSED:
          current_state = OPENING;
          time = millis();
          break;
          
        case CLOSING:
          current_state = OPENING;
          //offset the time by the time already elapsed
          time = millis() + 9500 - (millis() - time);
          break;
          
        case PARTIAL:
          current_state = CLOSING;
          //Set the time to the time that has already elapsed
          time = millis() - elapsed_time;
          break;
      }
    }
    
    if( value == '1' )
      Serial.print( current_state );
  }

  //if it has been nine and a half seconds and
  //the garage door is opeinging or closing
  if( (millis() - time) > 9500 && 
      (current_state == OPENING || current_state == CLOSING) )
  {
    if( analogRead(2) > 1000 )
    {
      //if( current_state == CLOSING )
        //Error( 1, "Object in door" );
      current_state = OPEN;
      time = -1;
    }
    else if( analogRead(3) > 1000 )
    {
      current_state = CLOSED;
      time = -1;
    }
  }
}


void Error( int error_code, String message )
{
  int i;
  
  for(i = message.length(); i < 127; i++)
  {
    message += "\0";
  }
  
  Serial.print( error_code );
  Serial.print( message );
}
