`timescale 1ns / 1ps

module mplier88(clock, start, mplier, mcand, product, done);
        input clock, start;
        input [7:0] mplier;
        input [7:0] mcand;
        output reg done;
        reg [2:0] count = 3'b000; // 3-bit counter (because 8 shifts occur)
        reg [1:0] state = 2'd0;
        reg [1:0] nextState = 2'd0;
        reg [8:0] accA;
        reg [7:0] accB;
        reg shift, load, K, M, add;
        output [15:0] product;
        assign product = {{accA[7:0]}, {accB[7:0]}};
        
//        always @(start, state, K, M)
          always @*
            begin
                shift = 1'b0;
                add = 1'b0;
                load = 1'b0;
                done = 1'b0;
                nextState = state;
                case(state)
                    0:
                        begin
                            add = 1'b0;
                            if (start) begin
                                done <= 1'b0;
                                load <= 1'b1;
                                nextState <= 2'd1;
                            end
                            else begin
                                done <= 1'b1;
                                nextState <= 2'd0;
                            end
                        end
                    1:
                        begin
                            M = accB[0];
                            load = 1'b0;
                            if (K) begin
                                add <= 1'b0;
                                shift <= 1'b0;
                                nextState <= 2'd2;
                            end
                            else begin
                                if (M) begin
                                    add <= 1'b1;
                                end
                                else begin
                                    add <= 1'b0;
                                end
                                shift <= 1'b1;
                                nextState <= 2'd1;
                            end
                        end
                    2:
                        begin
                            shift <= 1'b0;
                            done <= 1'b1;
                            nextState <= 2'd0;
                        end        
                    default:
                        begin
                            load = 1'b0;
                            shift = 1'b0;
                            done = 1'b0;
                            add = 1'b0;
                        end         
                endcase        
            end
            
        always @(posedge clock)
            begin
                M = accB[0];
                state = nextState;
                if (load) begin
                    accA = 9'b000000000;
                    count = 3'b000;
                    accB = mplier;
                end
                else if (add) begin
                    accA = {{1'b0}, {accA[7:0]}};
                    accA = accA + mcand;
                end
                if (shift) begin
                    accA <= {{1'b0}, {accA[8:1]}};
                    accB <= {{accA[0]}, {accB[7:1]}};
                    if (count < 4'd8) begin
                        count <= count + 1;
                    end
                end
                else begin end
                K = count == 3'd7 ? 1'b1 : 1'b0;
            end    
endmodule