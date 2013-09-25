import x10.util.Timer;

/**
 * Class with the main method.
 *
 * The main method will call the provided Solver.solve() method
 * for each of the benchmark inputs.  The value returned from solve()
 * will be compared against the expected value and the time required
 * by solve() will be compared to a baseline time.  The final score
 * will be the geometric mean of the speedups for each benchmark input.
 *
 * As an implementation detail, the solve() method will be called three
 * times for each benchmark input and the median time will be used when
 * computing the geometric mean speedup.
 */
public class Main
{
    /**
     * This struct holds one benchmark input, along with the expected value
     * for that input and the benchmark time (in milliseconds).
     */
    static struct Inputs
    {
        val size         : int;                     // Size of the board along one side
        val pawns        : Array[Square]{rank==1};  // Array of pawns.  The array can be of zero length
        val solutions    : int;                     // Expected/correct number of solutions
        val baseline_time: double;                  // Time in milliseconds

        // Time should not be less than one ...
        def this(size: int, pawns: Array[Square]{rank==1}, solutions: int, time: double)
        {
            this.size          = size;
            this.pawns         = pawns;
            this.solutions     = solutions;
            this.baseline_time = time;
        }
    }


    static val BENCHMARK_INPUT_COUNT = 3;          // How many benchmark input cases do we have?

    public static def main(Array[String])
    {
        val INPUTS = new Array[Inputs](0..(BENCHMARK_INPUT_COUNT - 1));
        INPUTS(0) = Inputs(8, new Array[Square](6..5), 92, 1000.0f);    // No pawns (X10 idiom for zero length array).
        INPUTS(1) = Inputs(9, new Array[Square](0..0), 324, 2000.0f);    // One pawn, default value location.
            val SQUARE_ARRAY_2 = new Array[Square](0..1);
            SQUARE_ARRAY_2(0) = Square(2,3); 
            SQUARE_ARRAY_2(1) = Square(4,5); 
        INPUTS(2) = Inputs(10, SQUARE_ARRAY_2, 42556, 2000.0f);    // One pawn, default value location.


        Console.OUT.println();
        try
        {
            var prod: double = 1.0;
            for (index in INPUTS)
                prod *= run_one_test(INPUTS(index));
            val geom_mean = Math.pow(prod, 1.0/BENCHMARK_INPUT_COUNT);

            val geom_mean_String: String = String.format("%.2f", new Array[Any](1, geom_mean));
            Console.OUT.println();
            Console.OUT.println("Geometric Mean Speedup: " + geom_mean_String);
        }
        catch (Exception)
        {
            Console.OUT.println();
            Console.OUT.println("Geometric Mean Speedup: " + "None ... answer was wrong.");
        }
    }


    /**
     * Helper function to run one benchmark test, validate the
     * answer, measure the times and select the median run time
     * for this one benchmark test.
     */
    static def run_one_test(input: Inputs) : double
    {
        val speedups = new Array[double](0..2);             // Run three times ... we'll take the median value

        for (index in speedups)
        {
            // Make a new Solver to prevent caching :-)
            //
            var solver: Solver = new Solver();        

            val start     = Timer.milliTime();
            val solutions = solver.solve(input.size, input.pawns);
            val end       = Timer.milliTime();
            var time_in_millis: long = end - start;

            if (solutions != input.solutions)
            {
                Console.OUT.println("\tComputed answer: INCORRECT!!!!!!!!!!!!!!!!!!!!!");
                throw new Exception("Wrong answer");
            }

            // We don't want to blow up for super-fast times.
            // We will thus ensure that the times are non-zero.
            //
            if (time_in_millis == 0)
                time_in_millis = 1;

            speedups(index) = input.baseline_time/time_in_millis;
        }

        val med = median(speedups(0), speedups(1), speedups(2));

        val speedup_0_String: String = String.format("%.2f", new Array[Any](1, speedups(0)));
        val speedup_1_String: String = String.format("%.2f", new Array[Any](1, speedups(1)));
        val speedup_2_String: String = String.format("%.2f", new Array[Any](1, speedups(2)));
        val median_speedup_String: String = String.format("%.2f", new Array[Any](1, med));

        // We don't need to do this, but it is nice to be able to see the times
        // of each of the three runs.  If something is super-weird, a human might
        // notice ...
        Console.OUT.println("    Speedups: [" + speedup_0_String + ", "
                                              + speedup_1_String + ", "
                                              + speedup_2_String + "] ... median: "
                                              + median_speedup_String);
        return med;      // Return the median speedup
    }

    /**
     * Return the median of three values.
     */
    static def median(v1: double, v2: double, v3: double)
    {
        if (v1 > v2)
        {
            if (v3 > v1)            // v3 > v1 > v2
                return v1;
            else if (v3 > v2)       // v1 > v2 > v1
                return v3;
            else                    // v1 > v2 > v1
                return v2;
        }
        else                        // v1 <= v2
        {
            if (v3 > v2)            // v3 > v2 > v1
                return v2;
            else if (v3 > v1)       // v2 > v3 > v1
                return v3;
            else                    // v2 > v1 > v3
                return v1;
        }
    }
}
