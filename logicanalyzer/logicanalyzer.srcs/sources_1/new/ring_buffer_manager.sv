`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2026 16:47:55
// Design Name: 
// Module Name: ring_buffer_manager
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import config_pkg::*;

module ring_buffer_manager(
    ring_buffer_size,
    current_write_pointer, next_write_pointer,
    current_read_pointer,  next_read_pointer,
    can_read, can_write
);
    input  logic [31:0] ring_buffer_size;
    input  logic [31:0] current_write_pointer;
    input  logic [31:0] current_read_pointer;
    output logic [31:0] next_write_pointer;
    output logic [31:0] next_read_pointer;
    output logic        can_read;
    output logic        can_write;

    always_comb begin
        if (current_write_pointer == ring_buffer_size - 1)
            next_write_pointer = 32'd0;
        else
            next_write_pointer = current_write_pointer + 32'd1;

        if (current_read_pointer == ring_buffer_size - 1)
            next_read_pointer = 32'd0;
        else
            next_read_pointer = current_read_pointer + 32'd1;
    end

    always_comb begin
        can_read  = next_read_pointer  != current_write_pointer;
        can_write = next_write_pointer != current_read_pointer;
    end

endmodule
