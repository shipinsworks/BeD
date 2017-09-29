#include "stdio.h"
#include "scenario.h"
#include "drv_c2sif.h"
#define  DFF_ID 1

// シナリオ関数
void scenario()
{
  int ret;
  int dout;
  printf("Hello, scenario_tc002!\n");
  // データを投入
  printf("write din: 0");
  ret = dff_data_in( DFF_ID, 0 );
  printf("ret: %d", ret);
  // 論理の反応を読む
  ret = dff_data_out( DFF_ID, &dout );
  printf("ret: %d", ret);
  printf("read dout: 0x%08x",dout);
  // データを投入
  printf("write din: 1");
  ret = dff_data_in( DFF_ID, 1 );
  printf("ret: %d", ret);
  // 論理の反応を読む
  ret = dff_data_out( DFF_ID, &dout );
  printf("ret: %d", ret);
  printf("read dout: %d",dout);
  // 終了
}
