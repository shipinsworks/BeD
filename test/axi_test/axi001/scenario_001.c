#include "stdio.h"
#include "scenario.h"

void scenario() {
  int ret;
  uint32_t addr;
  uint32_t data[C2SIF_DATA_SIZE];
  printf("scenario axi_001.");
  
  // データを投入
  addr = 0x00000100; // awaddr
  data[0] = 0x12345678; // wdata
  printf("write addr: 0x%08x data: 0x%08x",addr,data[0]);
  ret = write_packet( 1, 0, addr, 1, data );
  printf("ret: %d", ret);
  addr = 0x00000100; // araddr
  data[0] = 0x00000000; // rdata
  ret = read_packet( 1, 1, addr, 1, data );
  printf("read addr: 0x%08x data: 0x%08x",addr, data[0]);
}
