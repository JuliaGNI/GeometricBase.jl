
export GeometricMethod, isGeometricMethod


abstract type GeometricMethod end

Base.parent(::GeometricMethod) = nothing

isexplicit(::GeometricMethod) = missing
isimplicit(::GeometricMethod) = missing
issymmetric(::GeometricMethod) = missing
issymplectic(::GeometricMethod) = missing
isenergypreserving(::GeometricMethod) = missing
isstifflyaccurate(::GeometricMethod) = missing

order(::Union{GeometricMethod, Type{<:GeometricMethod}}) = missing
name(::Union{GeometricMethod, Type{<:GeometricMethod}}) = missing
description(::Union{GeometricMethod, Type{<:GeometricMethod}}) = missing
reference(::Union{GeometricMethod, Type{<:GeometricMethod}}) = missing


function isGeometricMethod(method::GeometricMethod)
    isexplicit(method) === missing && return false
    isimplicit(method) === missing && return false
    issymmetric(method) === missing && return false
    issymplectic(method) === missing && return false
    isenergypreserving(method) === missing && return false
    isstifflyaccurate(method) === missing && return false
    order(method) === missing && return false
    name(method) === missing && return false
    description(method) === missing && return false
    reference(method) === missing && return false
    return true
end
