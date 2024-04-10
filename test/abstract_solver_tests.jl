using GeometricBase
using Test


struct TestSolver <: AbstractSolver end

@test isAbstractSolver(TestSolver())
@test !isAbstractSolver(42)


struct TestSolverMethod <: SolverMethod end

@test isSolverMethod(TestSolverMethod())
@test !isSolverMethod(42)
