#include "scenario.h"

#define DRV_C2SIF_FN_DATA_WRITE   0
#define DRV_C2SIF_FN_DATA_READ    1

int dff_data_in( uint32_t id,  int din )
{
  c2sif_pkt_s pkt;
  int ret;
  pkt.id = id;
  pkt.fn = DRV_C2SIF_FN_DATA_WRITE;
  pkt.addr = 0;
  pkt.size = 1;
  pkt.data[0] = din;
  c2s_write_packet( &pkt );
  return pkt.ret;
}

int dff_data_out( uint32_t id, int *dout )
{
  c2sif_pkt_s pkt;
  int ret;
  pkt.id = id;
  pkt.fn = DRV_C2SIF_FN_DATA_READ;
  pkt.addr = 0;
  pkt.size = 1;
  c2s_read_packet( &pkt );
  *dout = (int)( pkt.data[0] & 0x1 );
  return pkt.ret;
}
