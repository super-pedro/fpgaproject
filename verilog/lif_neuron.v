module lif_neuron(
    input wire clk,
    input wire reset,
    input wire spike_in,
    output reg spike_out
);

reg [7:0] voltage = 0;
reg [25:0] led_counter = 0;
reg [26:0] leak_counter = 0;

parameter WEIGHT = 8'd20;
parameter THRESHOLD = 8'd100;
parameter LEAK_AMOUNT = 8'd10;
parameter LEAK_TIME = 27'd100_000_000;

always @(posedge clk) begin

    if (reset) begin
        voltage <= 0;
        spike_out <= 0;
        led_counter <= 0;
        leak_counter <= 0;
    end

    else begin

        if (led_counter > 0) begin
            led_counter <= led_counter - 1;
            spike_out <= 1;
        end
        else begin
            spike_out <= 0;
        end

        if (leak_counter >= LEAK_TIME) begin
            leak_counter <= 0;

            if (voltage >= LEAK_AMOUNT)
                voltage <= voltage - LEAK_AMOUNT;
            else
                voltage <= 0;
        end
        else begin
            leak_counter <= leak_counter + 1;
        end

        if (spike_in) begin
            if (voltage + WEIGHT >= THRESHOLD) begin
                voltage <= 0;
                led_counter <= 50_000_000;
                spike_out <= 1;
            end
            else begin
                voltage <= voltage + WEIGHT;
            end
        end

    end

end

endmodule
