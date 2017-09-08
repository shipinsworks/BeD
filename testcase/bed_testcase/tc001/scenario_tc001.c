#include "stdio.h"
#include "scenario.h"
static FILE *fp = NULL;
static char filepath[] = "testcase/bed_testcase/tc001/dff_data.txt";

int dff_get_data( s2cif_pkt_s *pkt )
{
  uint32_t data;
  debug_printf("dff_get_data called.");
  int ret = 0;
  if( fp == NULL ) {
    if(( fp = fopen(filepath,"r")) == NULL ) {
      printf("Error: Cannot open file(%s).",filepath);
      ret = -2;
    } else {
      debug_printf("Info: open file(%s) ok.",filepath);
    }
  }
  if( ret == 0 ) {
    if((ret = fscanf( fp, "%8x", pkt->data )) != EOF) {
      debug_printf("get data:%08x",pkt->data[0]);
      ret = 0;
    }
  }
  return ret;
}

void scenario()
{
  unsigned int ret = 0;
  ret = s2c_c_func_setup( 1, 0, 0, dff_get_data );
  printf("Hello, scenario_tc001!\n");
}
