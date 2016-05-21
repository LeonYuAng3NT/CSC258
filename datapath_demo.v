`timescale 1ns / 1ns // `timescale time_unit/time_precision

module datapath_demo(
    input CLOCK_50,
    input [9:0] SW,
    input [3:0] KEY,
    output [9:0] LEDR
    );

    demo u0(
        .resetn(KEY[0]),
        .clk(CLOCK_50),
        .go(~KEY[1]),
        .done(LEDR[9]),
        .x(SW[7:0]),
        .f(LEDR[7:0])
        );
endmodule


module demo(clk, resetn, go, done, x, f);
    input clk, resetn, go;
    input [7:0] x;
    output [7:0] f;
	 output done;
	 
    wire SelxA, SelAB, LdRA, LdRB, ALUop;

    control c0(
        // system signals
        .resetn(resetn),
        .clock(clk),

        // FSM signals
        .go(go),
        .done(done),
        
        // Datapath Control signals
        .SelxA(SelxA),
        .SelAB(SelAB),
        .LdRA(LdRA),
        .LdRB(LdRB),
        .ALUop(ALUop)
    );

    
    datapath d0(
        // System signals
        .resetn(resetn),
        .clock(clk),

        // Data in / out
        .x(x),
        .f(f),

        // Control signals
        .selxA(SelxA),
        .selAB(SelAB),
        .ALUop(ALUop),
        .LdRA(LdRA),
        .LdRB(LdRB)    
    );

endmodule


module control(resetn, clock, go, done, SelxA, SelAB, LdRA, LdRB, ALUop);

    input resetn, go, clock;
    output reg SelxA, SelAB, LdRA, LdRB;
    output reg ALUop; // 0 for addition, 1 for multiplication
    output reg done;  // ALUOut has valid final result


    localparam [1:0] LOAD_X = 0,  COMPUTE_X_SQUARE = 1,
              COMPUTE_2X = 2, FINAL_RESULT = 3;

    // Make sure we select enough bits for all of our states
    reg [1:0] current_state, next_state; 

    
    // Next State Combination Logic. Drives next state for flip-flops.
    always @ (*)
    begin
        case (current_state)
            LOAD_X: next_state = go ? COMPUTE_X_SQUARE : LOAD_X;
            COMPUTE_X_SQUARE: next_state = COMPUTE_2X;
            COMPUTE_2X: next_state = FINAL_RESULT;
            FINAL_RESULT: next_state = FINAL_RESULT;
            default: next_state = LOAD_X;
        endcase
    end


    // Output Combinational Logic. Drives all the control signals
    always @ (*)
    begin
        // Alternatively you need to ensure you set the appropriate values in
        // every case expression. In this case you can skip default (iff you've
        // included everything here.
        //{LdRA, LdRB} = 2'b00;
        //{SelxA, SelAB} = 2'b00;
        //ALUop = 1'b0;
        //done = 1'b0; 

    case (current_state)
        LOAD_X: begin   // Do x + 0 and store this into both registers
            LdRA = 1'b1;
            LdRB = 1'b1;
            SelxA = 1'b0; 
            SelAB = 1'b0;
            ALUop = 1'b0;
            done = 1'b0;
        end
        COMPUTE_X_SQUARE: begin // Do x^2 and load result to RA
           LdRA = 1'b1;
           LdRB = 1'b0;
           SelxA = 1'b0;
           SelAB = 1'b0;
           ALUop = 1'b1;
           done = 1'b0;
        end

        COMPUTE_2X: begin // Do 2x and load result into RB
            LdRA = 1'b0;
            LdRB = 1'b1;
            SelxA = 1'b0;
            SelAB = 1'b1;
            ALUop = 1'b0;
            done = 1'b0;
        end

        FINAL_RESULT: begin // Add x^2 with 2x from RA and RB
           LdRA = 1'b0;
           LdRB = 1'b0;
           SelxA = 1'b1;
           SelAB = 1'b1;
           ALUop = 1'b0;
           done = 1'b1;
        end

        default: begin
           {LdRA, LdRB} = 2'b00;
           {SelxA, SelAB} = 2'b00;
           ALUop = 1'b0;
           done = 1'b0; 
        end
        endcase
    end
    

    // FSM State Register/Flip-flops
    always @ (posedge clock, negedge resetn)
        if (resetn == 1'b0)
            current_state <= LOAD_X; // Set our reset state here
        else
            current_state <= next_state;

endmodule

     

module datapath(x, resetn, clock, selxA, selAB, ALUop, LdRA, LdRB, f);

    input [7:0] x;
    input resetn, clock, selxA, selAB, ALUop, LdRA, LdRB;
    output [7:0] f;


    // Internal signals
    wire [7:0] Mux1_Out, Mux2_Out;
    reg [7:0] RA_Out, RB_Out;
    reg [7:0] ALUout;


    // Registers RA, RB
    always @ (posedge clock, negedge resetn)
        if (resetn == 1'b0) begin
            RA_Out <= 0;
            RB_Out <= 0;
            end
        else begin
            if (LdRA == 1'b1)
                RA_Out <= ALUout;

            if (LdRB == 1'b1) // Careful it should not be an else if!
                RB_Out <= ALUout;
            // The lack of else implies a memory element.
        end 


    // Multiplexers
    assign Mux1_Out = selxA ? RA_Out : x;
    assign Mux2_Out = selAB ? RB_Out : RA_Out;

   
    // ALU 
    always @(*)
        case (ALUop)
            0: ALUout = Mux1_Out + Mux2_Out;
            1: ALUout = Mux1_Out * Mux2_Out;
            default: ALUout = 8'd0;
        endcase



    // output result on f
    assign f = ALUout;

endmodule


