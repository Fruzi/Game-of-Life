# Game-of-Life
Simulating Conway's Game of Life using x86 assembly (the original game - https://en.wikipedia.org/wiki/Conway's_Game_of_Life).
The program begins by reading the initial state configuration of the organisms managed by the co-routines, the number of generations to run, and the printing frequency (in steps).
The program initializes an appropriate mechanism, and control is then passed to a scheduler co-routine which decides the appropriate scheduling for the co-routines. The states of the organisms managed by the co-routines, where co-routine is responsible for one organism, cell in the array. Every organism is a cell in 2 a dimensional array, so it has 8 neighbors (diagonal cells also count as neighbors). Life board is cyclic, it means that each cell in the last column has neighbors from the first column and vice versa. Each cell in the last row has neighbors from the first row and vice versa.

The cell organisms change according to the following rules: if the cell is currently alive, then it will remain alive in the next generation if and only if exactly 2 or 3 of its neighbors are currently alive. Otherwise it dies. A dead cell remains dead in the next generation, unless it has exactly 3 living neighbors, in which case we say that an organism is born here.

A specialized co-routine called the printer prints the organism states for all the cells as a two dimensional array.

# Running the program
\> ass3 \<filename\> \<length\> \<width\> \<t\> \<k\><br />
\> ass3 -d \<filename\> \<length\> \<width\> \<t\> \<k\> <br />
where:<br />
-d (debug) option.<br />
If used, prints at the beginning of the program the input, in a manner that Printer co-routine does, and the values of the command line arguments.

Example:
\>ass3 inputExample.txt 4 6 10 3<br />
length=4<br />
width=6<br />
number of generations=10<br />
print frequency=3<br />
0   0   1   0   0   1  
1   1   0   0   0   1  
0   0   0   0   0   0  
1   1   1   0   0   1  

# Initial Configuration
filename:
The name of the initial state file. The file include just space ' '(dead) , '1'(alive) and newline character after every width characters.

Width and length:
The dimensions of the co-routine array. Maximum value of length and width is 100. This file determines organisms initial states. 

Number of generations:
The fourth command-line argument, t, is the number of generations for the scheduler to iterate.

Printing frequency
Next, k, is the number of steps to be done by the scheduler between calls to the printer, i.e. after each k "resumes" of cell co-routines, there needs to be one to the printer.
