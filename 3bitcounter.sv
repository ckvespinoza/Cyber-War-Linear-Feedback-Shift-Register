module 3bitcounter (count, reset, clk);
	input logic clk;
	input logic reset;
	output logic [2:0] count;
	
	always_ff @(posedge clk or negedge reset)
		if (!reset) //reset is always true until pressed
			count <= 3'b000;
		else
			count <= count + 1;
	end
end module