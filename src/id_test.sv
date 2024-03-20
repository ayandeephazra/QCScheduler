module id_test();

	reg clk;
	reg rst_n;
	
	reg [55:0] instr;
	reg valid;
	
	wire queue_full;
	wire queue_empty;
	wire wrap_around;

	integer i;
	
	id #(/*DEPTH*/64, /*NUM_FPGA*/50, /*NUM_QUBIT_PER_FPGA*/64) id0(
		.clk(clk),
		.rst_n(rst_n),
		.instruction(instr),						// instr to send
		.valid(valid),								// valid is high for 1 cycle when new instruction is available
		.queue_full(queue_full),					// if high, then do not overwrite data at instruction
		.queue_empty(queue_empty),					// if high, then queue empty
		.wrap_around(wrap_around)					// wraparound for internal use
	);
	
	task send_instr(input [55:0] data);
		@(posedge clk);
		instr = data;
		valid = 1;
	endtask
	
	initial begin
		clk = 0;
		rst_n = 0;
		valid = 0;
		
		@(posedge clk);
		rst_n = 1;
		
		for (i = 0; i< 16; i++)
			send_instr(56'hDDDDDDdddddddd);
		for (i = 16; i< 32; i++)
			send_instr(56'hcccccccccccccc);
		for (i = 32; i< 48; i++)
			send_instr(56'hbbbbbbbbbbbbbb);
		for (i = 48; i< 64; i++)
			send_instr(56'haaaaaaaaaaaaaa);
		send_instr(32'h0);
		@(posedge clk);
		valid = 0;
		
		
		repeat (30000) @ (posedge clk);
		
		$stop();
	end
	
	always
		#5 clk = ~clk;
endmodule
