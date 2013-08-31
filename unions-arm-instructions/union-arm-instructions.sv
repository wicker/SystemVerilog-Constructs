//
//  ARM Instruction parser which reads out the instruction
//  in the appropriate format. Uses unions and structs.
//
//  Jenner Hanni
//

package definitions;

  //
  // Data Processing 
  //
  typedef struct packed {
    logic [1:0] zeros;
    logic immediate;
    logic [3:0] opcode;
    logic setcondition;
  } dataprocAlt;

  typedef union packed {
    logic [7:0] flag;
    dataprocAlt notflag;
  } dataprocflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    dataprocflagAlt flagunion;
    logic [3:0] Rn;
    logic [3:0] Rd;
    logic [11:0] operandTwo;
  } dataprocessingInstruction;

  //
  // Multiply and Multiply-Accumulate (MUL, MLA)
  //
  typedef struct packed {
    logic [5:0] placeholder;
    logic accumulate;
    logic setcondition;
  } multAlt;

  typedef union packed {
    logic [7:0] flag;
    multAlt notflag;
  } multflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    multflagAlt flagunion;
    logic [3:0] Rd;
    logic [3:0] Rn;
    logic [3:0] Rs;
    logic [3:0] nine;
    logic [3:0] Rm; 
  } multiplyInstruction;

  //
  // Single Data Swap (SWP)
  //
  typedef struct packed {
    logic [4:0] placeholder;
    logic bytebit;
    logic [1:0] zeros;
  } swpAlt;

  typedef union packed {
    logic [7:0] flag;
    swpAlt notflag;
  } swpflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    swpflagAlt flagunion;
    logic [3:0] Rn;
    logic [3:0] Rd;
    logic [3:0] morezeros;
    logic [3:0] nine;
    logic [3:0] Rm; 
  } singledataswapInstruction;

  //
  // Single Data Transfer (LDR, SWP)
  //
  typedef struct packed {
    logic [1:0] one;
    logic immediateOffset;
    logic prepostBit;
    logic updownBit;
    logic bytewordBit;
    logic writebackBit;
    logic loadstoreBit;
  } singledataAlt;

  typedef union packed {
    logic [7:0] flag;
    singledataAlt notflag;
  } singledataflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    singledataflagAlt flagunion;
    logic [3:0] Rn;
    logic [3:0] Rd;
    logic [11:0] offset; 
  }  singledatatransferInstruction;

  //
  // Undefined Instruction
  // 
  typedef struct packed {
    logic [2:0] three;
    logic [4:0] nocare;
  } undefAlt;

  typedef union packed {
    logic [7:0] flag;
    undefAlt notflag;
  } undefflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    undefflagAlt flagunion;
    logic [14:0] empty;
    logic one;
    logic [3:0] alsoempty;
  } undefinedInstruction;

  //
  // Block Data Transfer (LDM, STM)
  //
  typedef struct packed {
    logic [2:0] four;
    logic prepostBit;
    logic updownBit;
    logic PSRforceuserBit;
    logic writebackBit;
    logic loadstoreBit; 
  } blockdataAlt;

  typedef union packed {
    logic [7:0] flag;
    blockdataAlt notflag;
  } blockdataflagAlt;
  
  typedef struct packed {
    logic [3:0] condition;
    blockdataflagAlt flagunion;
    logic [3:0] Rn;
    logic [15:0] registerList;
  } blockdatatransferInstruction;

  //
  // Branch and Branch with Link (B, BL)
  //
  typedef struct packed {
    logic [2:0] five;
    logic linkBit; 
  } branchAlt;

  typedef union packed {
    logic [3:0] flag; 
    branchAlt notflag;
  } branchflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    branchflagAlt flagunion;
    logic [23:0] offset;
  } branchInstruction;

  //
  // Coprocessor Data Transfers (LDC, STC)
  //
  typedef struct packed {
    logic [2:0] six;
    logic prepostBit;
    logic updownBit;
    logic lengthBit;
    logic writebackBit;
    logic loadstoreBit;
  } coprocdatatransferAlt;

  typedef union packed {
    logic [7:0] flag;
    coprocdatatransferAlt notflag;
  } coprocdatatransferflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    coprocdatatransferflagAlt flagunion;
    logic [3:0] Rn;
    logic [3:0] CRd;
    logic [3:0] cp_num;
    logic [7:0] offset;
  } coprocdatatransferInstruction;

  //
  // Coprocessor Data Operations (CDP) 
  //
  typedef struct packed {
    logic [3:0] fourteen;
    logic [3:0] opcode;
  } coprocdataopAlt;

  typedef union packed {
    logic [7:0] flag;
    coprocdataopAlt notflag;
  } coprocdataopflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    coprocdataopflagAlt flagunion;
    logic [3:0] CRn;
    logic [3:0] CRd; 
    logic [3:0] cp_num;
    logic [2:0] CP;
    logic zero;
    logic [3:0] CRm;
  } coprocdataoperationInstruction;

  //
  // Coprocessor Register Transfers (MRC, MCR)
  //
  typedef struct packed {
    logic [3:0] fourteen;
    logic [2:0] opmode;
    logic loadstoreBit;
  } coprocregtranAlt;

  typedef union packed {
    logic [7:0] flag;
    coprocregtranAlt notflag;
  } coprocregtranflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    coprocregtranflagAlt flagunion;
    logic [3:0] CRn; 
    logic [3:0] Rd;
    logic [3:0] cp_num;
    logic [2:0] CP;
    logic one;
    logic [3:0] CRm;
  } coprocregistertransferInstruction;

  //
  // Software Interrupt (SWI)
  //
  typedef struct packed {
    logic [3:0] fifteen;
  } softintAlt;

  typedef union packed {
    logic [3:0] flag;
    softintAlt notflag;
  } softintflagAlt;

  typedef struct packed {
    logic [3:0] condition;
    softintflagAlt flagunion;
    logic [23:0] comment;
  } softwareinterruptInstruction;

  // this union is capable of modeling ARM7TDMI instructions
  // based on the ARMv4 architecture. it does not model Thumb instructions.

  typedef union packed {
    dataprocessingInstruction         dataproc; 
    multiplyInstruction               multiply;
    singledataswapInstruction         singleswap;
    singledatatransferInstruction     singletransfer;
    undefinedInstruction              undefined;
    blockdatatransferInstruction      blockdata;
    branchInstruction                 branch;
    coprocdatatransferInstruction     coprocdatatransfer;
    coprocdataoperationInstruction    coprocdataoperation;
    coprocregistertransferInstruction coprocregtransfer;
    softwareinterruptInstruction      softwareinterrupt;
  } instruction;

  //
  // Function to receive, identify, and print the corresponding fields
  //

  function identifyInstruction(input instruction inst, string name);

    case (inst[27:26]) 
      2'b00 : begin 
        if (inst[24] == 0) begin
          // could be data processing, PSR transfer or multiply
          $display("This instruction could be data processing/PSR transfer or multiply/multiply-accumulate.\nThe possibilities arrangements are included below.\n");
          $display("%s: %b %b %b %b %b %b %b %b\n",name,inst.dataproc.condition, inst.dataproc.flagunion.notflag.zeros, inst.dataproc.flagunion.notflag.immediate,inst.dataproc.flagunion.notflag.opcode,inst.dataproc.flagunion.notflag.setcondition,inst.dataproc.Rn,inst.dataproc.Rd,inst.dataproc.operandTwo);
          $display("%s: %b %b %b %b %b %b %b %b %b\n",name,inst.multiply.condition, inst.multiply.flagunion.notflag.placeholder,inst.multiply.flagunion.notflag.accumulate,inst.multiply.flagunion.notflag.setcondition,inst.multiply.Rd,inst.multiply.Rn,inst.multiply.Rs,inst.multiply.nine,inst.multiply.Rm);
        end
        else begin
          // single data swap
          $display("%s: %b %b %b %b %b %b %b %b %b\n",name,inst.singleswap.condition, inst.singleswap.flagunion.notflag.placeholder, inst.singleswap.flagunion.notflag.bytebit, inst.singleswap.flagunion.notflag.zeros, inst.singleswap.Rn, inst.singleswap.Rd, inst.singleswap.morezeros, inst.singleswap.nine, inst.singleswap.Rm);

        end
      end

      2'b01 : begin
        if (inst[24] != "x") begin
          // single data transfer
          $display("%s: %b %b %b %b %b %b %b %b %b %b %b\n",name,inst.singletransfer.condition,inst.singletransfer.flagunion.notflag.one,inst.singletransfer.flagunion.notflag.immediateOffset,inst.singletransfer.flagunion.notflag.prepostBit,inst.singletransfer.flagunion.notflag.updownBit,inst.singletransfer.flagunion.notflag.bytewordBit,inst.singletransfer.flagunion.notflag.writebackBit,inst.singletransfer.flagunion.notflag.loadstoreBit,inst.singletransfer.Rn,inst.singletransfer.Rd,inst.singletransfer.offset);
        end
        else begin
          // undefined inst
          $display("%s: %b %b %b %b %b\n",name,inst.undefined.condition,inst.undefined.flagunion.notflag.three,inst.undefined.flagunion.notflag.nocare,inst.undefined.empty,inst.undefined.one,inst.undefined.alsoempty);
        end
      end

      2'b10 : begin
        if (inst[25] == 0) begin
          // block data transfer
          $display("%s: %b %b %b %b %b %b %b %b %b\n",name,inst.blockdata.condition,inst.blockdata.flagunion.notflag.four,inst.blockdata.flagunion.notflag.prepostBit,inst.blockdata.flagunion.notflag.updownBit,inst.blockdata.flagunion.notflag.PSRforceuserBit,inst.blockdata.flagunion.notflag.writebackBit,inst.blockdata.flagunion.notflag.loadstoreBit,inst.blockdata.Rn,inst.blockdata.registerList);
        end
        else begin
          // branch inst
          $display("%s: %b %b %b %b\n",name,inst.branch.condition,inst.branch.flagunion.notflag.five,inst.branch.flagunion.notflag.linkBit,inst.branch.offset);
        end 
      end

      2'b11 : begin
        if (inst[25] == 0) begin
          // coprocessor data transfer
          $display("%s: %b %b %b %b %b %b %b %b %b %b %b\n",name,inst.coprocdatatransfer.condition,inst.coprocdatatransfer.flagunion.notflag.six,inst.coprocdatatransfer.flagunion.notflag.prepostBit,inst.coprocdatatransfer.flagunion.notflag.updownBit,inst.coprocdatatransfer.flagunion.notflag.lengthBit,inst.coprocdatatransfer.flagunion.notflag.writebackBit,inst.coprocdatatransfer.flagunion.notflag.loadstoreBit,inst.coprocdatatransfer.Rn,inst.coprocdatatransfer.CRd,inst.coprocdatatransfer.cp_num,inst.coprocdatatransfer.offset);
        end
        else begin
          if (inst[24] == 0) begin
            if (inst[4] == 0) begin
              // coprocessor data operation
              $display("%s: %b %b %b %b %b %b %b %b %b\n",name,inst.coprocdataoperation.condition,inst.coprocdataoperation.flagunion.notflag.fourteen,inst.coprocdataoperation.flagunion.notflag.opcode,inst.coprocdataoperation.CRn,inst.coprocdataoperation.CRd,inst.coprocdataoperation.cp_num,inst.coprocdataoperation.CP,inst.coprocdataoperation.zero,inst.coprocdataoperation.CRm);
            end
            else begin
              // coprocessor register transfer
              $display("%s: %b %b %b %b %b %b %b %b %b %b\n",name,inst.coprocregtransfer.condition,inst.coprocregtransfer.flagunion.notflag.fourteen,inst.coprocregtransfer.flagunion.notflag.opmode,inst.coprocregtransfer.flagunion.notflag.loadstoreBit,inst.coprocregtransfer.CRn,inst.coprocregtransfer.Rd,inst.coprocregtransfer.cp_num,inst.coprocregtransfer.CP,inst.coprocregtransfer.one,inst.coprocregtransfer.CRm);
            end
          end
          else begin
            // software interrupt
            $display("%s: %b %b %b\n",name,inst.softwareinterrupt.condition,inst.softwareinterrupt.flagunion.notflag.fifteen,inst.softwareinterrupt.comment);
          end
      end
  end endcase

  endfunction
endpackage

module ARMInstructions();

  import definitions::*;

  logic [31:0] inst;

  typedef struct {
    string s;  
    instruction arg;
  } test;
  
  test a[11];

  //
  // load test array
  //

  initial begin
    a[0].s = "Data Processing";
    a[0].arg = 32'b00000000000000000000000000000000;
    a[1].s = "Multiply";
    a[1].arg = 32'b00000000000000000000000010010000;
    a[2].s = "Single Data Swap";
    a[2].arg = 32'b00000001000000000000000010010000;
    a[3].s = "Single Data Transfer";
    a[3].arg = 32'b00000100000000000000000000000000;
    a[4].s = "Undefined Instruction";
    a[4].arg = 32'b00000110000000000000000000010000;
    a[5].s = "Block Data Transfer";
    a[5].arg = 32'b00001000000000000000000000000000;
    a[6].s = "Branch Instruction";
    a[6].arg = 32'b00001010000000000000000000000000;
    a[7].s = "Coprocessor Data Transfer";
    a[7].arg = 32'b00001100000000000000000000000000;
    a[8].s = "Coprocessor Data Operation";
    a[8].arg = 32'b00001110000000000000000000000000;
    a[9].s = "Coprocessor Register Transfer";
    a[9].arg = 32'b00001110000000000000000000010000;
    a[10].s = "Software Interrupt";
    a[10].arg = 32'b0000111100000000000000000000000;

    //
    // run testcases through the function
    //
    foreach(a[index]) begin 
      identifyInstruction(a[index].arg,a[index].s);
    end
  end

endmodule


