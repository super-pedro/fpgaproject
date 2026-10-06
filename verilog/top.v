module top(
    input wire clk,
    input wire btnC,
    input wire btnU,
    input wire btnD,
    input wire btnL,
    input wire btnR,
    output wire led0,
    output wire led1
);

wire [3:0] input_pattern;

assign input_pattern[0] = btnU;
assign input_pattern[1] = btnD;
assign input_pattern[2] = btnL;
assign input_pattern[3] = btnR;

ann_classifier classifier(
    .x(input_pattern),
    .class0(led0),
    .class1(led1)
);

endmodule
