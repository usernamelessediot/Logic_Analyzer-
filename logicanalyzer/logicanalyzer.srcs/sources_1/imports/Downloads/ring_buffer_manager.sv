// ring_buffer_manager.sv
// No package dependency — plain parameters for port widths.
// Used by analyzer_block internally for per-block ring buffers.

module ring_buffer_manager #(
    parameter PTR_WIDTH = 8  // default matches RINGBUF_ADDR_SIZE = clog2(256)
)(
    input  logic [PTR_WIDTH-1:0] current_write_pointer,
    output logic [PTR_WIDTH-1:0] next_write_pointer,
    output logic                 can_write,

    input  logic [PTR_WIDTH-1:0] current_read_pointer,
    output logic [PTR_WIDTH-1:0] next_read_pointer,
    output logic                 can_read,

    input  logic [31:0]          ring_buffer_size
);

    always_comb begin
        // Next write pointer — wrap at ring_buffer_size
        if (current_write_pointer == ring_buffer_size - 1)
            next_write_pointer = '0;
        else
            next_write_pointer = current_write_pointer + 1'b1;

        // Next read pointer — wrap at ring_buffer_size
        if (current_read_pointer == ring_buffer_size - 1)
            next_read_pointer = '0;
        else
            next_read_pointer = current_read_pointer + 1'b1;

        // Full: write would catch up to read
        can_write = (next_write_pointer != current_read_pointer);

        // Empty: read would catch up to write
        can_read  = (next_read_pointer  != current_write_pointer);
    end

endmodule
