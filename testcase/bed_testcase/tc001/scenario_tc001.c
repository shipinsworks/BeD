#include "stdio.h"
#include "scenario.h"

// データファイル
static FILE *fp0 = NULL;
static FILE *fp1 = NULL;
static char get_filepath[] = "testcase/bed_testcase/tc001/dff_data.txt";
static char put_filepath[] = "testcase/bed_testcase/tc001/sim/dff_dump.txt";

// デーや要求に対する応答関数
int dff_get_data( s2cif_pkt_s *pkt )
{
  uint32_t data;
  debug_printf("dff_get_data called.");
  int ret = 0;
  if( fp0 == NULL ) {
    if(( fp0 = fopen(get_filepath,"r")) == NULL ) {
      printf("Error: Cannot open file(%s).",get_filepath);
      ret = -2;
    } else {
      debug_printf("Info: open file(%s) ok.",get_filepath);
    }
  }
  if( ret == 0 ) {
    if((ret = fscanf( fp0, "%8x", pkt->data )) != EOF) {
      debug_printf("get data:%08x",pkt->data[0]);
      ret = 0;
    }
  }
  return ret;
}

// データモニタ関数
int dff_put_data( s2cif_pkt_s *pkt )
{
  int ret = 0;
  debug_printf("dff_put_data called.");
  if( fp1 == NULL ) {
    if(( fp1 = fopen(put_filepath,"w")) == NULL ) {
      printf("Error: Cannot open file(%s).",put_filepath);
      ret = -2;
    } else {
      debug_printf("Info: open file(%s) ok.",put_filepath);
    }
  }
  if( ret == 0 ) {
    fprintf(fp1,"data[0]:%08x\n",pkt->data[0]);
  }
  pkt->ret = ret;
  return ret;
}

// シナリオ関数
void scenario()
{
  int ret = 0;
  ret = func_setup( 1, 0, 0, dff_get_data );
  ret = func_setup( 1, 1, 1, dff_put_data );
  printf("Hello, scenario_tc001!\n");
  // リターンすると通常はシミュレーション停止
  // 応答関数がEODを検出するまで待つ仕掛けをテストベンチに記述してある。
}
