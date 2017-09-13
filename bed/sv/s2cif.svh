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

   // 応答関数の呼び出し
   task automatic func_call( input uint32_t id, input uint32_t fn, output int ret, output uint32_t data[`S2CIF_DATA_SIZE] );
      s2cif_pkt_s pkt;
      pkt.id = id;
      pkt.fn = fn;
      s2c_func_call( pkt );
      data = pkt.data;
      ret = pkt.ret;
   endtask // func_call

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
