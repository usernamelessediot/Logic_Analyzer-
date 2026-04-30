module spi_decoder(clk, reset, sck, miso, mosi, cs, acquire_val, acquire_data);

	input logic clk, reset, sck, miso, mosi, cs;
	
	output logic        acquire_val;
	output logic [15:0] acquire_data;
	
	// Hysteresis for CS, SCK
	logic last_SCK, last_CS;
	logic latch_SCK, latch_CS;
	
	// Static relations between CS and SCK
	logic sck_rise, sck_fall, cs_rise, cs_fall;
	assign sck_rise = ~last_SCK &  latch_SCK;
	assign sck_fall =  last_SCK & ~latch_SCK;
	assign cs_rise = ~last_CS  &  latch_CS;
	assign cs_fall =  last_CS  & ~latch_CS;
	
	// Update last and current values of CS and SCK
	always @(posedge clk) begin
		if (reset) begin
			// Bus idle - CS high, SCK low
			last_SCK  <= 0;
			last_CS   <= 1;
			latch_SCK <= 0;
			latch_CS  <= 1;
		end else begin
			// Update input registers each cycle
			latch_SCK <= sck;
			latch_CS  <= cs;
			last_SCK  <= latch_SCK;
			last_CS   <= latch_CS;
		end
	end
	
	
	logic       bus_activity;
	logic [2:0] bit_idx;
	logic [7:0] mosi_value, miso_value;
	
	always @(posedge clk) begin
		if (reset) begin
			bus_activity 	<= 1'b0;
			bit_idx        <= 3'd0;
			mosi_value     <= 8'd0;
			miso_value     <= 8'd0;
		end else begin
			
			if (bus_activity) begin
				if (sck_rise) begin
					if (bit_idx < 3'd7) bit_idx <= bit_idx + 1;
					mosi_value <= {mosi_value[6:0], mosi};
					miso_value <= {miso_value[6:0], miso};
					acquire_val  <= 1'b0;
				end else if (cs_rise) begin
					// CS high - terminate current transaction
					bus_activity <= 1'b0;
					if (bit_idx == 3'd7) begin
						// if we read full 8 bits, write to memory
						acquire_val  <= 1'b1;
						acquire_data <= {mosi_value, miso_value};					
					end
				end
			end else begin
				acquire_val  	 <= 1'b0;
				if (cs_fall) begin
					// start transactions
					bus_activity <= 1'b1;
					mosi_value   <= 8'd0;
					miso_value   <= 8'd0;
					bit_idx      <= 3'd0;
				end
			end
			
			
		end
	end
	

endmodule 