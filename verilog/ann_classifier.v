module ann_classifier(
    input wire [3:0] x,
    output reg class0,
    output reg class1
);

integer h0, h1, h2, h3;
integer o0, o1;

always @(*) begin

    h0 =  3*x[0] - 7*x[1] + 1*x[2] - 6*x[3] - 5;
    h1 = -28*x[0] +22*x[1] + 2*x[2] + 2*x[3] +26;
    h2 = -16*x[0] +21*x[1] + 7*x[2] + 7*x[3] + 9;
    h3 =  4*x[0] + 0*x[1] - 3*x[2] - 3*x[3] - 1;

    if (h0 < 0) h0 = 0;
    if (h1 < 0) h1 = 0;
    if (h2 < 0) h2 = 0;
    if (h3 < 0) h3 = 0;

    o0 =  4*h0 -34*h1 -28*h2 -7*h3 + 65*16;
    o1 = -7*h0 +26*h1 +23*h2 +2*h3 - 63*16;

    class0 = 0;
    class1 = 0;

    if (o0 > o1)
        class0 = 1;
    else
        class1 = 1;
end

endmodule
