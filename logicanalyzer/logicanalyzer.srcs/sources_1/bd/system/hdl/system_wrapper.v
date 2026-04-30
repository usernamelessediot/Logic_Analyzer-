//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
//Date        : Sat Mar 28 01:04:44 2026
//Host        : DESKTOP-98T9PFJ running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (block_configs_flat_0,
    clk,
    inputs_0,
    reset,
    trig_configs_flat_0,
    triggered_0,
    triggered_address_0,
    triggered_block_id_0,
    usb_uart_rxd,
    usb_uart_txd);
  input [7:0]block_configs_flat_0;
  input clk;
  input [15:0]inputs_0;
  input reset;
  input [7:0]trig_configs_flat_0;
  output triggered_0;
  output [7:0]triggered_address_0;
  output [1:0]triggered_block_id_0;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [7:0]block_configs_flat_0;
  wire clk;
  wire [15:0]inputs_0;
  wire reset;
  wire [7:0]trig_configs_flat_0;
  wire triggered_0;
  wire [7:0]triggered_address_0;
  wire [1:0]triggered_block_id_0;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  system system_i
       (.block_configs_flat_0(block_configs_flat_0),
        .clk(clk),
        .inputs_0(inputs_0),
        .reset(reset),
        .trig_configs_flat_0(trig_configs_flat_0),
        .triggered_0(triggered_0),
        .triggered_address_0(triggered_address_0),
        .triggered_block_id_0(triggered_block_id_0),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
