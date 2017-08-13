#ifndef _SCENARIO_TASK_H_
#define _SCENARIO_TASK_H_

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "svdpi.h"

extern void cs_printf( char *str );

#define printf(...) msg_printf( __VA_ARGS__ )

void msg_printf( char *format, ... )
{
  va_list args;
  char tmp[1024];
  char *p0;

  va_start( args, format );
  vsprintf( tmp, format, args );
  va_end( args );
  p0 = strrchr( tmp, '\n' );
  if(( p0 != NULL ) & (( p0 - tmp ) == ( strlen( tmp ) -1 ))) *p0 = '\0';
  cs_printf( tmp );
}

#ifdef DEBUG
#define debug_printf(...) msg_printf( __VA_ARGS__ )
#else
#define debug_printf(...)
#endif

void sc_get_data( const unsigned int id, const unsigned int fn, unsigned int *ret, unsigned int data[16])
{
  data[0] = 0x12345678;
  *ret = 0;
}

#endif
