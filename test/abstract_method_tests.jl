using GeometricBase
using Test


struct MyMethod <: AbstractMethod end

method = MyMethod()

@test !isAbstractMethod(method)

GeometricBase.isexplicit(method::MyMethod) = true
GeometricBase.isimplicit(method::MyMethod) = false
GeometricBase.issymmetric(method::MyMethod) = false
GeometricBase.issymplectic(method::MyMethod) = false
GeometricBase.isenergypreserving(method::MyMethod) = false
GeometricBase.isstifflyaccurate(method::MyMethod) = false

GeometricBase.order(::Union{MyMethod, Type{<:MyMethod}}) = 0
GeometricBase.name(::Union{MyMethod, Type{<:MyMethod}}) = "My Method"
GeometricBase.description(::Union{MyMethod, Type{<:MyMethod}}) = "Test Method"
GeometricBase.reference(::Union{MyMethod, Type{<:MyMethod}}) = "n/a"

@test isAbstractMethod(method)
