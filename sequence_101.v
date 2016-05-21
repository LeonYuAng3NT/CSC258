module sequence_101(clock, resetn, w, z);

    input clock, resetn, w;
    output z;
    
    reg [1:0] present_state, next_state; 
    // present_state => Outputs Q of flip-flops.
    // next_state => Inputs D of flip-flops.
    
    localparam [1:0] A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
    // Could also use parameter instead of localparam.
    
    // Combinational Circuit A. Drives FFs inputs. 
    // Function of current FF state and input(s).
    // Note the different coding styles (e.g., if-else, use of ternary ? operator, etc.) 
    // Either is fine. Just use on style. I just mixed them here for your reference.
    always @ (*) begin
       case (present_state)
           A: 
              begin
                  if (w == 1'b1)
                      next_state = B;
                  else              
                     next_state = A;
              end
           B: next_state = (w == 1'b1) ? B : C; 
           C: next_state = (!w) ? A : D; // Note the use of logical operator ! instead of the bitwise ~)
           D: next_state =  (!w) ? C : B;
           default: next_state = A;
       endcase
    end
    
    // State Flip-Flops. Note the non-blocking assignment statements.
    always @ (posedge clock, negedge resetn) begin
       if (resetn == 1'b0)
           present_state <= A;
       else
           present_state <= next_state;
    end
    
    
    // Combinational Circuit B. Implements output function. 
    // Function of current FF state only (Moore FSM).
    // Function of both current FF state and input(s) (Mealy FSM).
    
    assign z = (present_state == D);
    // Alternatively, if there are more outputs, write it as always @(*)
    // Careful, do NOT write .. == 2'b11. Use the parameter name (here D).

endmodule
