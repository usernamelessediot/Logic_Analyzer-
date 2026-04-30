// config.sv
// SystemVerilog Package containing global constants and definitions

package config_pkg;

    // Configuration constants for the Analyzer Block (ANALBLK)
    localparam ANALBLK_CONFIG_BITWIDTH = 2;
    localparam ANALBLK_CONFIG_DISABLED = 2'd0;
    localparam ANALBLK_CONFIG_GPIO     = 2'd1;
    localparam ANALBLK_CONFIG_SPI      = 2'd2;
    localparam ANALBLK_CONFIG_I2C      = 2'd3;

    // Configuration constants for the Trigger Unit (TRIG)
    localparam TRIG_CONFIG_BITWIDTH = 2;
    localparam TRIG_COND_BITWIDTH   = 24;

    // Protocol configuration constants
    localparam CONFIG_DISABLE = 2'b00;
    localparam CONFIG_GPIO    = 2'b01;
    localparam CONFIG_SPI     = 2'b10;
    localparam CONFIG_I2C     = 2'b11;

    // GPIO and timing
    localparam GPIO_NUM_INPUTS = 4;
    localparam TIMER_BITWIDTH  = 46;

    // Ring Buffer and Memory constants
    localparam RINGBUF_WORD_SIZE   = 64;
    localparam RINGBUF_NUM_ENTRIES = 256;
    localparam RINGBUF_ADDR_SIZE   = $clog2(RINGBUF_NUM_ENTRIES);

    localparam DPR_NUM_ENTRIES = 2000;
    localparam DPR_ADDR_SIZE = $clog2(DPR_NUM_ENTRIES);
    localparam DPR_WORD_SIZE = RINGBUF_WORD_SIZE;
    
    // Protocol state constants (I2C)
    localparam BUS_TIMEOUT_CYCLES = 100000;
    localparam S_BUS_IDLE     = 0;
    localparam S_DATA         = 1;
    localparam S_ACK_NACK     = 2;
    localparam S_REPSTRT_STOP = 3;

    localparam START            = 0;
    localparam REPEATED_START   = 1;

endpackage : config_pkg