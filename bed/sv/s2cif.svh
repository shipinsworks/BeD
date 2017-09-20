`ifndef _S2CIF_SVH_
 `define _S2CIF_SVH_

 `include "macro.svh"

// Sim側マスタのインタフェース
interface s2cif();
   
   // 応答関数の登録要求
   task automatic func_setup( input uint32_t id, input uint32_t fn, output int ret );
      s2cif_pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      s2c_s_func_setup( pkt );
      ret = pkt.ret;
   endtask // s2c_s_func_setup

   // データ要求関数の呼び出し
   task automatic data_pull_call( input uint32_t id, input uint32_t fn, input uint32_t addr, input uint32_t size, output int ret, output uint32_t data[`S2CIF_DATA_SIZE] );
      s2cif_pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      pkt.addr = addr;
      pkt.size = size;
      s2c_func_call( pkt );
      data = pkt.data;
      ret = pkt.ret;
   endtask // data_req_call

   // モニタ関数の呼び出し
   task automatic data_push_call( input uint32_t id, input uint32_t fn, input uint32_t addr, input uint32_t size, output int ret, input uint32_t data[`S2CIF_DATA_SIZE] );
      s2cif_pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      pkt.addr = addr;
      pkt.size = size;
      pkt.data = data;
      s2c_func_call( pkt );
      ret = pkt.ret;
   endtask // data_push_call

   // 終了チェック
   task automatic check_end( output int ret );
      s2cif_pkt_s pkt;
      pkt.id = 0;
      pkt.fn = 2;
      s2c_check_end( pkt );
      ret = pkt.ret;
   endtask // check_end
   
endinterface // s2cif

`endif
