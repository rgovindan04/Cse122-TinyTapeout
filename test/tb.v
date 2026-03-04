`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump waveform
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // ALU inputs
  reg [3:0] a;
  reg [3:0] b;
  reg [2:0] op;

  // ALU outputs
  wire [3:0] y;
  wire carry;

  // Instantiate ALU
  alu dut (
      .a(a),
      .b(b),
      .op(op),
      .y(y),
      .carry(carry)
  );

  // Test helper
  task check;
    input [3:0] expected;
    begin
      if (y !== expected) begin
        $display("TEST FAILED: a=%d b=%d op=%b -> got=%d expected=%d",
                  a, b, op, y, expected);
        $finish;
      end
      else begin
        $display("PASS: a=%d b=%d op=%b result=%d", a, b, op, y);
      end
    end
  endtask


  initial begin

    // ADD
    a = 4; b = 3; op = 3'b000; #10;
    check(7);

    // SUB
    a = 9; b = 4; op = 3'b001; #10;
    check(5);

    // AND
    a = 4'b1010; b = 4'b1100; op = 3'b010; #10;
    check(4'b1000);

    // OR
    a = 4'b1010; b = 4'b0101; op = 3'b011; #10;
    check(4'b1111);

    // XOR
    a = 4'b1010; b = 4'b1100; op = 3'b100; #10;
    check(4'b0110);

    // NOT
    a = 4'b1010; op = 3'b101; #10;
    check(4'b0101);

    // SHIFT LEFT
    a = 4'b0011; op = 3'b110; #10;
    check(4'b0110);

    // SHIFT RIGHT
    a = 4'b1000; op = 3'b111; #10;
    check(4'b0100);

    $display("ALL TESTS PASSED");
    $finish;

  end

endmodule
