import config_pkg::*; // for GPIO_NUM_INPUTS constant

module gpio_decoder (
    input  logic                      clk,
    input  logic                      reset,
    input  logic [GPIO_NUM_INPUTS-1:0] inputs,        // <-- now vector
    output logic [GPIO_NUM_INPUTS-1:0] gpio_rising,   // <-- now vector
    output logic [GPIO_NUM_INPUTS-1:0] gpio_falling   // <-- now vector
);

    genvar i;
    generate
        for (i = 0; i < GPIO_NUM_INPUTS; i++) begin : gpio_decoder_gen

            logic last_state_reg, current_state_reg;

            always_ff @(posedge clk) begin
                if (reset) begin
                    last_state_reg    <= 1'b0;
                    current_state_reg <= 1'b0;
                end else begin
                    last_state_reg    <= current_state_reg;
                    current_state_reg <= inputs[i];  // ? valid indexing now
                end
            end

            assign gpio_rising[i]  = ~last_state_reg &  current_state_reg;
            assign gpio_falling[i] =  last_state_reg & ~current_state_reg;
        end
    endgenerate

endmodule
