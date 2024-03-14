using GeometricBase
using Test


struct TestProblem <: AbstractProblem end

problem = TestProblem()

# @test !isAbstractProblem(problem)

@test isAbstractProblem(problem)
@test !isAbstractProblem(42)
