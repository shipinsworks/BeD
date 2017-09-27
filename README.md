Basic Verification Environment using DPI-C

ＤＰＩ－Ｃ利用の基本的な検証環境

## Description

Ｃ言語で制御する論理動作シミュレーション向けの軽い検証環境を、Ｘｉｌｉｎｘ社ＶｉｖａｄｏシミュレータのＷｅｂＰａｃｋで実現する。

## Features

* ＤＰＩーＣインタフェースの定型パケット化により、ＦａｔａｌやＩｎｔｅｒｎａｌの発生を低減している。
* Ｃ言語からのテスト情報投入も、論理要求によるテスト情報投入できる。
   * import/exportによる構造体データの両方向転送
   * コールバック関数を登録して論理側から呼び出しが可能
* ＣＵＩバッチ処理により論理検証を実行、波形表示のみ別途ＧＵＩ表示

## Requirement

Xilinx Vivado WebPack

## Usage

* help

    $ bsim -h

* 2 step

    $ bsim -p project/dff.prj
    
    $ bsim -t tb/dff_s2cif_top.sv pattern/bed_test/tc001

* all

    $ bsim -p project/dff.prj -t tb/dff_s2cif_top.sv pattern/bed_test/tc001

* modified testbench or scenario, testbench/scenario compile & sim run

    $ bsim -t tb/dff_s2cif_top.sv pattern/bed_test/tc001
 
* after sim run, modified scenario & sim run

    $ bsim pattern/bed_test/tc001

## Installation

    $ git clone https://github.com/shipinsworks/BeD.git BeD
    $ cd BeD
    $ export BED_INSDIR=$(pwd)
    $ export XV_PATH=/opt/Xilinx/Vivda/2017.2
    $ export PATH=${XV_PATH}/bin:${BED_INSDIR}/bed/bin:${PATH}

## Author

shipinsworks

## License

MIT
