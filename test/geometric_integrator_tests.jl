using GeometricBase
using Test


struct MyIntegrator <: GeometricIntegrator end

int = MyIntegrator()

@test !isGeometricIntegrator(int)

function GeometricBase.integrate!(::MyIntegrator) end

@test isGeometricIntegrator(int)
