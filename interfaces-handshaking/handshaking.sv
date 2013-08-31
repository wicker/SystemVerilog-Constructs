//
// Simple handshaking example
// Found in my homework files
// I don't actually remember writing this
// but I'm not sure who else would have
// so. you know. here it is.
//

interface main_bus ();
  logic client_ready;
  logic server_ready;
  logic [3:0] data;

  modport server (
    input   client_ready,
    output  server_ready,
    output  data,
    import  pause);

  modport client (
    output  client_ready,
    input   server_ready,
    input   data,
    import  pause);

  // interface method can operate on any signals in the interface
  task pause();
    logic [3:0] delay;
    delay = $random;
    if (delay == 0) delay = 1;
    #delay;
  endtask : pause;

endinterface

module server (main_bus.server mbus);

  logic [3:0] data_out; 
  assign mbus.data = data_out;

  always begin
    mbus.server_ready = 0;
    mbus.pause;

      wait (mbus.client_ready)
      mbus.pause;
      data_out = $random;
      mbus.pause;
      mbus.server_ready = 1;

        wait (!mbus.client_ready)
        mbus.pause;
  end

endmodule : server

module client (main_bus.client mbus);

  logic [3:0] data_in; // for verification

  always begin
    mbus.client_ready = 0;
    mbus.pause;
    mbus.client_ready = 1;

    forever begin
      wait (mbus.server_ready)
      mbus.pause;
      data_in = mbus.data;
      mbus.pause;
      mbus.client_ready = 0;
        wait (!mbus.server_ready)
        mbus.pause;
        mbus.client_ready = 1;
    end
  end
    
endmodule : client

module top ();

  parameter MAX = 5;

  main_bus mbus();
  server a_server(mbus);
  client a_client(mbus);

  // set up the number of test cases
  int i = 0;
  logic flag;
  int good, bad;
  logic [3:0] test;

  always_ff @(posedge mbus.server_ready) begin
    $display("server: '%H' ",mbus.data);
    test = mbus.data;
    if (i == MAX) flag = 1;
    else i++;
  end

  always_ff @(negedge mbus.client_ready) begin 
    $display("client: '%H'",mbus.data);
    assert (test ==? mbus.data) $display("SUCCESS.\n");
    else $warning("Client wrote in a nibble that is not what server provided to the bus.");
    if (flag == 1) begin
      i++;
      $display("TOTAL CHECKS: %0d\n",i);
      $stop;
    end
  end

endmodule : top

