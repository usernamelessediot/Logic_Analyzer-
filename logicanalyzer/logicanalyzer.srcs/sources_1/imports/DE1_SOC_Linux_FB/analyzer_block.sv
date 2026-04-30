import config_pkg::*;

// =================================================
// counter
// =================================================

module counter(clk, reset, cval);

	input  logic clk, reset;
	output logic [TIMER_BITWIDTH-1:0] cval;
	
	always @(posedge clk) begin
		if (reset) cval <= 0;
		else       cval <= cval + 1;
	end

endmodule


// =================================================
// ring_buffer_ram
// =================================================

module ring_buffer_ram (q, d, wr_addr, rd_addr, we, clk1, clk2);

	input  logic [RINGBUF_WORD_SIZE-1:0] d;
	input  logic [RINGBUF_ADDR_SIZE-1:0] wr_addr, rd_addr;
	input  logic                         we, clk1, clk2;

	output logic [RINGBUF_WORD_SIZE-1:0] q;

	logic [RINGBUF_ADDR_SIZE-1:0] read_address_reg;
	logic [RINGBUF_WORD_SIZE-1:0] mem [RINGBUF_NUM_ENTRIES-1:0];

	always @(posedge clk1) begin
		if (we) 
			mem[wr_addr]  <= d;
	end

	always @(posedge clk2) begin
		q 					  <= mem[read_address_reg];
		read_address_reg <= rd_addr;
	end


endmodule


// =================================================
// trigger_unit
// =================================================

module trigger_unit(
	clk, reset, 
	configuration, trig_cond, 
	trig_in, trig_out,
	gpio_falling, gpio_rising,
	spi_in, spi_val,
	i2c_in, i2c_val
);

	input  logic       clk, reset;
	input  logic [TRIG_CONFIG_BITWIDTH-1:0] configuration;
	
	// Format GPIO: [8bitmask] --> [4rising][4falling]
	// Format SPI: [8bitmask][8bitcondition]
	// Format I2C: [8bitmask][8bitcondition]
	input  logic [TRIG_COND_BITWIDTH-1  :0] trig_cond;
	input  logic       trig_in;
	
	input  logic [GPIO_NUM_INPUTS-1:0] gpio_falling; 
	input  logic [GPIO_NUM_INPUTS-1:0] gpio_rising;
	
	input  logic [7:0] 					  spi_in;
	input  logic [7:0]					  i2c_in;
	input	 logic 							  spi_val;
	input  logic							  i2c_val;
	
	output logic       trig_out; 	
	
	
	logic [7:0] mask;
	logic [7:0] cond;
	assign mask = trig_cond[15:8];
	assign cond = trig_cond[7:0];
	
	integer i;
	always @(posedge clk) begin
		if (reset) begin
			trig_out <= 1'b0;
		end else begin
			
			case (configuration)
				CONFIG_DISABLE: 
					trig_out <= 1'b0;
					
				CONFIG_GPIO: begin
					if (( {gpio_rising, gpio_falling} & trig_cond ) > 0) trig_out <= 1'b1;
					else																  trig_out <= 1'b0;
				end
				
				CONFIG_SPI: begin
					if (spi_val) begin
						if ((mask&spi_in) == (mask&cond)) trig_out <= 1'b1;
						else 										 trig_out <= 1'b0;
					end else 									 trig_out <= 1'b0;
				end
				
				CONFIG_I2C: begin
					if (i2c_val) begin
						if ((mask&i2c_in) == (mask&cond)) begin
							trig_out <= 1'b1;
						end else begin
							trig_out <= 1'b0;
						end
					end else begin
						trig_out <= 1'b0;
					end
				end
				
				default: begin
					trig_out <= 1'b0;
				end
			endcase
			
		end
	end

endmodule


// =================================================
// analyzer_block
// =================================================

module analyzer_block(clk, reset, inputs, configuration, trig_config, trig_cond, trig_out, sampler_id, data_can_read, data_read_data, data_read_addr, data_read_next_addr);
	
	input  logic       									clk, reset;
	input  logic [GPIO_NUM_INPUTS-1:0] 				inputs;
	input  logic [ANALBLK_CONFIG_BITWIDTH-1:0]	configuration;
	input  logic [TRIG_COND_BITWIDTH-1  :0]      trig_cond;
	input  logic [TRIG_CONFIG_BITWIDTH-1:0]      trig_config;
	
	input  logic [1:0]									sampler_id;
	
	output logic                                 trig_out;
	
	// Keep track of current_time
	logic [TIMER_BITWIDTH-1:0] timer_value;
	counter cnt(clk, reset, timer_value); // TODO: Reset on trigger? Or store time at trigger and subtract
	
	// Ring Buffer for temporary sample storage
	logic ring_buf_val;
   logic [RINGBUF_WORD_SIZE-1:0] 		ring_buf_data;
	logic [RINGBUF_ADDR_SIZE-1:0] 		ring_buf_addr;
	logic [RINGBUF_ADDR_SIZE-1:0] 		ring_buf_next_addr;
	logic                         		ring_buf_can_write;

	
	input  logic [RINGBUF_ADDR_SIZE-1:0] data_read_addr;
	output logic [RINGBUF_ADDR_SIZE-1:0] data_read_next_addr;
	output logic [RINGBUF_WORD_SIZE-1:0] data_read_data;
	output logic                         data_can_read;
		
	ring_buffer_ram ringbuf(
		.q				(data_read_data), 
		.d				(ring_buf_data), 
		.wr_addr		(ring_buf_addr), 
		.rd_addr		(data_read_addr), 
		.we			(ring_buf_val), 
		.clk1			(clk), 
		.clk2			(clk)
	);
	
	ring_buffer_manager buf_manager(
		.ring_buffer_size				(RINGBUF_NUM_ENTRIES),
		
		.current_write_pointer		(ring_buf_addr), 
		.next_write_pointer			(ring_buf_next_addr),
		.can_write						(ring_buf_can_write), 

		.current_read_pointer		(data_read_addr), 
		.next_read_pointer			(data_read_next_addr),
		.can_read						(data_can_read)
	);

	
	// GPIO Decoder
	logic [GPIO_NUM_INPUTS-1:0] gpio_dec_rising;
	logic [GPIO_NUM_INPUTS-1:0] gpio_dec_falling;
	logic [2*GPIO_NUM_INPUTS-1:0] gpio_status;
	assign gpio_status = { gpio_dec_rising, gpio_dec_falling };
	
	gpio_decoder gpio(
		.clk			   (clk), 
		.reset		   (reset), 
		.inputs		   (inputs), 
		.gpio_rising	(gpio_dec_rising), 
		.gpio_falling	(gpio_dec_falling)
	);
	
	
	// I2C decoder
	logic [9:0] i2c_acquire_data;
	logic       i2c_acquire_val;
	
	i2c_decoder i2c(
		.clk				(clk), 
		.reset			(reset), 
		.sda				(inputs[1]), 
		.scl				(inputs[0]),
		.acquire_val	(i2c_acquire_val), 
		.acquire_data	(i2c_acquire_data)
	);
	
	// SPI decoder
	logic [15:0] spi_acquire_data;
	logic        spi_acquire_val;
	spi_decoder spi(
		.clk				(clk), 
		.reset			(reset), 
		.sck				(inputs[0]), 
		.miso				(inputs[1]), 
		.mosi				(inputs[2]), 
		.cs				(inputs[3]),
		.acquire_val	(spi_acquire_val),
		.acquire_data  (spi_acquire_data)
	);	
	
	// Trigger Unit
	trigger_unit trigger(
		.clk						(clk), 
		.reset					(reset), 
		.configuration			(trig_config), 
		.trig_cond				(trig_cond), 
		.trig_in					(1'd0), 
		.trig_out				(trig_out),
		.gpio_falling			(gpio_dec_falling), 
		.gpio_rising			(gpio_dec_rising),
		.spi_in					(spi_acquire_data[15:8]),
		.spi_val					(spi_acquire_val),
		.i2c_in					(i2c_acquire_data[9:2]),
		.i2c_val					(i2c_acquire_val)
	);
	
	// =================================================
	// state
	// =================================================
	/*logic triggered;
	
	// Update triggered
	always @(posedge clk) begin
		if (reset) triggered <= 0;
		else begin
			if (trig_out && ~triggered) begin
				triggered <= 1;
				// TODO: set start time and ringbuf address
			end // TODO: else if (done_condition) ... 
		end
	end*/
	
   // =================================================
	// acquire
	// =================================================
	
	always @(posedge clk) begin
		if (reset) begin
			ring_buf_addr <= 1;
			ring_buf_data <= 0;
			ring_buf_val  <= 0;
		end else begin
			case (configuration)
				ANALBLK_CONFIG_DISABLED: ; 
					// do nothing! :D
				
				
				ANALBLK_CONFIG_GPIO: begin 
					// write gpio changes if any
					if (gpio_status) begin
					   if (ring_buf_can_write) begin
							ring_buf_addr <= ring_buf_next_addr;
							ring_buf_data <= { sampler_id, timer_value, 2'b01, 6'b0, gpio_status };
							ring_buf_val  <= 1;
						end else begin
							ring_buf_val  <= 0;
							// TODO: Log this somehow! We're dropping samples!
						end
					end else begin
						ring_buf_val  <= 0;
					end
				end
				
				ANALBLK_CONFIG_SPI:  
					if (spi_acquire_val) begin
						if (ring_buf_can_write) begin
						   ring_buf_addr <= ring_buf_next_addr;
							ring_buf_data <= { sampler_id, timer_value, 2'b10, spi_acquire_data };
							ring_buf_val  <= 1'b1;
						end else begin
							ring_buf_val  <= 0;
							// TODO: Log this somehow! We're dropping samples!
						end
					end else begin
						ring_buf_val  <= 0;
					end
				
				ANALBLK_CONFIG_I2C: begin  
					if (i2c_acquire_val) begin
						if (ring_buf_can_write) begin
							ring_buf_addr <= ring_buf_next_addr;
							ring_buf_data <= { sampler_id, timer_value, 2'b11, 6'b0, i2c_acquire_data };
							ring_buf_val  <= 1;
						end else begin
							ring_buf_val  <= 0;
							// TODO: Log this somehow! We're dropping samples!
						end
					end else begin
						ring_buf_val  <= 0;
					end
				end
				
				default:  ;
				
			endcase
		end
	end

endmodule
