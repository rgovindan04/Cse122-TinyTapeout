`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  reg  [3:0] a;
  reg  [3:0] b;
  reg  [2:0] op;

  wire [3:0] y;
  wire       carry;

  alu dut (
      .a(a),
      .b(b),
      .op(op),
      .y(y),
      .carry(carry)
  );

  // golden model: returns {carry, y}
  function [4:0] golden;
    input [3:0] ga;
    input [3:0] gb;
    input [2:0] gop;
    begin
      case (gop)
        3'b000: golden = ga + gb;                 // {carry,y}
        3'b001: golden = ga - gb;                 // {carry,y}
        3'b010: golden = {1'b0, (ga & gb)};
        3'b011: golden = {1'b0, (ga | gb)};
        3'b100: golden = {1'b0, (ga ^ gb)};
        3'b101: golden = {1'b0, (~ga)};
        3'b110: golden = {1'b0, (ga << 1)};
        3'b111: golden = {1'b0, (ga >> 1)};
        default: golden = 5'b0;
      endcase
    end
  endfunction

  integer ai, bi, oi;
  integer tests;
  reg [4:0] exp;

  initial begin
    tests = 0;

    // Exhaustive: 8 ops * 16 A * 16 B = 2048 cases
    for (oi = 0; oi < 8; oi = oi + 1) begin
      for (ai = 0; ai < 16; ai = ai + 1) begin
        for (bi = 0; bi < 16; bi = bi + 1) begin
          op = oi[2:0];
          a  = ai[3:0];
          b  = bi[3:0];
          #1; // settle

          exp = golden(a, b, op);
          tests = tests + 1;

          // Check y
          if (y !== exp[3:0]) begin
            $display("FAIL(Y): op=%b a=%0d (0x%0h) b=%0d (0x%0h) got y=%0d (0x%0h) exp y=%0d (0x%0h)",
                     op, a, a, b, b, y, y, exp[3:0], exp[3:0]);
            $finish;
          end

          // Check carry behavior (matches your ALU)
          if ((op == 3'b000) || (op == 3'b001)) begin
            if (carry !== exp[4]) begin
              $display("FAIL(C): op=%b a=%0d b=%0d got carry=%b exp carry=%b",
                       op, a, b, carry, exp[4]);
              $finish;
            end
          end else begin
            if (carry !== 1'b0) begin
              $display("FAIL(C0): op=%b a=%0d b=%0d got carry=%b exp carry=0",
                       op, a, b, carry);
              $finish;
            end
          end
        end
      end
    end

    $display("ALL TESTS PASSED (%0d cases)", tests);
    $finish;
  end

endmodule