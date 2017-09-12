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
  int ret;
  uint32_t data[S2CIF_DATA_SIZE];
} s2cif_pkt_s;

#define C2SIF_DATA_SIZE 16
typedef struct {
  uint32_t id;
  uint32_t fn;
  int ret;
  uint32_t addr;
  uint32_t size;
  uint32_t data[C2SIF_DATA_SIZE];
} c2sif_pkt_s;
    
extern void c2s_printf( char *str );
extern void c2s_debug_printf( char *str );
extern void c2s_error_printf( char *str );
extern void c2s_write_packet( c2sif_pkt_s *pkt );
extern void c2s_read_packet( c2sif_pkt_s *pkt );

#define BASENAME(p) ((strrchr((p), '/') ? : ((p) - 1)) + 1)

#define printf(...) msg_printf( __VA_ARGS__ )
void msg_sprintf( char *str, char *format, ... )
{
  va_list args;
  char tmp[1024];
  char *p0;

  va_start( args, format );
  vsprintf( tmp, format, args );
  va_end( args );
  p0 = strrchr( tmp, '\n' );
  if(( p0 != NULL ) & (( p0 - tmp ) == ( strlen( tmp ) -1 ))) *p0 = '\0';
  strcpy( str, tmp );
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
  c2s_printf( tmp );
}

#ifdef DEBUG
#define debug_printf(...) {\
  char tmp[1024];\
  msg_sprintf( tmp, __VA_ARGS__ );\
  msg_sprintf( tmp, "%s(%1d) %s", BASENAME( __FILE__ ), __LINE__, tmp ); \
  c2s_debug_printf( tmp );\
}
#else
#define debug_printf(...)
#endif

#define error_printf(...) {\
    char tmp[1024];				\
    msg_sprintf( tmp, __VA_ARGS__ );					\
    msg_sprintf( tmp, "%s(%1d) %s", BASENAME( __FILE__ ), __LINE__, tmp ); \
    c2s_error_printf( tmp );							\
}

// Sim側マスタの要求関数の登録構造体
#define S2C_FUNC_SIZE 256
typedef struct {
  uint32_t id; // id!=0の時データが有効
  uint32_t fn; // function no.
  uint32_t s_enable; // logic side setup 1:OK
  uint32_t c_enable; // scenario side setup 1:OK
  uint32_t end_flag; // 0: not end, 1: end
  int (*func_ptr)( s2cif_pkt_s *pkt ); // function pointer
} func_s;

static func_s s2c_func_table[S2C_FUNC_SIZE];
static uint32_t s2c_func_cnt = 0;
uint32_t null_func()
{
  debug_printf("null function called.");
  return 0;
}

// Sim側マスタの要求関数の登録（Sim側からの初期設定）
void s2c_s_func_setup( s2cif_pkt_s *pkt )
{
  int ret = 0;
  int flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if( flag == 0 ) {
      if(( s2c_func_table[i].id == pkt->id ) &&
	 ( s2c_func_table[i].fn == pkt->fn ) &&
	 ( s2c_func_table[i].c_enable != 0 )) {
	s2c_func_table[i].s_enable = 1;
	s2c_func_table[i].end_flag = 0; // 初期化、Sim側からは設定しない
	debug_printf("s2c_func_table registration OK. C->S id:%d fn:%d",pkt->id, pkt->fn);
	flag = 1;
      }
    } else {
      if(( s2c_func_table[i].id == pkt->id ) &&
	 ( s2c_func_table[i].fn == pkt->fn ) &&
	 ( s2c_func_table[i].c_enable != 0 )) {
	error_printf("Error: Sim側マスタの要求関数のSim側からの多重登録");
	ret = 1002;
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
      s2c_func_table[s2c_func_cnt].end_flag = 0;
      s2c_func_table[s2c_func_cnt].func_ptr = null_func;
      debug_printf("s2c_func_table registration OK. S id:%d fn:%d",pkt->id, pkt->fn);
      s2c_func_cnt++;
    } else {
      error_printf("Error: Sim側マスタの要求関数の登録数オーバーフロー");
      ret = 1003;
    }
  }
  pkt->ret = ret;
}

// Sim側マスタの要求関数の登録（C側からの初期設定）
// 投入データのすべてを転送したい場合、end_flagは0を設定して終了を待たせる
int s2c_c_func_setup( uint32_t id, uint32_t fn, uint32_t end_flag, int (*func_ptr)( s2cif_pkt_s *pkt ) )
{
  int ret = 0;
  int flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if( flag == 0 ) {
      if(( s2c_func_table[i].id == id ) &&
	 ( s2c_func_table[i].fn == fn ) &&
	 ( s2c_func_table[i].s_enable != 0 )) {
	s2c_func_table[i].c_enable = 1;
	s2c_func_table[i].end_flag = end_flag;
	s2c_func_table[i].func_ptr = func_ptr;
	debug_printf("s2c_func_setup registration OK. S->C id:%d fn:%d", id, fn);
	flag = 1;
      }
    } else {
      if(( s2c_func_table[i].id == id ) &&
	 ( s2c_func_table[i].fn == fn ) &&
	 ( s2c_func_table[i].s_enable != 0 )) {
	error_printf("Error: Sim側マスタの要求関数のC側からの多重登録");
	ret = 1005;
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
      s2c_func_table[s2c_func_cnt].end_flag = end_flag;
      s2c_func_table[s2c_func_cnt].func_ptr = func_ptr;
      debug_printf("s2c_func_setup registration OK. C id:%d fn:%d", id, fn);
      s2c_func_cnt++;
    } else {
      error_printf("Error: Sim側マスタの要求関数の登録数オーバーフロー");
      ret = 1006;
    }
  }
  return ret;
}

// Sim側からのＣ言語要求受付関数の呼び出し
void s2c_func_call( s2cif_pkt_s *pkt )
{
  int ret = 0;
  uint32_t flag = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    if(( s2c_func_table[i].id == pkt->id ) &&
       ( s2c_func_table[i].fn == pkt->fn )) {
      if(( s2c_func_table[i].s_enable == 1 ) &&
	 ( s2c_func_table[i].c_enable == 1 )) {
	ret = s2c_func_table[i].func_ptr( pkt );
	// ret: 0 正常終了,　<0: EOD/NotOpen, >0: 異常終了 
	debug_printf("s2c_func_table[%d] id:%d fn:%d func called. ret:%d", i, s2c_func_table[i].id, s2c_func_table[i].fn, ret);
	if( s2c_func_table[i].end_flag == 0 ) { 
	  if( ret == 0 ) {
	    s2c_func_table[i].end_flag = 0;
	  } else { // ret != 0ならば終了可能にする（End of Data　あるいはエラー発生 ）
	    s2c_func_table[i].end_flag = 1;
	  }
	}
	flag = 1;
      } else {
	error_printf("Error: Sim側マスタの要求関数の設定不具合有り。 S:%1d C:%1d",s2c_func_table[i].s_enable,s2c_func_table[i].c_enable);
	ret = 1000;
	flag = 1;
      }
    }
  }
  if( flag == 0 ) {
    error_printf("Error: Sim側マスタの要求関数が未登録。id:%d fn:%d", pkt->id, pkt->fn);
    ret = 1001;
  }
  pkt->ret = ret;
}

void s2c_check_end( s2cif_pkt_s *pkt )
{
  int ret = 0;
  for( int i = 0; i < s2c_func_cnt; i++ ) {
    ret += s2c_func_table[i].end_flag;
  }
  if( ret < s2c_func_cnt ) { // すべての登録関数が終了可能ならば
    pkt->ret = 0; // 終了可能
  } else {
    pkt->ret = 1; // 終了不可
  }
}

int write_packet( uint32_t id, uint32_t fn, uint32_t addr, uint32_t size, uint32_t data[C2SIF_DATA_SIZE] )
{
  c2sif_pkt_s pkt;
  int ret;
  pkt.id = id;
  pkt.fn = fn;
  pkt.addr = addr;
  pkt.size = size;
  if( size > C2SIF_DATA_SIZE ) {
    ret = 1008; // size over
  } else {
    for( int i=0; i<size; i++ ) {
      pkt.data[i] = data[i];
    }
    c2s_write_packet( &pkt );
    ret = pkt.ret;
  }
  return ret;
}

int read_packet( uint32_t id, uint32_t fn, uint32_t addr, uint32_t size, uint32_t data[C2SIF_DATA_SIZE] )
{
  c2sif_pkt_s pkt;
  int ret;
  pkt.id = id;
  pkt.fn = fn;
  pkt.addr = addr;
  pkt.size = size;
  if( size > C2SIF_DATA_SIZE ) {
    ret = 1009; // size over
  } else {
    c2s_read_packet( &pkt );
    for( int i=0; i<size; i++ ) {
      data[i] = pkt.data[i];
    }
    ret = pkt.ret;
  }
  return ret;
}

#endif
