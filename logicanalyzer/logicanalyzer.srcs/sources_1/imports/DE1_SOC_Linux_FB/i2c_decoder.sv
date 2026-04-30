// i2c_decoder.sv
// FIX: Delete `include "config.sv" and add the import statement

import config_pkg::*; // <-- CRITICAL FIX: Imports all constants and definitions

module i2c_decoder(clk, reset, sda, scl, acquire_val, acquire_data);

	input logic clk, reset, sda, scl;
	
	output logic        acquire_val;
	output logic [9:0] acquire_data;
	
	// Counter to revert to IDLE state
	// (for error recovery)
	// BUS_TIMEOUT_CYCLES is now correctly defined via the import
	logic bus_timeout_cnt;
	logic                                  idle_timeout;
	

	
	// Byte characteristics
	logic [3:0] current_byte_id;
	logic [7:0] current_byte_value;
	logic       current_start_type; 
	logic       stop_asserted;
	logic       ack_asserted;
	// =====================
	
	// Current state
	// 0    : idle
	// 1    : data
	// 2  : waiting for ack/nack
	// 3  : waiting for stop/repeated start
	// S_BUS_IDLE, S_DATA, S_ACK_NACK, S_REPSTRT_STOP are defined by the import
	logic [3:0] current_state;
	logic  [3:0] next_state;
	
	// Hysteresis for SDA SCL
	logic last_SDA, last_SCL;
	logic latch_SDA, latch_SCL;
	
	// Static relations between SDA and SCL
	logic sda_rise, sda_fall, scl_rise, scl_fall;
	assign sda_rise = ~last_SDA &  latch_SDA;
	assign sda_fall =  last_SDA & ~latch_SDA;
	assign scl_rise = ~last_SCL &  latch_SCL;
	assign scl_fall =  last_SCL & ~latch_SCL;
	
	// More static relations - i2c protocol specific
	logic start_cond, stop_cond, ack_cond;
	assign start_cond = latch_SCL & sda_fall; // SCL high, SDA falling
	assign stop_cond    = latch_SCL & sda_rise; // SCL high, SDA rising
	assign ack_cond    = ~latch_SDA;            // SDA high (nack) low (ack)

	// Update last and current values of SDA and SCL
	always @(posedge clk) begin
		if (reset) begin
			// Bus idle - SCL and SDA high
			last_SDA <= 1;
			last_SCL <= 1;
			latch_SDA <= 1;
			latch_SCL <= 1;
		end else begin
			// Update input registers each cycle
			latch_SDA <= sda;
			latch_SCL <= scl;
			last_SDA <= latch_SDA;
			last_SCL <= latch_SCL;
		end
	end
	
	// Update decode FSM
	always @(posedge clk) begin
		if (reset) begin
			current_state <= S_BUS_IDLE;
		end else begin
			current_state <= next_state;
		end
	end
	
	// calculate next state
	always @(*) begin
		if (reset) begin
			next_state = S_BUS_IDLE;
		end else begin
	
		
			case (current_state)
				
				S_BUS_IDLE:      begin
					if (start_cond) next_state = S_DATA;
					else             next_state = S_BUS_IDLE;
				end
				
				S_DATA: begin
					if      (scl_rise && current_byte_id == 7) next_state = S_ACK_NACK;
					else if (idle_timeout)                             next_state = S_BUS_IDLE;
					else                                                   next_state = S_DATA;
				end
				
				S_ACK_NACK:      begin 
					if      (scl_rise)   next_state = S_REPSTRT_STOP;
					else if (idle_timeout) next_state = S_BUS_IDLE;
					else                   next_state = S_ACK_NACK;
				end
				
				S_REPSTRT_STOP: begin 
					if      (start_cond)   next_state = S_DATA;
					else if (stop_cond)    next_state = S_BUS_IDLE;
					else if (idle_timeout) next_state = S_BUS_IDLE;
					else                   next_state = S_REPSTRT_STOP;
				end
				
				default:         begin
					next_state = S_BUS_IDLE;
				end
				
			endcase
		
		end
	end
	
	// Update packet characteristics based on inputs and state
	always @(posedge clk) begin
		if (reset) begin
			current_byte_value <= 0;
			current_start_type <= 0;
			stop_asserted      <= 0;
			ack_asserted         <= 0;
			current_byte_id    <= 0;
		end else begin
			
			case (current_state)
				
				S_BUS_IDLE:      begin
					// reset everything
					current_byte_id    <= 0;
					current_byte_value <= 0;
					ack_asserted       <= 0;
					stop_asserted      <= 0;
					current_start_type <= 0;
					if (start_cond) current_start_type <= START;
				end
				
				S_DATA: begin
					if (scl_rise) begin
						current_byte_value[7 - (current_byte_id)] <= latch_SDA;
						current_byte_id <= current_byte_id + 1;
					end
				end
				
				S_ACK_NACK:      begin 
					if (scl_rise) ack_asserted <= ack_cond;
				end
				
				S_REPSTRT_STOP: begin 
					if    (start_cond) current_start_type <= REPEATED_START;  /* new byte */
					else if (stop_cond)  stop_asserted <= 1;                   /* back to idle */
				end
				
				default:         begin
					// something went wrong here
				end
				
			endcase
			
		end
	end
	
	// Write to output
	always @(posedge clk) begin
		if (reset) begin
			acquire_val  <= 0;
			acquire_data <= 0;
		end else begin
			// Frame done when S_REPSTRT_STOP transitions to another state (and we didn't timeout)
			if (current_state == S_REPSTRT_STOP && next_state!= S_REPSTRT_STOP &&!idle_timeout) begin
				acquire_val  <= 1;
				// Data format {data(8), ack/nack(1), stop(1)}
				acquire_data <= {current_byte_value, ack_asserted, stop_cond};
			end else begin
				acquire_val <= 0;
			end
		end 
	end
	
	// Idle timeout
	always @(posedge clk) begin
		if (reset |

| current_state == S_BUS_IDLE) begin
			bus_timeout_cnt <= 0;
			idle_timeout    <= 0;
		end else begin
			if (bus_timeout_cnt < BUS_TIMEOUT_CYCLES) begin
				bus_timeout_cnt <= bus_timeout_cnt + 1;
				idle_timeout    <= 0;
			end else begin
				bus_timeout_cnt <= bus_timeout_cnt;
				idle_timeout    <= 1;
			end
		end
	end


endmodule