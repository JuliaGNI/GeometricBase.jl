
export AbstractSolverState, isAbstractSolverState, SolverState

"""
    AbstractSolverState

The state is used in solvers and optimizers to translate information about previous solver/optimization steps to successive iterations.
"""
abstract type AbstractSolverState end

isAbstractSolverState(::Any) = false
isAbstractSolverState(::AbstractSolverState) = true

"""
`NullSolverState` is an empty struct that is used to indicate than a solver does not store a state.
"""
struct NullSolverState <: AbstractSolverState end


"""
    SolverState(::Union{<:AbstractSolver,<:SolverMethod}, args...; kwargs...)

This method returns a subtype of `AbstractSolverState` according to the `AbstractSolver` or `SolverMethod` that is passed to it.
By default, i.e., if no such method is defined for a given solver, it returns `NullSolverState`.
"""
SolverState(::Union{<:AbstractSolver,<:SolverMethod}, args...; kwargs...) = NullSolverState()
