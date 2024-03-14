using GeometricBase
using Test


struct TestSolver <: AbstractSolver end

@test isAbstractSolver(TestSolver())
@test !isAbstractSolver(42)
