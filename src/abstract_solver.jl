
export AbstractSolver, isAbstractSolver
export SolverMethod, isSolverMethod
export NoSolver

abstract type AbstractSolver end

isAbstractSolver(::Any) = false
isAbstractSolver(::AbstractSolver) = true


abstract type SolverMethod <: AbstractMethod end

isSolverMethod(::Any) = false
isSolverMethod(::SolverMethod) = true


struct NoSolver <: SolverMethod end
