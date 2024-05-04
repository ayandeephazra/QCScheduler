module sched_test();

	reg clk;
	reg rst_n;

	integer i, j, k;
	
	parameter DEPTH = 64, NUM_FPGA = 64, NUM_QUBIT_PER_FPGA = 64, 
				NUM_INSTRS = 100, NUM_REGS_L1 = 50, NUM_REGS_L2 = 50;
	
	reg [0:NUM_INSTRS-1] [3*$clog2(NUM_FPGA*NUM_QUBIT_PER_FPGA)+21:0] instr;
	reg [NUM_INSTRS-1:0] status;
	reg [$clog2(NUM_INSTRS)-1:0] ireg_index;		
	
	scheduler #(/*DEPTH*/ 64, /*NUM_FPGA*/ 64, /*NUM_QUBIT_PER_FPGA*/ 64, /*NUM_INSTRS*/ 100, 
					/*NUM_REGS_L1*/ 50, /*NUM_REGS_L2*/ 50) isc0(
		.clk(clk),
		.rst_n(rst_n),
		.instruction(instr),	
		.status(status),
		.ireg_index(ireg_index)					
	);

	initial begin
		clk = 0;
		rst_n = 0;

		@(posedge clk);
		rst_n = 1;

		for (i = 0; i< 35; i++)
			instr[i]  = {54'h1DDDDDdddd0001, 4'b1000};
		for (i = 35; i< 50; i++)
			instr[i]  = {54'h0ccccccccc0005, 4'b1000};
		for (i = 50; i< 75; i++)
			instr[i]  = {54'h3bbbbbbbbb0009, 4'b1000};
		for (i = 75; i< 100; i++)
			instr[i]  = {54'h2aaaaaaaaa000c, 4'b1000};

		@(posedge clk);

		
		repeat (30000) @ (posedge clk);
		
		$stop();
	end
	
	always
		#5 clk = ~clk;
endmodule
