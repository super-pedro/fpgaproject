module snn_accelerator(
    input wire clk,
    input wire reset,
    input wire [3:0] spikes_in,
    output reg class0,
    output reg class1
);

integer v0, v1, v2, v3;
integer o0, o1;

integer i0, i1, i2, i3;
integer j0, j1;

integer count0, count1;

reg [16:0] tick_counter = 0;

parameter THRESHOLD = 32;

always @(posedge clk) begin

    if (reset) begin
        v0 <= 0;
        v1 <= 0;
        v2 <= 0;
        v3 <= 0;

        o0 <= 0;
        o1 <= 0;

        count0 <= 0;
        count1 <= 0;

        class0 <= 0;
        class1 <= 0;

        tick_counter <= 0;
    end

    else begin

        // No input means no active inference
        if (spikes_in == 4'b0000) begin
            v0 <= 0;
            v1 <= 0;
            v2 <= 0;
            v3 <= 0;

            o0 <= 0;
            o1 <= 0;

            count0 <= 0;
            count1 <= 0;

            class0 <= 0;
            class1 <= 0;

            tick_counter <= 0;
        end

        else if (tick_counter < 100_000) begin
            tick_counter <= tick_counter + 1;
        end

        else begin
            tick_counter <= 0;

            // Hidden layer biases
            i0 = 13;
            i1 = 11;
            i2 = 7;
            i3 = -2;

            // Input 0
            if (spikes_in[0]) begin
                i0 = i0 + 21;
                i1 = i1 - 31;
                i2 = i2 - 7;
                i3 = i3 - 1;
            end

            // Input 1
            if (spikes_in[1]) begin
                i0 = i0 - 22;
                i1 = i1 + 27;
                i2 = i2 + 13;
                i3 = i3 + 23;
            end

            // Input 2
            if (spikes_in[2]) begin
                i0 = i0 + 10;
                i1 = i1 + 9;
                i2 = i2 - 3;
                i3 = i3 - 8;
            end

            // Input 3
            if (spikes_in[3]) begin
                i0 = i0 + 15;
                i1 = i1 + 15;
                i2 = i2 - 6;
                i3 = i3 - 8;
            end

            // Hidden layer leak
            v0 = (v0 * 13) >>> 4;
            v1 = (v1 * 13) >>> 4;
            v2 = (v2 * 13) >>> 4;
            v3 = (v3 * 13) >>> 4;

            // Add input currents
            v0 = v0 + i0;
            v1 = v1 + i1;
            v2 = v2 + i2;
            v3 = v3 + i3;

            // Reuse these as hidden spike flags
            i0 = 0;
            i1 = 0;
            i2 = 0;
            i3 = 0;

            if (v0 >= THRESHOLD) begin
                i0 = 1;
                v0 = 0;
            end

            if (v1 >= THRESHOLD) begin
                i1 = 1;
                v1 = 0;
            end

            if (v2 >= THRESHOLD) begin
                i2 = 1;
                v2 = 0;
            end

            if (v3 >= THRESHOLD) begin
                i3 = 1;
                v3 = 0;
            end

            // Output layer biases
            j0 = 8;
            j1 = 3;

            if (i0) begin
                j0 = j0 + 18;
                j1 = j1 - 14;
            end

            if (i1) begin
                j0 = j0 - 17;
                j1 = j1 + 24;
            end

            if (i2) begin
                j0 = j0 + 3;
                j1 = j1 + 3;
            end

            if (i3) begin
                j0 = j0 - 2;
                j1 = j1 + 3;
            end

            // Output neuron leak
            o0 = (o0 * 13) >>> 4;
            o1 = (o1 * 13) >>> 4;

            // Add output currents
            o0 = o0 + j0;
            o1 = o1 + j1;

            // Output spikes
            if (o0 >= THRESHOLD) begin
                count0 = count0 + 1;
                o0 = 0;
            end

            if (o1 >= THRESHOLD) begin
                count1 = count1 + 1;
                o1 = 0;
            end

            // Classification
            if (count0 > count1) begin
                class0 <= 1;
                class1 <= 0;
            end
            else if (count1 > count0) begin
                class0 <= 0;
                class1 <= 1;
            end
            else begin
                class0 <= 0;
                class1 <= 0;
            end

        end
    end
end

endmodule
