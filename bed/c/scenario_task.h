#ifndef _SCENARIO_TASK_H_
#define _SCENARIO_TASK_H_

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "svdpi.h"

// Sim側との転送パケット
#define S2CIF_DATA_SIZE 16
typedef struct {
   uint32_t id;
   uint32_t fn;
   uint32_t ret;
   uint32_t data[S2CIF_DATA_SIZE];
} pkt_s;

extern void cs_printf( char *str );
extern void s2c_s_func_setup( pkt_s *pkt );
extern void s2c_func_call( pkt_s *pkt );
extern void sc_get_data( pkt_s *pkt );

#define BASENAME(p) ((strrchr((p), '/') ? : ((p) - 1)) + 1)

#define printf(...) msg_printf( __VA_ARGS__ )
void msg_sprintf( char *tmp, char *format, ... )
{
  va_list args;
  // char tmp[1024];
  char *p0;

  va_start( args, format );
  vsprintf( tmp, format, args );
  va_end( args );
  p0 = strrchr( tmp, '\n' );
  if(( p0 != NULL ) & (( p0 - tmp ) == ( strlen( tmp ) -1 ))) *p0 = '\0';
  // return tmp;
}

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
#define debug_printf(...) char tmp[1024], tmp2[1024];	\
  msg_sprintf( tmp, __VA_ARGS__ );\
  msg_sprintf( tmp2, "%s(%1d) %s", BASENAME( __FILE__ ), __LINE__, tmp ); \
  dbg_printf( tmp2 )
#else
#define debug_printf(...)
#endif

// Sim側マスタの要求関数の登録構造体
#define S2C_FUNC_SIZE 256
typedef struct {
  uint32_t id; // id!=0の時データが有効
  uint32_t fn;
  uint32_t s_enable;
  uint32_t c_enable;
  uint32_t (*func_ptr)( pkt_s *pkt );
} func_s;

static func_s s2c_func_table[S2C_FUNC_SIZE];
static uint32_t s2c_func_cnt = 0;
uint32_t null_func()
{
  debug_printf("null function called.");
  return 0;
}

// Sim側マスタの要求関数の登録（Sim側からの初期設定）
void s2c_s_func_setup( pkt_s *pkt )
{
  uint32_t ret = 0;
  int flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if( flag == 0 ) {
      if(( s2c_func_table[i].id == pkt->id ) &&
	 ( s2c_func_table[i].fn == pkt->fn ) &&
	 ( s2c_func_table[i].c_enable != 0 )) {
	s2c_func_table[i].s_enable = 1;
	debug_printf("s2c_func_table registration OK. C->S id:%d fn:%d",pkt->id, pkt->fn);
	flag = 1;
      }
    } else {
      if(( s2c_func_table[i].id == pkt->id ) &&
	 ( s2c_func_table[i].fn == pkt->fn ) &&
	 ( s2c_func_table[i].c_enable != 0 )) {
	printf("Error: Sim側マスタの要求関数のSim側からの多重登録");
	ret = 1;
	flag = 1;
      }
    }
  }
  if( flag == 0 ) {
    if( s2c_func_cnt < S2C_FUNC_SIZE ) {
      s2c_func_table[s2c_func_cnt].id = pkt->id;
      s2c_func_table[s2c_func_cnt].fn = pkt->fn;
      s2c_func_table[s2c_func_cnt].s_enable = 1;
      s2c_func_table[s2c_func_cnt].c_enable = 0;
      s2c_func_table[s2c_func_cnt].func_ptr = null_func;
      debug_printf("s2c_func_table registration OK. S id:%d fn:%d",pkt->id, pkt->fn);
      s2c_func_cnt++;
    } else {
      printf("Error: Sim側マスタの要求関数の登録数オーバーフロー");
      ret = 1;
    }
  }
  pkt->ret = ret;
}

// Sim側マスタの要求関数の登録（C側からの初期設定）
uint32_t s2c_c_func_setup( uint32_t id, uint32_t fn, uint32_t (*func_ptr)( pkt_s *pkt ) )
{
  uint32_t ret = 0;
  int flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if( flag == 0 ) {
      if(( s2c_func_table[i].id == id ) &&
	 ( s2c_func_table[i].fn == fn ) &&
	 ( s2c_func_table[i].s_enable != 0 )) {
	s2c_func_table[i].c_enable = 1;
	s2c_func_table[i].func_ptr = func_ptr;
	debug_printf("s2c_func_setup registration OK. S->C id:%d fn:%d", id, fn);
	flag = 1;
      }
    } else {
      if(( s2c_func_table[i].id == id ) &&
	 ( s2c_func_table[i].fn == fn ) &&
	 ( s2c_func_table[i].s_enable != 0 )) {
	printf("Error: Sim側マスタの要求関数のC側からの多重登録");
	ret = 1;
	flag = 1;
      }
    }
  }
  if( flag == 0 ) {
    if( s2c_func_cnt < S2C_FUNC_SIZE ) {
      s2c_func_table[s2c_func_cnt].id = id;
      s2c_func_table[s2c_func_cnt].fn = fn;
      s2c_func_table[s2c_func_cnt].s_enable = 0;
      s2c_func_table[s2c_func_cnt].c_enable = 1;
      s2c_func_table[s2c_func_cnt].func_ptr = func_ptr;
      debug_printf("s2c_func_setup registration OK. C id:%d fn:%d", id, fn);
      s2c_func_cnt++;
    } else {
      printf("Error: Sim側マスタの要求関数の登録数オーバーフロー");
      ret = 2;
    }
  }
  return ret;
}

// Sim側からのＣ言語要求受付関数の呼び出し
void s2c_func_call( pkt_s *pkt )
{
  uint32_t ret = 0;
  uint32_t flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if(( s2c_func_table[i].id == pkt->id ) &&
       ( s2c_func_table[i].fn == pkt->fn )) {
      if(( s2c_func_table[i].s_enable == 1 ) &&
	 ( s2c_func_table[i].c_enable == 1 )) {
	debug_printf("s2c_func_table[%d] id:%d fn:%d func called.", i, s2c_func_table[i].id, s2c_func_table[i].fn);
	ret = s2c_func_table[i].func_ptr( pkt );
	flag = 1;
      } else {
	printf("Error: Sim側マスタの要求関数の設定不具合有り。 S:%1d C:%1d",s2c_func_table[i].s_enable,s2c_func_table[i].c_enable);
	ret = 1000;
	flag = 1;
      }
    }
  }
  if( flag == 0 ) {
    printf("Error: Sim側マスタの要求関数が未登録。id:%d fn:%d", pkt->id, pkt->fn);
    ret = 1001;
  }
  pkt->ret = ret;
}

void sc_get_data( pkt_s *pkt )
{
  pkt->data[0] = 0x12345678;
  pkt->ret = 0;
}

#endif
