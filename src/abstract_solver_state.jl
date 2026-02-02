
export AbstractSolverState, isAbstractSolverState, SolverState

"""
    AbstractSolverState

The state is used in solvers and optimizers to translate information about previous solver/optimization steps to successive iterations.
"""
abstract type AbstractSolverState end

isAbstractSolverState(::Any) = false
isAbstractSolverState(::AbstractSolverState) = true

"""
    SolverState

This method returns a subtype of `AbstractSolverState` according to the `SolverMethod` and additional, required parameters that is passed to it.
"""
function SolverState end
