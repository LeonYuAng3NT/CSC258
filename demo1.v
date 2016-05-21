// This is a comment.
// demo1 is the name of our top-level module.
module demo1(SW, LEDR);
    input [2:0] SW;
    output [9:0] LEDR;

    wire connection;

    // We will cascade two 2-input and gates. 
    // This is one instance of the my_and module named u1.
    my_and u1(
     .in1(SW[0]),
     .in2(SW[1]),
     .out1(connection));

    // This is a second instance of the my_and module named u2.
    // One if its inputs is the output of u1.
    my_and u2(.in1(connection),
    .in2(SW[2]),
    .out1(LEDR[0]));

endmodule

module my_and(in1, in2, out1);
    input in1;
    input in2;
    output out1;

    // This is a 2-input and gate.
    assign out1 = in1 & in2;
endmodule
