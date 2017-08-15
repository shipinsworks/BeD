#include "stdio.h"
#include "scenario.h"
uint32_t dff_get_data( pkt_s *pkt )
{
  pkt->data[0] = 0x12345678;
  return 0;
}

int scenario()
{
  unsigned int ret = 0;
  ret = s2c_c_func_setup( 1, 0, dff_get_data );
  printf("Hello, scenario_tc001!\n");
  return 0;
}
