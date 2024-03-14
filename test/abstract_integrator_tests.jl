using GeometricBase
using Test


struct TestIntegrator <: AbstractIntegrator end

int = TestIntegrator()

@test !isAbstractIntegrator(int)

function GeometricBase.integrate!(::TestIntegrator) end

@test isAbstractIntegrator(int)
@test !isAbstractIntegrator(42)
