
export AbstractSolverState, isAbstractSolverState

"""
    AbstractSolverState

The state is used in solvers and optimizers to translate information about previous solver/optimization steps to successive iterations.
"""
abstract type AbstractSolverState end

isAbstractSolverState(::Any) = false
isAbstractSolverState(::AbstractSolverState) = true