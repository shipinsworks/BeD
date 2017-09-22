#include "stdio.h"
#include "scenario.h"

static unsigned int memory[256];

int axi4_lite_slave_write( s2cif_pkt_s *pkt )
{
  debug_printf("axi4_lite_slave_write called.");
  printf("pkt.addr: 0x%08x data:0x%08x",pkt->addr,pkt->data[0]);
  memory[pkt->addr] = pkt->data[0];
  return 0;
}

int axi4_lite_slave_read( s2cif_pkt_s *pkt )
{
  debug_printf("axi4_lite_slave_read called.");
  printf("pkt.addr: 0x%08x",pkt->addr);
  pkt->data[0] = memory[pkt->addr];
  return 0;
}

void scenario() {
  uint32_t addr;
  uint32_t data[C2SIF_DATA_SIZE];
  int ret = 0;
  ret = func_setup( 2, 1, 0, axi4_lite_slave_write );
  ret = func_setup( 2, 0, 1, axi4_lite_slave_read );
  printf("scenario axi_003.");

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
