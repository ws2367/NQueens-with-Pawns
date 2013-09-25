NQueens With Pawns Problem
================================================================
Wen Hsiang Shaw ws2367@columbia.edu

Language: 
X10 http://x10lang.org/, developed by IBM
It is very similar to Java(Java backend), except the val, which is just a constant variable
and the parallel statements, such as async, and finish. async is to spawn a worker. finish is
the synchronization of workers.

Source:
Parallel Programming course, COMS 4130, Fall 2012, Columbia University, taught by
Prof. Martha Kim and Prof. Vijay Saraswat.

Compilation instruction:
With X10 compiler installed, execute ./doit.sh

Files:
All of the required files and test harness are included in the tarball.
src/: Directory for source files. See Solver.x10 for the method I implemented. All the
other files are provided by TA.

Problem Description:
NQueens problem is to place N queens on an NxN board such that none of the queens
can attack each other. (Ref: http://en.wikipedia.org/wiki/Eight_queens_puzzle ) When two
queens are in the same row, same column or same diagonal, the two queens are attacking
each other. Instead of regular NQueens, zero or more fixedposition pawns which can
block queens are on the board. By blocking, it means that when a pawn is in between the
two queens, the two queens cannot attack each other. Given a board size and set of
pawns, the solver I implemented return the number of viable queen arrangements.

Challenge and solution:

Serial version
I would like to use this code example as the demonstration of my ability to think through to
solve an unknown problem and a parallel program. As you may know, it is hard to find a
existing good algorithm on the internet to solve NQueens with pawns problem(At least I
tried to found but failed). One of the most common algorithms for regular NQueens is
backtrace depth first search, which constructs the search tree by considering one row of
the board at a time, eliminating most nonsolution board positions at a very early stage in
their construction.
The difficulty comes with the pawns. For N queens with pawns, such limitation that exactly
one queen in a row does not exist. I came up with the idea that involves two levels of
backtrace search. I first divide the board into segments. A segment consists of some
positions s.t. all the positions in it must be dependent, that is, only one or zero queen can
be placed in a segment. None of positions is placed twice in different segments. The
divider of segments is either a pawn or endofline.
The way I do segmentation is either by row or by column. Take the one which results in 
smaller number of segments, K. Construct the first level of backtrace search, which is basically 
the search tree of choosing N from K. Then following each path of search tree, search the 
positions on the K segments in backtrace depth first sense.

Parallel version
The parallelism of this algorithm is very difficult since the search tree is extremely
unbalanced and unpredictable. The naive way to do this is to assign subtrees to threads
uniformly. However, a good parallelism split the work to each thread evenly. There are
some theoretical ways to predict the tree, but failed to be practical. I came up with some
heuristic methods. For example, I tried to predict the workload of a subtree by the
multiplication of the length of segment of the rootnode and the workload of its childnodes.
However, I found it illperformed.
In the final version I use a threshold, CUTOFF_LEVEL, as a stopping point to spawn more async’s.

if length of segment * (N - current level) > CUTOFF_LEVEL

Then it stops to spawn async’s.

As for evaluation, for 10x10 boards with two pawns on (2,3) and (4,5), my solver takes
around 55 ms, which is quite comparable to the best few in class. The engineers in
KLATencor(http://www.klatencor.com/) are evaluating our result with massive
benchmarks. It is still ongoing and the result should come out soon.

Future work:
I did come up with some ideas after submitting it. For example, Monitor, a type of data
structure can be used to allocate the work dynamically, much similar to what a scheduler
does, in a higher level.