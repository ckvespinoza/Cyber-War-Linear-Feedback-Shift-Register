module comparator_10bit (A_gt_B, A, B);
	input  logic [9:0] A;
	input  logic [9:0] B;
	output logic A_gt_B;

    //Combinational comparison using subtraction assuming that the bits will be unsigned (would not work for signed)
    assign A_gt_B = (A > B); //true if A is greater than B

endmodule