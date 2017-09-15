#include "stdio.h"
#include "scenario.h"

void scenario() {
  int ret;
  uint32_t data[C2SIF_DATA_SIZE];
  printf("scenario axi_001.");
  
  // データを投入
  data[0] = 0x00000100; // awaddr
  data[1] = 0x12345678; // wdata
  printf("write data[0]: 0x%08x data[1]: 0x%08x",data[0],data[1]);
  ret = write_packet( 1, 0, 0x00000001, 2, data );
  printf("ret: %d", ret);
  data[0] = 0x00000100; // araddr
  data[1] = 0x00000000; // rdata
  ret = read_packet( 1, 1, 0x00000001, 2, data );
}
