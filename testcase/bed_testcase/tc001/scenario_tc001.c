#include "stdio.h"
#include "scenario.h"
FILE *fp = NULL;
char filepath[] = "dff_data.txt";

uint32_t dff_get_data( pkt_s *pkt )
{
  int ret = 0;
  if( fp == NULL ) {
    if(( fp = fopen(filepath,"r")) == NULL ) {
      printf("Error: Cannot open file(%s).",filepath);
      ret = 2;
    }
  }
  if( ret == 0 ) {
    ret = fscanf( fp, "%d", pkt->data[0] );
  }
  //  pkt->data[0] = 0x12345678;
  return ret;
}

int scenario()
{
  unsigned int ret = 0;
  ret = s2c_c_func_setup( 1, 0, dff_get_data );
  printf("Hello, scenario_tc001!\n");
  return 0;
}
