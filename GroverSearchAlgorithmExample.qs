// Import namespaces that provide useful functions for type conversion, mathematical operations, and array manipulation.
import Microsoft.Quantum.Convert.*;
import Microsoft.Quantum.Math.*;
import Microsoft.Quantum.Arrays.*;

// Entry point of the program.
@EntryPoint()
operation Main() : Unit 
{
    // Define how many qubits will be used (bitSize = 4), meaning the "state space" has a size of 2^4 = 16.
    let bitSize = 4;

    // Iterate through all possible "correct answers" (solutions) from 0 to 2^bitSize - 1 (in our case, from 0 to 15).
    for solution in 0..2^bitSize-1
    {
        // Create an "oracle" for the current solution.
        // In Q#, you can partially apply a function without specifying all arguments (using underscores _).
        let oracle = Oracle(solution, _);
        
        // Call Grover's algorithm (GroverSearch) with this oracle.
        let result = GroverSearch(bitSize, oracle);
        
        // Output the expected and the actually found results.
        Message($"Expected to find: {solution}");
        Message($"Found: {result}");
    }
}

// Grover's algorithm: accepts the number of qubits and a "phase oracle" function. 
// Returns a number that we hope matches the desired solution.
operation GroverSearch(nQubits : Int, phaseOracle : Qubit[] => Unit) : Int 
{
    // Allocate a register of nQubits qubits for computation.
    use qubits = Qubit[nQubits];
    
    // Compute the optimal number of iterations needed for Grover's algorithm,
    // using the formula ~ π / (4 * sqrt(N)), where N = 2^nQubits.
    // Floor(...) rounds down to the nearest integer, as the number of iterations must be an integer.
    let iterations = Floor(PI() / 4.0 * Sqrt(IntAsDouble(2 ^ nQubits)));

    // Initialize all qubits in an equal superposition
    // using the Hadamard operator: |0...0> -> 1/√(2^n) Σ|x>.
    ApplyToEachA(H, qubits);

    // Perform the main part of the algorithm.
    for _ in 1..iterations 
    {
        // Apply the "oracle," which "marks" the desired state by adding a phase of -1.
        phaseOracle(qubits);
        
        // Apply the amplitude amplification (reflect about the uniform superposition).
        ReflectAboutUniform(qubits);
    }

    // Measure the qubits and return the result as an integer.
    return MeasureInteger(qubits);
}

// Operation that implements reflection about the uniform superposition.
operation ReflectAboutUniform(qubits : Qubit[]) : Unit 
{
    // The `within ... apply` block indicates that operations in the `within` 
    // block will be undone (Adjoint) upon exiting the block.
    within 
    {
        // Apply the Hadamard operator (H) to all qubits, 
        // then the X operator to all qubits.
        ApplyToEachA(H, qubits);
        ApplyToEachA(X, qubits);
    } 
    apply 
    {
        // Apply a controlled Z operator,
        // where all qubits except the last are controls, 
        // and the last is the target.
        // If all controls are in the |1> state, a phase of -1 is applied.
        Controlled Z(Most(qubits), Tail(qubits));
    }
}

// "Oracle" that "marks" the desired state (solution).
// The oracle adds a phase of -1 to the state corresponding to the solution.
operation Oracle(solution : Int, qubits : Qubit[]) : Unit is Adj 
{
    // Determine the number of qubits in the register.
    let n = Length(qubits);
    
    // In the `within` block, operations will "roll back" 
    // (the Adjoint operation is applied) after exiting the block.
    within 
    {
        // Get the binary representation of the solution with a length of n.
        let markerBits = IntAsBoolArray(solution, n);

        // For each qubit, if the corresponding bit is 0, apply X (inversion),
        // to "prepare" this state for the subsequent controlled Z operation.
        for i in 0..n-1 
        {
            if not markerBits[i] 
            {
                X(qubits[i]);
            }
        }
    } 
    apply 
    {
        // Apply a controlled Z operator, where all qubits except the last are controls, 
        // and the last is the target. 
        // This "adds" a negative phase -1 only for the desired state.
        Controlled Z(Most(qubits), Tail(qubits));
    }
}
