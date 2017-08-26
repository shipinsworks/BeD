Basic Verification Environment using DPI-C

ＤＰＩ－Ｃ利用の基本的な検証環境

## Description

Ｃ言語で制御する論理動作シミュレーション向けの軽い検証環境を、Ｘｉｌｉｎｘ社ＶｉｖａｄｏシミュレータのＷｅｂＰａｃｋで実現する。

## Features

* ＣＵＩバッチ処理による機能テストケースを実行できる。
* Ｃ言語の乱数を使用してＵＶＭ同様の制限付き乱数生成テストケースを実現できる。
* Ｃ言語からのテスト情報投入も、論理要求によるテスト情報投入できる。

## Requirement

Xilinx Vivado WebPack

## Usage

    $ bsim -h
    $ bsim -p dff.prj
    $ bsim -t tb/dff_top.sv
    $ bsim -p dff.prj -t tb/dff_top.sv testcase/bed/testcase/tc001
    $ bsim -p dff.prj -t tb/dff_top.sv
    $ bsim -t tb/dff_top.sv testcase/bed/testcase/tc001

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
