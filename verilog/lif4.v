module lif4 #(
    parameter integer W0 = 10,
    parameter integer W1 = 10,
    parameter integer W2 = 10,
    parameter integer W3 = 10,
    parameter integer THRESHOLD = 40
)(
    input wire clk,
    input wire reset,
    input wire [3:0] spikes,
    output reg spike_out
);

integer voltage = 0;
integer leak_counter = 0;
integer sum;

always @(posedge clk) begin
    if (reset) begin
        voltage <= 0;
        leak_counter <= 0;
        spike_out <= 0;
    end
    else begin
        spike_out <= 0;

        sum = 0;

        if (spikes[0]) sum = sum + W0;
        if (spikes[1]) sum = sum + W1;
        if (spikes[2]) sum = sum + W2;
        if (spikes[3]) sum = sum + W3;

        if (voltage + sum >= THRESHOLD) begin
            voltage <= 0;
            spike_out <= 1;
        end
        else begin
            voltage <= voltage + sum;
        end

        if (leak_counter >= 100_000_000) begin
            leak_counter <= 0;

            if (voltage >= 5)
                voltage <= voltage - 5;
            else
                voltage <= 0;
        end
        else begin
            leak_counter <= leak_counter + 1;
        end
    end
end

endmodule
