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

typedef int unsigned uint32;

// Sim側との転送パケット
#define S2CIF_DATA_SIZE 16
typedef struct {
   uint32 id;
   uint32 fn;
   uint32 ret;
   uint32 data[S2CIF_DATA_SIZE];
} pkt_s;

// Sim側からの要求受付関数
void sc_get_data( pkt_s *pkt )
{
  debug_printf("pkt.id:%08x",pkt->id);
  pkt->data[0] = 0x12345678;
  pkt->ret = 0;
}

#endif
