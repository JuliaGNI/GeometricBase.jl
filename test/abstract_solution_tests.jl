using GeometricBase
using Test

struct TestSolution <: AbstractSolution{Float64, Float64} end

@test !isAbstractSolution(TestSolution())
@test !isAbstractSolution(42)

Base.step(sol::TestSolution) = error("step() not implemented for ", typeof(sol))
GeometricBase.ntime(sol::TestSolution) = error("ntime() not implemented for ", typeof(sol))
function GeometricBase.nstore(sol::TestSolution)
    error("nstore() not implemented for ", typeof(sol))
end
function GeometricBase.timesteps(sol::TestSolution)
    error("timesteps() not implemented for ", typeof(sol))
end
function GeometricBase.eachtimestep(sol::TestSolution)
    error("eachtimestep() not implemented for ", typeof(sol))
end

@test isAbstractSolution(TestSolution())
