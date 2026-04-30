## =============================================================================
## constraints.xdc - Basys-3 (xc7a35tcpg236-1)
## Generated from official Basys-3-Master.xdc
## Mapped to system_wrapper port names for Logic Analyzer project
## =============================================================================

## ---- Clock (100MHz onboard oscillator) ----
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## ---- Reset (Center Button BTNC) ----
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports reset]

## ---- UART (USB-RS232) ----
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports usb_uart_rxd]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports usb_uart_txd]

## ---- inputs[15:0] ----
## Block 0 (SPI): inputs[3:0] ? PMOD JA
##   inputs[0] = SCK  ? JA1
##   inputs[1] = MISO ? JA2
##   inputs[2] = MOSI ? JA3
##   inputs[3] = CS   ? JA4
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[0]}]
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[1]}]
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[2]}]
set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[3]}]

## Block 1 (disabled): inputs[7:4] ? PMOD JA (bottom row)
set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[4]}]
set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[5]}]
set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[6]}]
set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[7]}]

## Block 2 (disabled): inputs[11:8] ? PMOD JB (top row)
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[8]}]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[9]}]
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[10]}]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[11]}]

## Block 3 (I2C): inputs[15:12] ? PMOD JB (bottom row)
##   inputs[12] = SCL ? JB7
##   inputs[13] = SDA ? JB8
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[12]}]
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[13]}]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[14]}]
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {inputs_0[15]}]

## ---- block_configs_flat[7:0] ? SW[7:0] ----
## SW[1:0]=10 ? block0=SPI
## SW[3:2]=00 ? block1=disabled
## SW[5:4]=00 ? block2=disabled
## SW[7:6]=11 ? block3=I2C
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[3]}]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[4]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[5]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[6]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {block_configs_flat_0[7]}]

## ---- trig_configs_flat[7:0] ? SW[15:8] ----
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[0]}]
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[1]}]
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[2]}]
set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[3]}]
set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[4]}]
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[5]}]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[6]}]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {trig_configs_flat_0[7]}]



## ---- triggered ? LED[0] ----
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports triggered_0]

## ---- triggered_block_id[1:0] ? LED[2:1] ----
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {triggered_block_id_0[0]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {triggered_block_id_0[1]}]

## ---- triggered_address[7:0] ? LED[15:8] ----
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[0]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[1]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[2]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[3]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[4]}]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[5]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[6]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {triggered_address_0[7]}]

## ---- Configuration options ----
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## ---- Bypass DRC for unassigned m_axis_* ports (internal to block design) ----
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
