# Cyber War - Linear Feedback Shift Register
Continuation of Tug of War but instead replaces player 2 with a randomizer (created by taking the 7th and 10th taps of a 10-bit LFSR to XNOR into an input and using a comparator with the resulting 10-bit register with manually selected SW[8:0])

3.1 CyberWar
1. Add Point Counters
First off, take your lab2-3 and replace the “winner” system with counters. Specifically, develop a 3-bit counter (holds values 0..7). It starts at 0, and whenever a “win” comes in, it increments its current value by 1. Note that we assume once one player gets to 7 the game is over, so it doesn’t matter what happens when a player with 7 points gets one more.

Hint: use RTL (abstracted) principles for this design to make it easier

Now, alter your lab2-3 so that there is a counter for each player, which drives a per-player 7- segment display with the current score for that player. Whenever someone wins, you increment the appropriate player’s score, then restart the game (i.e. automatically reset the playfield). Resetting the entire game will reset the playfield and score, while winning only resets the playfield.

2. Add an LFSR
To build a cyber-player, you must create a random number generator to simulate button presses. In hardware, the simplest way to do this is generally an LFSR (linear feedback shift register). It consists of a set of N D-flip-flops (DFF1…DFFN), where the output of DFFi is the input of DFFi+1. The magic comes in on the input of DFF1. It is the XNOR of 2 or more outputs of the DFF. By picking the bits to XNOR carefully, you get an FSM that goes through a fairly random pattern, but with very simple hardware (note that these LFSRs never enter the all-1s state, but reach all other states). Figures 1 and 2 below provide two examples

<img width="1310" height="378" alt="image" src="https://github.com/user-attachments/assets/82fa22a0-f5e4-4635-8362-d9d526dbc4b6" />

First, draw the state diagram for these two circuits. It will show every possible state for the machine (8 for the 3-bit, 16 for the 4-bit), with arrows showing the next state they enter after that state.

Next, create a 10-bit LFSR in Quartus and simulate it. Use the list of XNOR taps provided in Appendix B. Do NOT invent your own, as most choices do not produce effective results.

3. Comparator
Develop a 10-bit comparator. The unit takes in two unsigned 10-bit numbers, called A and B, and returns TRUE if A>B, FALSE otherwise. You can think about this as a subtraction problem, or just by considering the individual bits of the number themselves.

4. CyberPlayer
We now have most of the components to implement a tunable cyber-player. For this implementation of a cyber-player, the left button presses will now be controlled by the circuits you write, while the right button presses will still be controlled by the user.
First, let’s slow things down so you have a chance – run your entire Tug of War game off of the clock divider’s divided_clocks[15] (about 768 Hz). To generate the computer’s button presses, compare the LFSR output (a value from 0 to 1023) to the value on SW[8:0] (a value from 0 to 511) – you can extend the SW[8:0] with a 0 at the top bit to make it a 10-bit unsigned value. If the SW value is greater than the LFSR value, consider this a computer button-press. You can speed up or slow down the system by simply playing with the user switches, to see how fast you can go. If the clock is too fast, adjust to a different divided_clock output (applied to the ENTIRE design).

Remember to change the system clock input back to CLOCK_50 during simulation.

<img width="673" height="767" alt="image" src="https://github.com/user-attachments/assets/a2327b51-0985-4e8f-895d-8493dc1daa2e" />
