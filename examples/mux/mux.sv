module mux #(
    parameter NUM_PORTS=4,
    parameter DATA_WIDTH=8,
    parameter SEL_WIDTH=$clog2(NUM_PORTS)
) (
    input [SEL_WIDTH-1:0] sel,
    input [DATA_WIDTH-1:0] in[NUM_PORTS],
    output [DATA_WIDTH-1:0] out
);

    assign out = in[sel];

endmodule
