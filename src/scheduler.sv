module scheduler # (parameter DEPTH = 64, NUM_FPGA = 64, NUM_QUBIT_PER_FPGA = 64, 
						NUM_INSTRS = 100, NUM_REGS_L1 = 50, NUM_REGS_L2 = 50)
	(
		input clk,
		input rst_n,
		input reg [0:NUM_INSTRS-1] 
			[3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)+19:0] instruction,	// from I CACHE
		output reg [NUM_INSTRS-1:0] status,
		output reg [$clog2(NUM_INSTRS)-1:0] ireg_index					// where to fill up until
	);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//  I-WORD = < op_code 		19+3*clog(total qubits):18+3*clog(total qubits)
	//           | op_1 		17+3*clog(total qubits):18+2*clog(total qubits)
	//			 | op_2 		17+2*clog(total qubits):18+clog(total qubits)
	//		     | dest 		17+clog(total qubits):18 
	// 		     | start_time 	17:2 
	//		  	 | status 		1:0  >                                                                
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	// local parameters
	
	parameter INST_INDEX_MSB = 19+3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA);
	
	wire [1:0] status_wire;
	wire [15:0] start_time;
	wire [$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)-1:0] dest;
	wire [$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)-1:0] op_1;
	wire [$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)-1:0] op_2;
	wire [1:0] op_code; 									// 4 total so 2 bits
	
	// Register Microarchitecture
	
	reg [0:NUM_REGS_L1-1] [3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)+20:0] regs_layer1;
	reg [0:NUM_REGS_L2-1] [3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)+20:0] regs_layer2;
	reg [15:0] curr_timestamp;
	
	// first layer of registers
	
	int i;
	
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			ireg_index <= 0;
		else if (ireg_index == NUM_INSTRS-1)
			ireg_index <= 0;
		
		for(i = 0; i<NUM_REGS_L1; i++)
			if (~regs_layer1[i][1] & instruction[ireg_index][1]) begin
				regs_layer1[i] <= {instruction[ireg_index++][INST_INDEX_MSB:2],2'b10};
			end
	end
	
	
	// dispatch layer of registers
	// 1. check what the current dominant timestamp is
	// 2. fill from first layers any available instructions with matching timestamp
	
	always_ff @ (posedge clk, negedge rst_n) begin
	
	end
	
	// functional units
	
endmodule