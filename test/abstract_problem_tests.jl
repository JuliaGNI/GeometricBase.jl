using GeometricBase
using Test


struct MyProblem <: AbstractProblem end

problem = MyProblem()

# @test !isAbstractProblem(problem)

@test isAbstractProblem(problem)
