`timescale 1ns/1ns
`include "config.sv"

module testbench();

    // ------------------------------
    // Clocks, reset, signals
    // ------------------------------
    logic clk_100, reset;
    logic [31:0] index;

    // Block 0 ? I2C  ? inputs[3:0]  (scl=0, sda=1)
    logic sda, scl;

    // Block 1 ? SPI  ? inputs[7:4]  (sck=4, miso=5, mosi=6, cs=7)
    logic miso, mosi, sck, cs;

    // Block 2 ? GPIO ? inputs[11:8]
    logic gpio_toggle;

    // Block 3 ? GPIO ? inputs[15:12]
    logic gpio2_toggle;

    // Full 16-bit input to clump
    // [3:0]   = Block0 I2C  : {unused, unused, sda, scl}
    // [7:4]   = Block1 SPI  : {cs, mosi, miso, sck}
    // [11:8]  = Block2 GPIO : {gpio_toggle, gpio_toggle, gpio_toggle, gpio_toggle}
    // [15:12] = Block3 GPIO : {gpio2_toggle ...}
    logic [15:0] inputs;
    assign inputs = {
        gpio2_toggle, gpio2_toggle, gpio2_toggle, gpio2_toggle,  // [15:12] Block3 GPIO
        gpio_toggle,  gpio_toggle,  gpio_toggle,  gpio_toggle,   // [11:8]  Block2 GPIO
        cs,           mosi,         miso,         sck,           // [7:4]   Block1 SPI
        1'b0,         1'b0,         sda,          scl            // [3:0]   Block0 I2C
    };

    // ------------------------------
    // Clump configuration
    // ------------------------------
    import config_pkg::*;

    logic [ANALBLK_CONFIG_BITWIDTH-1:0] block_configs [0:3];
    logic [TRIG_CONFIG_BITWIDTH-1:0]    trig_configs  [0:3];
    logic [TRIG_COND_BITWIDTH-1:0]      trig_conds;

    // ------------------------------
    // Clump output signals
    // ------------------------------
    logic [DPR_ADDR_SIZE-1:0]  mb_read_addr;
    logic [DPR_ADDR_SIZE-1:0]  mb_next_addr;
    logic                      mb_can_read;
    logic [DPR_WORD_SIZE-1:0]  data_out;
    logic                      data_out_val;
    logic [DPR_ADDR_SIZE-1:0]  data_write_addr;

    logic                      triggered;
    logic [1:0]                triggered_block_id;
    logic [DPR_ADDR_SIZE-1:0]  triggered_address;

    // ------------------------------
    // Loop variables
    // ------------------------------
    integer i, j;

    // ------------------------------
    // DUT: analyzer_clump
    // ------------------------------
    analyzer_clump dut (
        .clk                (clk_100),
        .reset              (reset),
        .inputs             (inputs),

        .mb_read_addr       (mb_read_addr),
        .mb_next_addr       (mb_next_addr),
        .mb_can_read        (mb_can_read),
        .data_out           (data_out),
        .data_out_val       (data_out_val),
        .data_write_addr    (data_write_addr),

        .block_configs      (block_configs),
        .trig_configs       (trig_configs),
        .trig_conds         (trig_conds),

        .triggered          (triggered),
        .triggered_block_id (triggered_block_id),
        .triggered_address  (triggered_address)
    );

    // ------------------------------
    // Clock generation
    // ------------------------------
    initial clk_100 = 1'b0;
    always #5 clk_100 = ~clk_100; // 100 MHz

    // SPI clock only toggles when CS is low
    always begin
        #10;
        if (cs == 1'b0) sck = ~sck;
    end

    // GPIO toggles for Block 2 & 3
    initial gpio_toggle  = 1'b0;
    initial gpio2_toggle = 1'b0;
    always #37  gpio_toggle  = ~gpio_toggle;  // different frequencies
    always #53  gpio2_toggle = ~gpio2_toggle; // to stress round robin

    // Increment index
    always @(posedge clk_100) index <= index + 1;

    // ------------------------------
    // MicroBlaze read simulation
    // Advances read pointer whenever data is available
    // ------------------------------
    always @(posedge clk_100) begin
        if (reset) begin
            mb_read_addr <= 0;
        end else if (mb_can_read) begin
            mb_read_addr <= mb_next_addr; // consume data
        end
    end

    // ------------------------------
    // Monitor: print whenever data is written
    // ------------------------------
    always @(posedge clk_100) begin
        if (data_out_val) begin
            $display("[%0t] DATA OUT ? addr=%0d data=%0h block_id=%0b",
                $time, data_write_addr, data_out, data_out[63:62]);
        end
    end

    // Monitor trigger
    always @(posedge triggered) begin
        $display("[%0t] *** TRIGGERED *** block=%0d at addr=%0d",
            $time, triggered_block_id, triggered_address);
    end

    // ------------------------------
    // Main test sequence
    // ------------------------------
    initial begin
        // --- Init signals ---
        reset        = 1'b0;
        sda = 1; scl = 1;
        cs = 1; miso = 0; mosi = 0; sck = 0;
        mb_read_addr = 0;
        index        = 0;

        // Block 0 = I2C, Block 1 = SPI, Block 2 = GPIO, Block 3 = GPIO
        block_configs[0] = ANALBLK_CONFIG_I2C;
        block_configs[1] = ANALBLK_CONFIG_SPI;
        block_configs[2] = ANALBLK_CONFIG_GPIO;
        block_configs[3] = ANALBLK_CONFIG_GPIO;

        // Trigger on GPIO rising edge for Block 2
        trig_configs[0]  = CONFIG_DISABLE;
        trig_configs[1]  = CONFIG_DISABLE;
        trig_configs[2]  = CONFIG_GPIO;
        trig_configs[3]  = CONFIG_DISABLE;

        // Trigger condition: any rising edge on GPIO block (mask = 8'hFF)
        trig_conds = {8'hFF, 8'hFF, 8'h00};

        // --- Reset pulse ---
        #10 reset = 1'b1;
        #100 reset = 1'b0;
        #10;

        $display("=== Starting Clump Testbench ===");

        // ==============================
        // TEST 1: I2C Transaction (Block 0)
        // ==============================
        $display("\n--- TEST 1: I2C on Block 0 ---");

        // START condition: SDA falls while SCL high
        sda = 0; #10;
        scl = 0; #10;

        // Send 8 bits (all 1s = 0xFF)
        for (i = 0; i < 8; i = i + 1) begin
            scl = 0; #10;
            sda = 1;
            scl = 1; #10;
        end

        // ACK
        scl = 0; sda = 0; #10;
        scl = 1; #10;

        // STOP condition: SDA rises while SCL high
        scl = 1; #10;
        sda = 0; #10;
        sda = 1;
        #50;

        // ==============================
        // TEST 2: SPI Transaction (Block 1)
        // ==============================
        $display("\n--- TEST 2: SPI on Block 1 ---");

        cs = 0;
        // Send 8 bits on MOSI (alternating), MISO = 0
        for (i = 0; i < 8; i = i + 1) begin
            #10 mosi = ~mosi;
        end
        // Send 8 bits on MISO (alternating), MOSI = 0
        for (i = 0; i < 8; i = i + 1) begin
            #10 miso = ~miso; mosi = 0;
        end
        cs = 1;
        #50;

        // Second SPI transaction
        cs = 0;
        for (i = 0; i < 8; i = i + 1) begin
            #10 mosi = ~mosi;
        end
        for (i = 0; i < 8; i = i + 1) begin
            #10 mosi = 0; miso = ~miso;
        end
        cs = 1;
        #50;

        // ==============================
        // TEST 3: GPIO (Blocks 2 & 3 already toggling via always blocks)
        // Just wait and let the round robin handle both
        // ==============================
        $display("\n--- TEST 3: GPIO on Blocks 2 & 3 (running concurrently) ---");
        #500;

        // ==============================
        // TEST 4: All blocks simultaneously
        // Run another I2C + SPI while GPIO keeps toggling
        // ==============================
        $display("\n--- TEST 4: All blocks simultaneously ---");

        // I2C again
        sda = 0; #10;
        scl = 0; #10;
        for (i = 0; i < 8; i = i + 1) begin
            scl = 0; #10;
            sda = ~sda;
            scl = 1; #10;
        end
        scl = 0; sda = 0; #10;
        scl = 1; #10;
        scl = 1; sda = 0; #10;
        sda = 1;

        // SPI simultaneously
        cs = 0;
        for (i = 0; i < 8; i = i + 1) begin
            #10 mosi = ~mosi;
        end
        for (i = 0; i < 8; i = i + 1) begin
            #10 mosi = 0; miso = ~miso;
        end
        cs = 1;

        // Let everything settle and round robin work
        #1000;

        $display("\n=== Testbench Complete ===");
        $display("Total data_write_addr = %0d", data_write_addr);
        $display("Triggered = %0b, Block = %0d", triggered, triggered_block_id);
        $finish;
    end

endmodule