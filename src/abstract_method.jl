
export AbstractMethod, isAbstractMethod


abstract type AbstractMethod end

Base.parent(::AbstractMethod) = nothing

isexplicit(::AbstractMethod) = missing
isimplicit(::AbstractMethod) = missing
issymmetric(::AbstractMethod) = missing
issymplectic(::AbstractMethod) = missing
isenergypreserving(::AbstractMethod) = missing
isstifflyaccurate(::AbstractMethod) = missing

order(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
name(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
description(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
reference(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing


function isAbstractMethod(method::AbstractMethod)
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
