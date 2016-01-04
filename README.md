# ParallelGraphs
ParallelGraphs.jl is a framework for Massive Graph Analysis built on [ComputeFramework.jl](https://github.com/shashi/ComputeFramework.jl). ParallelGraphs.jl implements the Bulk Synchronous Parallel Model for running graph algorithms.

## Requirements
- ComputeFramework.jl
- LightGraphs.jl 

## Concept
Algorithms that adhere to the Bulk Synchronous Parallel Model have the following stages:

### Partitioning 
The input graph(object or file) is processed, and the vertices are partitioned into disjoint ranges. The partioning may be random or heuristic-enabled.

### Loading
The range of vertices are communicated to the available worker processes and the data accompanying these vertices (Adjacency lists, Labels etc) are migrated to the worker processes. 

### Computing
The compute phase consists of multiple iterations of synchronized super-steps. The inter-process communication takes place through message passing. 

Each vertex in the graph is assigned an active attribute. Usually a few user-specified seed vertices will start-off activated. As the algorithm proceeds, other vertices are acitvated and deactivated. When all vertices in the graph are in the deactivated state, the algorithm terminates. 

The super-steps often include:
- Message Processing: Process the messages received in the previous iteration.
- Vertex Visits: The input vertex visitor function is applied on all local active vertices.
- Message Passing: The messages generated during the vertex visits are dispatched to their destination worker processes.

All processes must finish the current iteration before the next iteration can start. This synchronization is required to ensure the correctness of algorithms.

### Consolidation
The distributed results are then gathered back onto the main process and a result is generated.


## Example Usage:
`examples/bsp.jl` contains a basic breadth first search demonstration for datasets of varying sizes.

