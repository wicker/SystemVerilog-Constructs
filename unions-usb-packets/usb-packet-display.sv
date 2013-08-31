USB Packet Handler

Write a function that accepts a USB 2.0 packet as an argument and prints
out its name, type, and contents in a "pretty" format.

========================================================================

Algorithm:

Specify high speed or full speed or low speed.

	Take transmitted PID byte and process to actual PID. 
	Test PID
		if Token, set name, sync, pid, addr, endp, crc5, eop
			  print packet
		if Data, set name, sync, pid, data, crc16, eop
			  print packet
		if Handshake, set name, sync, pid, eop
			  print packet

========================================================================

// max size of a captured packet is 8 bytes on low and 64 bytes otherwise

module USB_handler (input bytes [63:0] packet_in);

  parameter SYSTEMSPEED = Low; // alternatives are Full and High

  typedef bit[3:0] nibble;

  enum {,OUT, ACK, DATA0, PING, SOF, NYET, DATA2, SPLIT, 
         IN, NAK, DATA1, ERR, SETUP, STALL, MDATA} packet_name;

	// Token = 1, 4, 5, 8, 9, 13 
	// Handshake = 2, 6, 10, 12, 14
	// Data = 3, 7, 11, 15

  enum {Token, Handshake, Data} packet_type;

  typedef nibble type_bits;

  typedef union {byte sync_low_full_speed;
                 byte [3:0] sync_high_speed;
                 packet_name pid;
                 bit [6:0] addr;
                 nibble endp;
                 bit [15:0] data_crc;
                 bit [4:0] token_crc;
                 bit end_of_packet;
                 byte [7:0] data_payload_low_speed;
                 byte [1022:0] data_payload_full_speed;
                 byte [1023:0] data_payload_high_speed;
                }; USB2_packet;

  if (SYSTEMSPEED != High) 
    begin
    int pid = {packet_in[11],packet_in[10],packet_in[9],packet_in[8]};
    USB2_packet.pid = name_bits;
    end
  else if (SYSTEMSPEED == High)
    begin
    int type_bits = {packet_in[35],packet_in[34],packet_in[33],packet_in[32]};
    USB2_packet.pid = name.bits;
    end
  else
    begin
    $display("The system speed is not correctly set.");
    end 
  
    // set our local packet's type

    if (name_bits == 1 || name_bits == 4 || name_bits == 5 || name_bits == 8 ||
        name_bits == 9 || name_bits == 13) 
        begin
        USB2_packet.packet_type = 0;
        end
    if (name_bits == 2 || name_bits == 6 || name_bits == 10 || name_bits == 12 ||
        name_bits == 14) 
        begin
        USB2_packet.packet_type = 1;
        end
    if (name_bits == 3 || name_bits == 7 || name_bits == 11 || name_bits == 15) 
        begin
        USB2_packet.packet_type = 2;
        end

  if (USB2_packet.packet_type == 0) // Token Packet 
    begin
    if (SYSTEMSPEED == High)
      begin
      USB2_packet.sync_high_speed = packet_in[0:31];
      USB2_packet.addr = packet_in[46:40];
      USB2_packet.endp = packet_in[50:47];
      USB2_packet.token_crc = packet_in[55:51];
      USB2_packet.end_of_packet = packet_in[:56];
      end
    else
      begin
      USB2_packet.sync_low_speed = packet_in[7:0];
      USB2_packet.addr = packet_in[22:16];
      USB2_packet.endp = packet_in[26:23];
      USB2_packet.token_crc = packet_in[31:27];
      USB2_packet.end_of_packet = packet_in[:32];
      end
   end

  else if (USB2_packet.packet_type == 0) // Handshake Packet 
    begin
    if (SYSTEMSPEED == High)
      begin
      USB2_packet.sync_high_speed = packet_in[0:31];
      USB2_packet.end_of_packet = packet_in[:40];
      end
    else
      begin
      USB2_packet.sync_low_speed = packet_in[7:0];
      USB2_packet.end_of_packet = packet_in[:16];
      end
    end

  else if (USB2_packet.packet_type == 0) // Data Packet 
    begin
    if (SYSTEMSPEED = High)
       begin
       USB2_packet.sync_high_speed = packet_in[0:31];
       USB2_packet.data_payload_high_speed = packet_in[];
       USB2_packet.data_crc = packet_in[];
       USB2_packet.end_of_packet = packet_in[];
       end
    if (SYSTEMSPEED = Full)
       begin
       USB2_packet.sync_low_full_speed = packet_in[0:31];
       USB2_packet.data_payload_full_speed = packet_in[];
       USB2_packet.data_crc = packet_in[];
       USB2_packet.end_of_packet = packet_in[];
       end
    else
       begin
       USB2_packet.sync_low_full_speed = packet_in[0:31];
       USB2_packet.data_payload_low_speed = packet_in[];
       USB2_packet.data_crc = packet_in[];
       USB2_packet.end_of_packet = packet_in[];
       end
    end

$display("Packet Name: %s\n
          Packet Type: %s\n",USB2_packet.packet_name, USB2_packet.packet_type);

if (USB2_packet.packet_type == Token && SYSTEMSPEED == High)
   begin
   $display("SYNC: %x\n
             PID: %x\n
             ADDR: %x\n
             ENDP: %x\n
             CRC5: %x\n
             EOP: %x\n\n", USB2_packet.sync_high_speed, 
                           USB2_packet.pid,
                           USB2_packet.addr,
                           USB2_packet.endp,
                           USB2_packet.token_crc,
                           USB2_packet.end_of_package);
   end
if (USB2_packet.packet_type == Token && SYSTEMSPEED != High)
   begin
   $display("SYNC: %x\n
             PID: %x\n
             ADDR: %x\n
             ENDP: %x\n
             CRC5: %x\n
             EOP: %x\n\n", USB2_packet.sync_low_full_speed, 
                           USB2_packet.pid,
                           USB2_packet.addr,
                           USB2_packet.endp,
                           USB2_packet.token_crc,
                           USB2_packet.end_of_package);
   end
else if (USB2_packet.packet_type == Handshake && SYSTEMSPEED == High)
   begin
   $display("Sync: %x\n
             PID: %x\n
             EOP: %x\n, USB2_packet.sync_high_speed,
                        USB2_packet.pid,
                        USB2_packet.end_of_packet);
   end
else if (USB2_packet.packet_type == Handshake && SYSTEMSPEED != High)
   begin
   $display("Sync: %x\n
             PID: %x\n
             EOP: %x\n, USB2_packet.sync_low_full_speed,
                        USB2_packet.pid,
                        USB2_packet.end_of_packet);
   end
else if (USB2_packet.packet_type = Data && SYSTEMSPEED == High)
   begin
   $display("Sync: %x\n
             PID: %x\n
             Data: %x\n 
             CRC16: %x\n
             EOP: %x\n, USB2_packet.sync_high_speed,
                        USB2_packet.pid,
                        USB2_packet.data_payload_high_speed,
                        USB2_packet.data_crc,
                        USB2_packet.end_of_packet);
   end
else if (USB2_packet.packet_type = Data && SYSTEMSPEED == Full)
   begin
   $display("Sync: %x\n
             PID: %x\n
             Data: %x\n 
             CRC16: %x\n
             EOP: %x\n, USB2_packet.sync_low_full_speed,
                        USB2_packet.pid,
                        USB2_packet.data_payload_full_speed,
                        USB2_packet.data_crc,
                        USB2_packet.end_of_packet); 
   end
else if (USB2_packet.packet_type = Data && SYSTEMSPEED == Low)
   begin
   $display("Sync: %x\n
             PID: %x\n
             Data: %x\n 
             CRC16: %x\n
             EOP: %x\n, USB2_packet.sync_low_full_speed,
                        USB2_packet.pid,
                        USB2_packet.data_payload_low_speed,
                        USB2_packet.data_crc,
                        USB2_packet.end_of_packet);    
  end

endmodule
