using GeometricBase
using Test


struct TestMethod <: AbstractMethod end

method = TestMethod()

@test parent(method) === nothing

@test ismissing(GeometricBase.isexplicit(method))
@test ismissing(GeometricBase.isimplicit(method))
@test ismissing(GeometricBase.issymmetric(method))
@test ismissing(GeometricBase.issymplectic(method))
@test ismissing(GeometricBase.isenergypreserving(method))
@test ismissing(GeometricBase.isstifflyaccurate(method))
@test ismissing(GeometricBase.order(method))
@test ismissing(GeometricBase.name(method))
@test ismissing(GeometricBase.description(method))
@test ismissing(GeometricBase.reference(method))

@test !isAbstractMethod(method)

GeometricBase.isexplicit(method::TestMethod) = true
GeometricBase.isimplicit(method::TestMethod) = false
GeometricBase.issymmetric(method::TestMethod) = false
GeometricBase.issymplectic(method::TestMethod) = false
GeometricBase.isenergypreserving(method::TestMethod) = false
GeometricBase.isstifflyaccurate(method::TestMethod) = false

GeometricBase.order(::Union{TestMethod, Type{<:TestMethod}}) = 0
GeometricBase.name(::Union{TestMethod, Type{<:TestMethod}}) = "My Method"
GeometricBase.description(::Union{TestMethod, Type{<:TestMethod}}) = "Test Method"
GeometricBase.reference(::Union{TestMethod, Type{<:TestMethod}}) = "n/a"

@test isAbstractMethod(method)
@test !isAbstractMethod(42)
