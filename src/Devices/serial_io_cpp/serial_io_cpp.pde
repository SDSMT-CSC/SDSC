#include <stdio.h>

int buffer_begin = 0;
int buffer_end = 0;
char buffer[80];

void setup()
{
  Serial.begin(9600);
}

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
  return Serial.available()
}

int get_buffer_size()
{
  int size = buffer_end - buffer_begin;
  return (size >= 0 ? size : 80);
}

void loop()
{
  char message[80];
  if(input_ready())
  {
    int next_element = buffer_end + 1;
    char in_value = input();
    switch(in_value)
    {
      /* Newline flushes the buffer. */
      case '\n':
      case '\r':
        sprintf(message, "Flushing %d elements from buffer.\n", get_buffer_size());
        output(message);
        buffer_begin = buffer_end;
        break;
      /* ^A prints the buffer length */
      case 1:
        sprintf(message, "Buffer contains %d elements.", get_buffer_size());
        output(message);
        break;
      /* ^B prints the buffer contents. */
      case 2:
        for(in_value = buffer_begin; in_value != buffer_end; in_value = (in_value + 1) % 80)
        {
          output(buffer[in_value]);
        }
        output("");
        break;
      default:
        /* If the buffer is full, reply NACK. */
        if(next_element % 80 == buffer_begin % 80)
        {
          Serial.print(0);
        }
        /* Otherwise, add it to the buffer. */
        else
        {
          buffer[buffer_end] = in_value;
          buffer_end = next_element % 80;
        }
      /* End of default case */
    } /* End of switch statement */
  }   /* End of available serial check */
}     /* End of main */
