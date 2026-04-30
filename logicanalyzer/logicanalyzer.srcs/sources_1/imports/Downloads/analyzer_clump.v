// =============================================================================
// analyzer_clump.v  (plain Verilog — compatible with Vivado block design)
// Contains: 4 analyzer blocks, round-robin arbiter, internal ring buffer,
// AXI4-Stream 32-bit master output to MicroBlaze FIFO.
// =============================================================================

module analyzer_clump #(
    parameter DATA_WIDTH      = 64,
    parameter ADDR_WIDTH      = 8,
    parameter NUM_ENTRIES     = 256,
    parameter TRIG_COND_WIDTH = 24,
    parameter TIMER_WIDTH     = 46,
    parameter NUM_INPUTS      = 4
)(
    input  wire                       aclk,
    input  wire                       aresetn,

    input  wire [15:0]                inputs,

    // Flat config buses (2 bits per block)
    input  wire [7:0]                 block_configs_flat,
    input  wire [7:0]                 trig_configs_flat,
    input  wire [TRIG_COND_WIDTH-1:0] trig_conds,

    // Trigger status
    output reg                        triggered,
    output reg  [1:0]                 triggered_block_id,
    output reg  [ADDR_WIDTH-1:0]      triggered_address,

    // AXI4-Stream Master (32-bit)
    output reg  [31:0]                m_axis_tdata,
    output reg                        m_axis_tvalid,
    output reg                        m_axis_tlast,
    output wire [3:0]                 m_axis_tkeep,
    input  wire                       m_axis_tready
);

    assign m_axis_tkeep = 4'hF;

    wire reset;
    assign reset = ~aresetn;

    // -------------------------------------------------------------------------
    // Unpack flat config buses — use plain wires instead of unpacked arrays
    // -------------------------------------------------------------------------
    wire [1:0] block_cfg0, block_cfg1, block_cfg2, block_cfg3;
    wire [1:0] trig_cfg0,  trig_cfg1,  trig_cfg2,  trig_cfg3;

    assign block_cfg0 = block_configs_flat[1:0];
    assign block_cfg1 = block_configs_flat[3:2];
    assign block_cfg2 = block_configs_flat[5:4];
    assign block_cfg3 = block_configs_flat[7:6];

    assign trig_cfg0  = trig_configs_flat[1:0];
    assign trig_cfg1  = trig_configs_flat[3:2];
    assign trig_cfg2  = trig_configs_flat[5:4];
    assign trig_cfg3  = trig_configs_flat[7:6];

    // -------------------------------------------------------------------------
    // Per-block signals — flat wires instead of unpacked arrays
    // -------------------------------------------------------------------------
    wire [DATA_WIDTH-1:0] block_data0, block_data1, block_data2, block_data3;
    wire [ADDR_WIDTH-1:0] block_next0, block_next1, block_next2, block_next3;
    reg  [ADDR_WIDTH-1:0] block_addr0, block_addr1, block_addr2, block_addr3;
    wire                  block_can0,  block_can1,  block_can2,  block_can3;
    wire [3:0]            trig_outs;

    // -------------------------------------------------------------------------
    // Round-Robin Arbiter
    // -------------------------------------------------------------------------
    wire [3:0] arb_reqs;
    assign arb_reqs = {block_can3, block_can2, block_can1, block_can0};

    reg [3:0] priority_mask;
    reg [3:0] arb_grants;

    always @(*) begin
        arb_grants = 4'h0;
        if      (arb_reqs[0] & priority_mask[0]) arb_grants = 4'b0001;
        else if (arb_reqs[1] & priority_mask[1]) arb_grants = 4'b0010;
        else if (arb_reqs[2] & priority_mask[2]) arb_grants = 4'b0100;
        else if (arb_reqs[3] & priority_mask[3]) arb_grants = 4'b1000;
        else if (arb_reqs[0])                    arb_grants = 4'b0001;
        else if (arb_reqs[1])                    arb_grants = 4'b0010;
        else if (arb_reqs[2])                    arb_grants = 4'b0100;
        else if (arb_reqs[3])                    arb_grants = 4'b1000;
    end

    always @(posedge aclk) begin
        if (reset) begin
            priority_mask <= 4'hF;
        end else if (|arb_grants) begin
            case (arb_grants)
                4'b0001: priority_mask <= 4'b1110;
                4'b0010: priority_mask <= 4'b1100;
                4'b0100: priority_mask <= 4'b1000;
                4'b1000: priority_mask <= 4'b1111;
                default:  priority_mask <= 4'b1111;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // 4 Analyzer Blocks
    // -------------------------------------------------------------------------
    analyzer_block ablock0 (
        .clk(aclk), .reset(reset),
        .inputs(inputs[3:0]),
        .configuration(block_cfg0), .trig_config(trig_cfg0),
        .trig_cond(trig_conds), .trig_out(trig_outs[0]),
        .sampler_id(2'd0),
        .data_read_data(block_data0), .data_read_addr(block_addr0),
        .data_read_next_addr(block_next0), .data_can_read(block_can0)
    );

    analyzer_block ablock1 (
        .clk(aclk), .reset(reset),
        .inputs(inputs[7:4]),
        .configuration(block_cfg1), .trig_config(trig_cfg1),
        .trig_cond(trig_conds), .trig_out(trig_outs[1]),
        .sampler_id(2'd1),
        .data_read_data(block_data1), .data_read_addr(block_addr1),
        .data_read_next_addr(block_next1), .data_can_read(block_can1)
    );

    analyzer_block ablock2 (
        .clk(aclk), .reset(reset),
        .inputs(inputs[11:8]),
        .configuration(block_cfg2), .trig_config(trig_cfg2),
        .trig_cond(trig_conds), .trig_out(trig_outs[2]),
        .sampler_id(2'd2),
        .data_read_data(block_data2), .data_read_addr(block_addr2),
        .data_read_next_addr(block_next2), .data_can_read(block_can2)
    );

    analyzer_block ablock3 (
        .clk(aclk), .reset(reset),
        .inputs(inputs[15:12]),
        .configuration(block_cfg3), .trig_config(trig_cfg3),
        .trig_cond(trig_conds), .trig_out(trig_outs[3]),
        .sampler_id(2'd3),
        .data_read_data(block_data3), .data_read_addr(block_addr3),
        .data_read_next_addr(block_next3), .data_can_read(block_can3)
    );

    // -------------------------------------------------------------------------
    // Shared internal ring buffer RAM
    // -------------------------------------------------------------------------
    reg  [ADDR_WIDTH-1:0]  shared_wr_addr;
    reg  [ADDR_WIDTH-1:0]  shared_rd_addr;
    wire [ADDR_WIDTH-1:0]  shared_wr_next;
    wire [ADDR_WIDTH-1:0]  shared_rd_next;
    wire                   shared_can_write;
    wire                   shared_can_read;

    assign shared_wr_next  = (shared_wr_addr == NUM_ENTRIES-1) ? 0 : shared_wr_addr + 1;
    assign shared_rd_next  = (shared_rd_addr == NUM_ENTRIES-1) ? 0 : shared_rd_addr + 1;
    assign shared_can_write = (shared_wr_next != shared_rd_addr);
    assign shared_can_read  = (shared_rd_next != shared_wr_addr);

    reg [DATA_WIDTH-1:0] shared_ram [0:NUM_ENTRIES-1];
    reg [DATA_WIDTH-1:0] ram_rd_data;
    reg                  ram_we;
    reg [DATA_WIDTH-1:0] ram_wr_data;

    always @(posedge aclk) begin
        if (ram_we)
            shared_ram[shared_wr_addr] <= ram_wr_data;
        ram_rd_data <= shared_ram[shared_rd_addr];
    end

    // -------------------------------------------------------------------------
    // Write granted block into shared ring buffer
    // -------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (reset) begin
            shared_wr_addr <= 0;
            ram_we         <= 0;
            ram_wr_data    <= 0;
            block_addr0    <= 0;
            block_addr1    <= 0;
            block_addr2    <= 0;
            block_addr3    <= 0;
        end else begin
            ram_we <= 0;
            if (shared_can_write && !triggered) begin
                if (arb_grants[0]) begin
                    ram_wr_data    <= block_data0;
                    ram_we         <= 1;
                    shared_wr_addr <= shared_wr_next;
                    block_addr0    <= block_next0;
                end else if (arb_grants[1]) begin
                    ram_wr_data    <= block_data1;
                    ram_we         <= 1;
                    shared_wr_addr <= shared_wr_next;
                    block_addr1    <= block_next1;
                end else if (arb_grants[2]) begin
                    ram_wr_data    <= block_data2;
                    ram_we         <= 1;
                    shared_wr_addr <= shared_wr_next;
                    block_addr2    <= block_next2;
                end else if (arb_grants[3]) begin
                    ram_wr_data    <= block_data3;
                    ram_we         <= 1;
                    shared_wr_addr <= shared_wr_next;
                    block_addr3    <= block_next3;
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // AXI4-Stream: send 64-bit sample as two 32-bit words
    // -------------------------------------------------------------------------
    localparam S_IDLE    = 2'd0;
    localparam S_HI_WORD = 2'd1;
    localparam S_LO_WORD = 2'd2;

    reg [1:0]            axis_state;
    reg [DATA_WIDTH-1:0] sample_latch;
    reg                  rd_advance;

    always @(posedge aclk) begin
        if (reset)
            shared_rd_addr <= 0;
        else if (rd_advance)
            shared_rd_addr <= shared_rd_next;
    end

    always @(posedge aclk) begin
        if (reset) begin
            axis_state    <= S_IDLE;
            m_axis_tdata  <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
            sample_latch  <= 0;
            rd_advance    <= 0;
        end else begin
            rd_advance <= 0;
            case (axis_state)
                S_IDLE: begin
                    m_axis_tvalid <= 0;
                    m_axis_tlast  <= 0;
                    if (shared_can_read) begin
                        sample_latch <= ram_rd_data;
                        rd_advance   <= 1;
                        axis_state   <= S_HI_WORD;
                    end
                end
                S_HI_WORD: begin
                    m_axis_tdata  <= sample_latch[63:32];
                    m_axis_tvalid <= 1;
                    m_axis_tlast  <= 0;
                    if (m_axis_tready)
                        axis_state <= S_LO_WORD;
                end
                S_LO_WORD: begin
                    m_axis_tdata  <= sample_latch[31:0];
                    m_axis_tvalid <= 1;
                    m_axis_tlast  <= 1;
                    if (m_axis_tready) begin
                        m_axis_tvalid <= 0;
                        m_axis_tlast  <= 0;
                        axis_state    <= S_IDLE;
                    end
                end
                default: axis_state <= S_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Trigger latch
    // -------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (reset) begin
            triggered          <= 0;
            triggered_block_id <= 0;
            triggered_address  <= 0;
        end else begin
            if (!triggered && |trig_outs) begin
                triggered         <= 1;
                triggered_address <= shared_wr_addr;
                if      (trig_outs[0]) triggered_block_id <= 2'd0;
                else if (trig_outs[1]) triggered_block_id <= 2'd1;
                else if (trig_outs[2]) triggered_block_id <= 2'd2;
                else                   triggered_block_id <= 2'd3;
            end
        end
    end

endmodule
