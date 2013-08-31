//
// I took a base FIFO testbench written by someone else and 
// added assertions to verify its functionality.
// 
// Jenner Hanni
//

package definitions;

  timeunit 1ns;
  timeprecision 1ns;

  parameter WIDTH = 8;
  parameter DEPTH = 16;		// must be 2^DEPTHLOG2
  parameter DEPTHLOG2 = 4;
  parameter CLOCK_CYCLE = 2ms;
  parameter CLOCK_WIDTH = CLOCK_CYCLE/2;
  parameter PUSH = 0;
  parameter POP = 1;

endpackage

module Concurrents (clk, reset, push, pop, in, out, empty, full);

  import definitions::*;

  input wire clk, reset, push, pop;
  input wire [WIDTH-1:0] in;
  input wire empty, full;
  input wire [WIDTH-1:0] out;

  property never_push_into_full;
    @(posedge clk) full |-> ~push;
  endproperty

  property never_pop_from_empty;
    @(posedge clk) empty |-> ~pop;
  endproperty

  property rptr_unmodified_if_pop_not_asserted;
    @(posedge clk) ~pop |=> $stable(fifo.rptr);
  endproperty

  property wptr_unmodified_if_push_not_asserted;
    @(posedge clk) ~push |=> $stable(fifo.wptr);
  endproperty

  property rptr_increment_by_one_on_pop;
    @(posedge clk) pop |=> (fifo.rptr == fifo.rptr + 1'b1);
  endproperty

  property wptr_increment_by_one_on_push;
    @(posedge clk) push |=> (fifo.wptr == fifo.wptr + 1'b1);
  endproperty 

  a6: assert property (never_push_into_full);
  a7: assert property (never_pop_from_empty);
//  a8: assert property (rptr_unmodified_if_pop_not_asserted);
//  a9: assert property (wptr_unmodified_if_push_not_asserted);
// a10: assert property (rptr_increment_by_one_on_pop);
// a11: assert property (wptr_increment_by_one_on_push);

endmodule

module TestBench();

  import definitions::*;

  reg  clk, reset, in, push, pop;
  wire out, empty, full;

  logic [WIDTH-1:0] data;

  FIFO fifo (clk, reset, push, pop, in, out, empty, full);
  bind FIFO Concurrents c1 (clk, reset, push, pop, in, out, empty, full);
  
  initial begin
    clk = 0;
    forever #CLOCK_WIDTH clk = ~clk;
  end

  typedef struct {
    logic pushpop;
    logic [WIDTH-1:0] data;
  } transaction;

  initial begin

    $display("On startup, the FIFO empty, full, push and pop are all unknown.");
    $display("You should see a set of assertion errors here:\n");

    @(negedge clk) {push,pop,reset} = 3'b001; 

    // Testcase a1: verify push and pop work

    $display("\nTEST RESULT: Basic functionality: Push and pop work.");
    @(negedge clk) {push,pop,reset} = 3'b100; in = 8'b0;
    @(negedge clk) {push,pop,reset} = 3'b010; 

    // Testcase a2a: verify assertion errors on push + unknown in

    $display("\nTEST RESULT: (a1) Assertion should error on push and unknown in");
    @(negedge clk) {push,pop,reset} = 3'b100; in = 8'bx;
    @(negedge clk) {push,pop,reset} = 3'b001; 

    // Testcase a2b: verify assertion errors on pop + unknown out

    $display("\nTEST RESULT: (a1) Assertion should error on pop and unknown out");
    $display("This doesn't work from here without modifying FIFO to expose fifo.out");
//  @(negedge clk) {push,pop,reset} = 3'b010; fifo.out = 8'bx;
//  @(negedge clk) {push,pop,reset} = 3'b001; 

    // Testcase a3a: push itself should never be unknown

    $display("\nTEST RESULT: (a3a) Assertion should error on unknown push.");
    @(negedge clk) {push,pop,reset} = 3'bx00; in = 8'b0;
    @(negedge clk) {push,pop,reset} = 3'b001; 

    // Testcase a3b: pop itself should never be unknown

    $display("\nTEST RESULT: (a3b) Assertion should error on unknown pop.");
    @(negedge clk) {push,pop,reset} = 3'b0x0; in = 8'b0;
    @(negedge clk) {push,pop,reset} = 3'b001; 

    // Testcase a5: push and pop are never simultaneously true

    $display("\nTEST RESULT: (a5) Assertion should error on pop and push true.");
    @(negedge clk) {push,pop,reset} = 3'b110; in = 8'b0;
    @(negedge clk) {push,pop,reset} = 3'b001; 
    
    // Testcase a6: can't push into full fifo

    $display("\nTEST RESULT: (a6) Assertion should error on push into full FIFO.");
    begin
      for (int i = 0; i <= DEPTH; i++) begin
          @(negedge clk) {push,pop,reset} = 3'b100; in = 8'b0;
      end
      @(negedge clk) {push,pop,reset} = 3'b100; in = 8'b0;
    end
      
    // Testcase a7: can't pop from empty fifo

    $display("\nTEST RESULT: (a7) Assertion should error on push into full FIFO.");
    @(negedge clk) {push,pop,reset} = 3'b001; 
    @(negedge clk) {push,pop,reset} = 3'b010; in = 8'b0;
     
    // Testcase: rptr only changes if pop asserted
    // Testcase: wptr only changes if push asserted
    // Testcase: rptr incremented by one on a pop operation
    // Testcase: wptr incremented by one on a push operation

    $display("\nTests complete.");

    $stop;

  end

endmodule
  

