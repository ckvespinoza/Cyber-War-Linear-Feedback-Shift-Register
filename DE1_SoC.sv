module DE1_SoC (LEDR, HEX0, HEX5, SW, KEY, CLOCK_50);
	input  logic CLOCK_50;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [9:0] LEDR;
	output logic [6:0] HEX0;
	output logic [6:0] HEX5;

	
	logic resetRound; 						//Used to reset the round once a player has won
	assign resetRound = ~KEY[1];
	logic resetGame; 							//Used to reset the game once p1count or p1count reaches 7 or 3'b111
	assign resetGame = ~KEY[2];
	logic [2:0] p1count, p2count;					//To track the wins of each player
	logic [9:1] led_on;						//declares 9 bit vector for current state of LEDs
	logic gameOver;							//need to incorporate gameOver logic since original implementation allowed players to continue after reaching LED[9] or LED[1]
	logic roundOver;
	logic [31:0] div_clk;
	logic p1_press, p2_press; 				//Synchronize and edge-detect player buttons (see button_sync)
	logic clkSelect;							//Clock selection: simulation or FPGA board
	
	logic [9:0] lfsr_out;
	logic p2_computer_press;
	logic [9:0] sw_val;
	assign sw_val = {1'b0, SW[8:0]};
	comparator_10bit comp (.A_gt_B(p2_computer_press), .A(sw_val), .B(lfsr_out));

	// For simulation
	//assign clkSelect = CLOCK_50;           
	//button_sync b0 (.clk(CLOCK_50), .async_button(~KEY[0]), .pressed_pulse(p1_press));
	//button_sync b3 (.clk(CLOCK_50), .async_button(~KEY[3]), .pressed_pulse(p2_press));

	//The following define the mini-FSM within each state of the greater FSM
//	normalLight L1 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(1'b0), .NR(led_on[2]), .lightOn(led_on[1])); 			// min-FSM for LED[1] position
//	normalLight L2 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[1]), .NR(led_on[3]), .lightOn(led_on[2])); 	// min-FSM for LED[2] position
//	normalLight L3 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[2]), .NR(led_on[4]), .lightOn(led_on[3])); 	// min-FSM for LED[3] position
//	normalLight L4 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[3]), .NR(led_on[5]), .lightOn(led_on[4])); 	// min-FSM for LED[4] position
//	centerLight C5 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[4]), .NR(led_on[6]), .lightOn(led_on[5])); 	// min-FSM for LED[5] (center)
//	normalLight R6 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[5]), .NR(led_on[7]), .lightOn(led_on[6])); 	// min-FSM for LED[6] position
//	normalLight R7 (.clk(CLOCK_50), .reset(resetRound || resetGame),  .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[6]), .NR(led_on[8]), .lightOn(led_on[7])); 	// min-FSM for LED[7] position
//	normalLight R8 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[7]), .NR(led_on[9]), .lightOn(led_on[8])); 	// min-FSM for LED[8] position
//	normalLight R9 (.clk(CLOCK_50), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_press & ~roundOver), .NL(led_on[8]), .NR(1'b0), .lightOn(led_on[9])); 			// min-FSM for LED[9] position
	
	// For board
	parameter whichClock = 15; 			// 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50),.reset(resetRound),.divided_clocks(div_clk));
	assign clkSelect = div_clk[whichClock];
	button_sync b0 (.clk(clkSelect), .async_button(~KEY[0]), .pressed_pulse(p1_press));
	button_sync b3 (.clk(clkSelect), .async_button(~KEY[3]), .pressed_pulse(p2_press));
	
	lfsr10_xnor lfsr (.clk(clkSelect), .reset(resetRound || resetGame), .rnd(lfsr_out));

	//The following define the mini-FSM within each state of the greater FSM
	normalLight L1 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(1'b0), .NR(led_on[2]), .lightOn(led_on[1])); 		// min-FSM for LED[1] position
	normalLight L2 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[1]), .NR(led_on[3]), .lightOn(led_on[2])); 	// min-FSM for LED[2] position
	normalLight L3 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[2]), .NR(led_on[4]), .lightOn(led_on[3])); 	// min-FSM for LED[3] position
	normalLight L4 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[3]), .NR(led_on[5]), .lightOn(led_on[4])); 	// min-FSM for LED[4] position
	centerLight C5 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[4]), .NR(led_on[6]), .lightOn(led_on[5])); 	// min-FSM for LED[5] (center)
	normalLight R6 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[5]), .NR(led_on[7]), .lightOn(led_on[6])); 	// min-FSM for LED[6] position
	normalLight R7 (.clk(clkSelect), .reset(resetRound || resetGame),  .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[6]), .NR(led_on[8]), .lightOn(led_on[7])); // min-FSM for LED[7] position
	normalLight R8 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[7]), .NR(led_on[9]), .lightOn(led_on[8])); 	// min-FSM for LED[8] position
	normalLight R9 (.clk(clkSelect), .reset(resetRound || resetGame), .L(p1_press & ~roundOver), .R(p2_computer_press & ~roundOver), .NL(led_on[8]), .NR(1'b0), .lightOn(led_on[9])); 		// min-FSM for LED[9] position
 
	always_ff @(posedge clkSelect or posedge resetGame) begin
		if (resetGame) begin																			//if reset game KEY[2] is selected, reset all variables/counters
			gameOver  <= 1'b0;
			roundOver <= 1'b0;
			p1count   <= 3'b000;
			p2count   <= 3'b000;
		end
		else begin
			if (resetRound && ~gameOver) begin													//If the reset round KEY[1] is selected, and the game is not over, then reset the round (use case: when LED is at 1 or 9)
				roundOver <= 1'b0;
			end
			else begin
				if (!roundOver && led_on[9] && (p2count < 3'b111)) begin					//If player 2 wins AND they have less than 7 total wins, then round is over AND add 1 point to player 2
					roundOver <= 1'b1;
					p2count   <= p2count + 3'b001;
				end
				if (!roundOver && led_on[1] && (p1count < 3'b111)) begin					//If player 1 wins AND they have less than 7 total wins, then round is over AND add 1 point to player 1
					roundOver <= 1'b1;
					p1count   <= p1count + + 3'b001;
				end
				if ((p1count == 3'b111) || (p2count == 3'b111)) begin 					//If player 1 or player 2 have 7 total wins, them game is over
					gameOver <= 1'b1;
				end
			end
		end
	end

	assign LEDR[9:1] = led_on[9:1];
	assign LEDR[0]   = 1'b0;

	//scoreboard for each player
	always_comb begin
		case(p1count)
			3'b000: HEX0=7'b1000000;	// shows “0”
			3'b001: HEX0=7'b1111001;	// shows “1”
			3'b010: HEX0=7'b0100100;	// shows “2”
			3'b011: HEX0=7'b0110000;	// shows “3”
			3'b100: HEX0=7'b0011001;	// shows “4”
			3'b101: HEX0=7'b0010010;	// shows “5”
			3'b110: HEX0=7'b0000010;	// shows “6”
			3'b111: HEX0=7'b1111000;	// shows “7”
			default: HEX0 = 7'b1000000; // shows "0"
		endcase
		case(p2count)
			3'b000: HEX5=7'b1000000;	// shows “0”
			3'b001: HEX5=7'b1111001;	// shows “1”
			3'b010: HEX5=7'b0100100;	// shows “2”
			3'b011: HEX5=7'b0110000;	// shows “3”
			3'b100: HEX5=7'b0011001;	// shows “4”
			3'b101: HEX5=7'b0010010;	// shows “5”
			3'b110: HEX5=7'b0000010;	// shows “6”
			3'b111: HEX5=7'b1111000;	// shows “7”
			default: HEX5 = 7'b1000000; // shows "0"
		endcase
	end
endmodule

//module DE1_SoC_testbench();
//
//    // Declare signals
//    logic CLOCK_50;
//    logic [3:0] KEY;
//    logic [9:0] SW;
//    logic [9:0] LEDR;
//    logic [6:0] HEX0;
//
//    // Instantiate the DUT (Device Under Test)
//    DE1_SoC dut (
//        .CLOCK_50(CLOCK_50),
//        .KEY(KEY),
//        .SW(SW),
//        .LEDR(LEDR),
//        .HEX0(HEX0)
//    );
//
//    // Clock generation: 50MHz
//    parameter CLOCK_PERIOD = 20; // 20ns period = 50MHz
//    initial CLOCK_50 = 0;
//    always #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
//
//    // Test stimulus
//    initial begin
//        // Initialize inputs
//        KEY = 4'b1111;   // all keys unpressed (high)
//        SW  = 10'b0;
//
//        // Apply reset using SW[9]
//        SW[9] = 1'b1; repeat(2) @(posedge CLOCK_50); // reset active
//        SW[9] = 1'b0; repeat(2) @(posedge CLOCK_50); // release reset
//
//        // Player 1 presses KEY[0] to move light right
//        KEY[0] = 1'b0; repeat(2) @(posedge CLOCK_50); // press
//        KEY[0] = 1'b1; repeat(2) @(posedge CLOCK_50); // release
//
//        // Player 2 presses KEY[3] to move light left
//        KEY[3] = 1'b0; repeat(2) @(posedge CLOCK_50); // press
//        KEY[3] = 1'b1; repeat(2) @(posedge CLOCK_50); // release
//
//        // Simulate several turns
//        repeat (5) begin
//            // Player 1 move
//            KEY[0] = 1'b0; @(posedge CLOCK_50);
//            KEY[0] = 1'b1; @(posedge CLOCK_50);
//            // Player 2 move
//            KEY[3] = 1'b0; @(posedge CLOCK_50);
//            KEY[3] = 1'b1; @(posedge CLOCK_50);
//        end
//
//        // Test game over: move light to leftmost
//        repeat(10) begin
//            KEY[3] = 1'b0; @(posedge CLOCK_50);
//            KEY[3] = 1'b1; @(posedge CLOCK_50);
//        end
//
//        // Finish simulation
//        $stop;
//    end
//
//endmodule
