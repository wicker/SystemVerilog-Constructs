Create a typedef for a union to represent USB 2.0 packets. 

There are three types of USB 2.0 packets. 
They all take up 

  typedef union {token_packet token,
                 handshake_packet handshake,
                 data_packet data} packet_type;

  typedef struct packed {
                  union {
                    byte [3:0] sync_low_full_speed; // only uses one byte
                    byte [3:0] sync_high_speed;
                  }
                  packet_name pid;
                  bit [6:0] addr;
                  nibble endp;
                  union {
                    bit [15:0] data_crc;
                    bit [15:0] token_crc; // only uses 5b of 16
                  }
                  bit end_of_packet;
                  union {
                    byte [1023:0] data_payload_low_speed; // only uses 8b
                    byte [1023:0] data_payload_full_speed; // only uses 1023b
                    byte [1023:0] data_payload_high_speed;
                  }
                 } token_packet;

Reference: http://www.beyondlogic.org/usbnutshell/usb3.shtml


