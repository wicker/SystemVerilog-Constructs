//
// 1 Master, 2 Slaves Bus Interface in System Verilog
// Jenner Hanni
//
// Interface skeleton.
//
// References: 
// = http://www.doulos.com/knowhow/sysverilog/tutorial/interfaces/
// = SystemVerilog for Design, 2nd Ed
//

parameter DATA_BUS_WIDTH = 32;  // data bits plus parity 0 to DATA_BUS_WIDTH
parameter ADDR_BUS_WIDTH = 8;
parameter CLOCK_CYCLE = 2ms;
parameter CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter READ = 0;
parameter WRITE = 1;
parameter TESTCASES = 4; // how many test transactions are in the array?

typedef struct {
  logic rw; 
  logic [ADDR_BUS_WIDTH-1:0] addr;
  logic [DATA_BUS_WIDTH-1:0] data;
} transaction;

transaction test_array [5:0];

module test_system ();

  logic clock;

  initial begin
    clock = 0;
    forever #CLOCK_WIDTH clock = ~clock;
  end

  main_bus bus (clock);

  master m  (bus.master);
  slave #(8'h01) s1 (bus.slave);
  slave #(8'h02) s2 (bus.slave);

  // initialize the array of structs with test cases
  initial begin
    test_array[0].rw = WRITE;
    test_array[0].addr = 8'h01;
    test_array[0].data = 32'h0;
    test_array[1].rw = READ;
    test_array[1].addr = 8'h01;
    test_array[1].data = 32'h0;
    test_array[2].rw = WRITE;
    test_array[2].addr = 8'h01;
    test_array[2].data = 32'h1;
    test_array[3].rw = READ;
    test_array[3].addr = 8'h01;
    test_array[3].data = 32'h0;
  end

endmodule

interface main_bus(input logic clock);

  wire [DATA_BUS_WIDTH-1:0] data_wire;
  wire parity_bit, RB_bit, WB_bit, ack_bit;

  logic [DATA_BUS_WIDTH-1:0] data;
  logic [ADDR_BUS_WIDTH-1:0] address;
  logic parity, RB, WB, ack;

  assign data_wire = data;
  assign parity_bit = parity;
  assign RB_bit = RB;
  assign WB_bit = WB;
  assign ack_bit = ack;

  task master_read (input target_id, output mdata);
    address = target_id;
    RB = 1;
    $display("READ: Master asserts RB and asks for data read from device %h",target_id);
    @(posedge clock) begin
       wait (ack);
       if (compute_parity(data) == parity_bit) begin
          mdata = data;
          $display("Successful read.");
       end
       else
          $display("Calculated parity match failure. Data not read.");
       RB = 0;
    end
  endtask

  task master_write (input target_id, mdata);
    $display("WRITE: Master provides data %h for device %h and asserts WB.",mdata,target_id); 
    address = target_id;
    parity = compute_parity(mdata);
    $display("Parity for bus-bound mdata was %b.",parity);
    data = mdata;
    WB = 1;
    @(posedge clock) begin
       wait (ack);
       WB = 0;
    end
  endtask

  task slave_read (output sdata);
    if (compute_parity(data) == parity_bit) begin
       sdata = data;
       $display("Calculated parity matched. Successful write.");
    end
    else
       $display("Calculated parity match failure. Data not read.");
    ack = 1;
    @(posedge clock) begin
       ack = 0;
    end
  endtask

  task slave_write (input sdata);
    data = sdata;
    $display("After slave write, sdata = %h and bus data wire = %h",sdata,data);
    parity = compute_parity(sdata);
    #1
    $display("Parity bus bit updated to %b",parity_bit);
    ack = 1;
    @(posedge clock) begin
       ack = 0;
    end
  endtask

  function compute_parity (input test_data);
        $display("Parity computed.");
        return(^test_data);
  endfunction

  modport master (import task master_read(input target_id, output mdata),
                  import task master_write(input target_id, mdata),
                  import compute_parity,
                  inout data_wire, parity_bit, output address, RB_bit, WB_bit, 
                  input ack_bit, clock);

  modport slave  (import task slave_read(input sdata),
                  import task slave_write(input sdata),
                  import compute_parity,
                  inout data_wire, parity_bit, output ack_bit, 
                  input address, RB_bit, WB_bit, clock);

endinterface

module master (main_bus bus);

  logic [DATA_BUS_WIDTH-1:0] mdata;
  logic [ADDR_BUS_WIDTH-1:0] target_id;

  initial begin 
  for (int i = 0; i < TESTCASES; i++) begin 
     $display("\nCase %d:",i);
     @(posedge bus.clock) 
        target_id = test_array[i].addr;
        mdata = test_array[i].data; 
        $display("mdata: %h",mdata);
        if (test_array[i].rw == READ) 
           bus.master_read(target_id, mdata); 
        else if (test_array[i].rw == WRITE) 
           bus.master_write(target_id, mdata);
    end
  $stop;
  end
endmodule

module slave (main_bus bus);

  parameter DEVICE_ID;
  logic [DATA_BUS_WIDTH-1:0] sdata = 0;

  always @(posedge bus.clock) begin
    if (bus.address == DEVICE_ID) begin
       if (bus.RB_bit == 1) begin
          $display("Slave %h puts data %h on bus and asserts ack.",DEVICE_ID,sdata);
          bus.slave_write(sdata);
       end
       else if (bus.WB_bit == 1) begin
          $display("Slave %h takes data off the bus and asserts ack.",DEVICE_ID);
          bus.slave_read(sdata); 
       end
    end
  end

endmodule
