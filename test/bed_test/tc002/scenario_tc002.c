#include "stdio.h"
#include "scenario.h"

// シナリオ関数
void scenario()
{
  int ret;
  uint32_t data[C2SIF_DATA_SIZE];
  printf("Hello, scenario_tc002!\n");
  // データを投入
  data[0] = 0x01234567;
  printf("write data[0]: 0x%08x",data[0]);
  ret = write_packet( 1, 0, 0x00000001, 1, data );
  printf("ret: %d", ret);
  // 論理の反応を読む
  ret = read_packet( 1, 1, 0x00000001, 1, data );
  printf("ret: %d", ret);
  printf("read data[0]: 0x%08x",data[0]);
  // データを投入
  data[0] = 0xfedcba98;
  printf("write data[0]: 0x%08x",data[0]);
  ret = write_packet( 1, 0, 0x00000002, 1, data );
  printf("ret: %d", ret);
  // 論理の反応を読む
  ret = read_packet( 1, 1, 0x00000002, 1, data );
  printf("ret: %d", ret);
  printf("read data[0]: 0x%08x",data[0]);
  // 終了
}
