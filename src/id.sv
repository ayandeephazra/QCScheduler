module id # (parameter DEPTH = 64, NUM_FPGA = 64, NUM_QUBIT_PER_FPGA = 64)(
		input clk,
		input rst_n,
		input [3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)+20:0] instruction,	// from I CACHE
		input valid,										// valid is high for 1 cycle when new instruction is available
		output queue_full,									// if high, then do not overwrite data at instruction
		output queue_empty,									// if high, then queue empty
		output wrap_around
	);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	///* I-WORD = <start_time 55:40| op_code 39:38| op_1 37:26| op_2 25:14| dest 13:2 | status 1:0> *///
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	/* operand signals */
	parameter NUM_OPERANDS = NUM_FPGA*NUM_QUBIT_PER_FPGA;
	wire [15:0] start_time;
	wire [1:0] op_code;
	wire [$clog2(NUM_OPERANDS)-1:0] op_1;
	wire [$clog2(NUM_OPERANDS)-1:0] op_2;
	wire [$clog2(NUM_OPERANDS)-1:0] dest;
	
	/* queue signals */
	parameter PTRWIDTH = $clog2(DEPTH);
	parameter DATAWIDTH = 16 + 2 + 3*$clog2(NUM_OPERANDS) + 2; // or 3*$clog2(NUM_OPERANDS) + 20
	reg [DATAWIDTH - 1:0] queue [DEPTH];
	reg [PTRWIDTH-1:0] iter;
	reg [PTRWIDTH:0] head;
	reg [PTRWIDTH:0] tail;
	
	/////////////////////////////////
	///* OPERAND LOOKUP SIGNALS *///
	///////////////////////////////
	
	parameter FPGA_INDX_BIT_LIMIT = $clog2(NUM_FPGA);
	parameter QUBIT_PER_FPGA_BIT_LIMIT = $clog2(NUM_QUBIT_PER_FPGA);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	///* oplu-word = < fpga_indx FPGA_INDX_BIT_LIMIT:1| valid 0|              *///
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	reg [FPGA_INDX_BIT_LIMIT+QUBIT_PER_FPGA_BIT_LIMIT:0] oplu[0:NUM_OPERANDS-1];
	
	/* operand comb logic */
	assign start_time = instruction[55:40];
	assign op_code = instruction[39:38];
	parameter op1_up = 3*$clog2(NUM_OPERANDS)+1;
	parameter op1_down = 2*$clog2(NUM_OPERANDS)+2;
	assign op_1 = instruction[op1_up:op1_down];
	parameter op2_up = 2*$clog2(NUM_OPERANDS)+1;
	parameter op2_down = $clog2(NUM_OPERANDS)+2;
	assign op_2 = instruction[op2_up:op2_down];
	parameter dest_up = $clog2(NUM_OPERANDS)+1;
	parameter dest_down = 2;
	assign dest = instruction[dest_up:dest_down];
	
	
	/*queue logic*/
	assign wrap_around = head[PTRWIDTH] ^ tail[PTRWIDTH];
	assign queue_full = (wrap_around & (head[PTRWIDTH-1:0] == tail[PTRWIDTH-1:0])); 
	assign queue_empty = !wrap_around & (head[PTRWIDTH-1:0] == tail[PTRWIDTH-1:0]);
	
	always_ff @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			head = 7'b0000000;
			tail = 7'b0000000;
			//for (iter = 0; iter < 64; iter++)
			//	queue[iter[5:0]] <= {32{1'bx}};
		end else if (valid) begin
			if (!queue_full) begin
				queue[head[PTRWIDTH-1:0]] <= {start_time, op_code, op_1, op_2, dest, 2'b00};
				head <= head + 1;
			end
		end
	end
	
	integer i;
	/* oplu logic */
	always_ff @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for(i = 0; i<NUM_OPERANDS; i++)
				oplu[i][0] = 0;
		end else if (!queue_empty) begin
			
		end
	end
	
	/* combine multiple instrucitons ^ */
	/* send stats, setup a valid */
	/* op lookup on the side */

endmodule