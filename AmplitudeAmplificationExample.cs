using System;
using System.Linq;

namespace AmplitudeAmplification
{
    public class Example
    {
        public static void Main()
        {
            // Declare an integer variable containerSize with the value 16. N = 16
            int containerSize = 16;

            // Declare an integer variable iterationCount with the value 20. Any value for illustration.
            int iterationCount = 20;

            // Declare an integer variable indexMarked with the value 3.
            // It will be used to denote a specific "special" index on which a different operation (sign inversion) will be performed.
            int indexMarked = 3;

            // Create an array to store "probabilities."
            double[] container = new double[containerSize];

            // Calculate the initial probability as 1 / (square root of containerSize (16)).
            double probability = 1.0 / Math.Sqrt(containerSize);

            // Fill all elements of the container array with the same value, probability.
            for (int i = 0; i < containerSize; i++)
                container[i] = probability;

            // Start a loop that repeats iterationCount (20) times. Variable iteration ranges from 0 to 19.
            for (int iteration = 1; iteration <= iterationCount; iteration++)
            {
                // Calculate the average value in the container array.
                // container.Sum() returns the sum of all elements, which is then divided by containerSize to get the average.
                double average = container.Sum() / containerSize;

                // For each element in the array, calculate its "reflected" value relative to the average.
                // The formula 2 * average - container[j] returns the value that is symmetrically reflected relative to the average.
                for (int i = 0; i < containerSize; i++)
                    container[i] = 2 * average - container[i];

                // Invert the sign (multiply by -1) of the array element at the index indexMarked.
                container[indexMarked] *= -1;

                Console.WriteLine($"{container[indexMarked]}");
            }

            Console.ReadLine();
        }
    }
}
