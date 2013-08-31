//
// I took a base FIFO written by someone else and 
// added assertions to verify its functionality.
// 
// Jenner Hanni
//

module FIFO(clk, reset, push, pop, in, out, empty, full);

  import definitions::*;

  input logic clk, reset, push, pop;
  input logic [WIDTH-1:0] in;
  output logic empty, full;
  output logic [WIDTH-1:0] out;

  reg [WIDTH-1:0] data[DEPTH];		// actual data for the FIFO
  reg [DEPTHLOG2:0] rptr, wptr;		// read and write pointers
					  // additional bit for full/empty processing

  assign out = data[rptr[DEPTHLOG2-1:0]];
  assign empty = (wptr == rptr);
  assign full = ((rptr[DEPTHLOG2-1:0] == wptr[DEPTHLOG2-1:0]) && (rptr[DEPTHLOG2] ^ wptr[DEPTHLOG2]));


  always @(posedge clk) begin
    if (reset) begin
      rptr <= 0;
      wptr <= 0;
      end
    else if (pop && ~empty && ~$isunknown(pop)) begin
      a2: assert ($isunknown(out) == 0)
      else $error ("Out contains at least one unknown bit. Incremented read pointer.");
      rptr <= rptr + 1'b1;
    end
    else if (push && ~full && ~$isunknown(push)) begin
      a1: assert ($isunknown(in) == 0) begin
          data[wptr[DEPTHLOG2-1:0]] <= in;
          $display("Data pushed was %h.",in);
          wptr <= wptr + 1'b1;
        end
    else if (push && full)
        $display("whaaaat.");
      else 
        $error ("a1: In contains at least one unknown bit. No incrementing, no data pushed.");
    end
    a3a: assert ($isunknown(push) == 0) else $error ("Unknown push");
    a3b: assert (~$isunknown(pop)) else $error ("Unknown pop");
    a4a: assert (~$isunknown(empty)) else $error ("Unknown empty");
    a4b: assert (~$isunknown(full)) else $error ("Unknown full");
    a5:  assert (~(push && pop)) else $error ("Pop and push both true.");

  end

endmodule

