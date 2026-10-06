module button_pulse(
    input wire clk,
    input wire btn,
    output reg pulse
);

reg btn_prev = 0;

always @(posedge clk) begin
    pulse <= btn & ~btn_prev;
    btn_prev <= btn;
end

endmodule
