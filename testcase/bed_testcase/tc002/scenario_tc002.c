#include "stdio.h"
#include "scenario.h"

void scenario()
{
  int ret;
  uint32_t data[C2SIF_DATA_SIZE];
  printf("Hello, scenario_tc002!\n");
  data[0] = 0x01234567;
  printf("data[0]: 0x%08x",data[0]);
  write_packet( 1, 0, 0x00000001, 1, &ret, data );
  printf("ret: %d", ret);
  data[0] = 0xfedcba98;
  printf("data[0]: 0x%08x",data[0]);
  write_packet( 1, 0, 0x00000002, 1, &ret, data );
  printf("ret: %d", ret);
}
