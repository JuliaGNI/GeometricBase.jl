using GeometricBase
using Test


struct MyIntegrator <: AbstractIntegrator end

int = MyIntegrator()

@test !isAbstractIntegrator(int)

function GeometricBase.integrate!(::MyIntegrator) end

@test isAbstractIntegrator(int)
