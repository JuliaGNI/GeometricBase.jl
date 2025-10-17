
import Base: axes, copy!, eachindex, getindex, parent, setindex!, size, zero

export TimeVariable, StateVariable, VectorfieldVariable, AlgebraicVariable
export Increment, StateWithError, StateVariableWithError, StateVector

export isperiodic, parenttype, verifyrange
export add!, reset!, periodic, value, vectorfield, zerovector


"""
`AbstractVariable{T,N}` is a wrapper around a `AbstractArray{T,N}` that provides context for the nature of the variable.
"""
abstract type AbstractVariable{DT,N} <: AbstractArray{DT,N} end

axes(a::AbstractVariable, ind...) = axes(parent(a), ind...)
size(a::AbstractVariable, ind...) = size(parent(a), ind...)
eachindex(a::AbstractVariable) = eachindex(parent(a))
getindex(a::AbstractVariable, ind...) = getindex(parent(a), ind...)
setindex!(a::AbstractVariable, x, ind...) = setindex!(parent(a), x, ind...)
zero(a::AST) where {AST<:AbstractVariable} = AST(zero(parent(a)))

# ...

Base.:(==)(x::AV, y::AV) where {AV<:AbstractVariable} = parent(x) == parent(y)

"""
`AbstractScalarVariable{T}` is a wrapper around a zero-dimensional `AbstractArray{T,0}` that provides context for the nature of the variable, e.g., time.
"""
abstract type AbstractScalarVariable{DT} <: AbstractVariable{DT,0} end

Base.:(==)(x::AbstractScalarVariable, y::Number) = value(x) == y
Base.:(==)(x::Number, y::AbstractScalarVariable) = y == x

"""
`AbstractStateVariable{T,N,AT}` is a wrapper around a `AT <: AbstractArray{T,N}` that provides context for the nature of the variable, e.g., a state or a vector field.
"""
abstract type AbstractStateVariable{DT,N,AT} <: AbstractVariable{DT,N} end

parenttype(::AbstractStateVariable{DT,N,AT}) where {DT,N,AT} = AT

function copy!(dst::AbstractStateVariable{DT,N,AT}, src::AT) where {DT,N,AT<:AbstractArray{DT,N}}
    @assert axes(dst) == axes(src)
    copy!(parent(dst), src)
end

# This is necessarry to disambiguate `copy!(dst::AbstractVector, src::AbstractVector)`
function copy!(dst::AbstractStateVariable{DT,1,AT}, src::AT) where {DT,AT<:AbstractVector{DT}}
    @assert axes(dst) == axes(src)
    copy!(parent(dst), src)
end

function copy!(dst::AbstractStateVariable{DT,N,AT}, src::AbstractStateVariable{DT,N,AT}) where {DT,N,AT<:AbstractArray{DT,N}}
    @assert axes(dst) == axes(src)
    copy!(parent(dst), parent(src))
end

function add!(s::AbstractStateVariable{DT,N,AT}, Δs::AT) where {DT,N,AT<:AbstractArray{DT,N}}
    @assert axes(s) == axes(Δs)
    parent(s) .+= Δs
end


struct TimeVariable{DT<:Number,AT<:AbstractArray{DT,0}} <: AbstractScalarVariable{DT}
    value::AT
end

TimeVariable(x::TimeVariable) = TimeVariable(parent(x))
TimeVariable(x::Number) = TimeVariable(fill(x))

convert(::Type{<:TimeVariable}, x::Number) = TimeVariable(x)
convert(::Type{<:Number}, x::TimeVariable) = value(x)

parent(t::TimeVariable) = t.value
value(t::TimeVariable) = parent(t)[1]

function add!(t::TimeVariable{DT}, Δs::DT) where {DT}
    parent(t) .+= Δs
end

function copy!(t::TimeVariable{DT}, y::DT) where {DT}
    parent(t) .= y
end

Base.:(+)(a::TimeVariable) = a
Base.:(+)(a::TimeVariable, b::Number) = TimeVariable(value(a) + b)
Base.:(+)(a::Number, b::TimeVariable) = +(b, a)
Base.:(+)(a::TimeVariable, b::TimeVariable) = TimeVariable(value(a) + value(b))
Base.:(-)(a::TimeVariable) = TimeVariable(-value(a))
Base.:(-)(a::TimeVariable, b::Number) = TimeVariable(value(a) - b)
Base.:(-)(a::Number, b::TimeVariable) = TimeVariable(a - value(b))
Base.:(-)(a::TimeVariable, b::TimeVariable) = TimeVariable(value(a) - value(b))
Base.:(*)(a::TimeVariable, b::Number) = TimeVariable(value(a) * b)
Base.:(*)(a::Number, b::TimeVariable) = *(b, a)
Base.:(*)(a::TimeVariable, b::TimeVariable) = TimeVariable(value(a) * value(b))
Base.:(/)(a::TimeVariable, b::Number) = TimeVariable(value(a) / b)
Base.:(/)(a::Number, b::TimeVariable) = /(b, a)
Base.:(/)(a::TimeVariable, b::TimeVariable) = TimeVariable(value(a) / value(b))
Base.:(//)(a::TimeVariable, b::Number) = TimeVariable(value(a) // b)
Base.:(//)(a::Number, b::TimeVariable) = TimeVariable(a // value(b))
Base.:(//)(a::TimeVariable, b::TimeVariable) = TimeVariable(value(a) // value(b))
Base.:(^)(a::TimeVariable, b::Number) = TimeVariable(value(a)^b)


struct StateVariable{DT,N,AT,RT,PT} <: AbstractStateVariable{DT,N,AT}
    value::AT
    range::RT
    periodic::PT

    function StateVariable(value::AT, range::RT, periodic::PT) where {DT,N,AT<:AbstractArray{DT,N},RT<:Tuple{AT,AT},PT<:BitArray{N}}
        @assert axes(value) == axes(range[1]) == axes(range[2]) == axes(periodic)
        new{DT,N,AT,RT,PT}(value, range, periodic)
    end
end

function StateVariable(value::AT, range::RT) where {DT,N,AT<:AbstractArray{DT,N},RT<:Tuple{AT,AT}}
    periodic = BitArray(range[begin][i] ≠ -DT(Inf) && range[end][i] ≠ +DT(Inf) for i in eachindex(range[begin], range[end]))
    StateVariable(value, (range[begin], range[end]), periodic)
end

StateVariable(value::AT, range_min::AT, range_max::AT) where {DT,N,AT<:AbstractArray{DT,N}} = StateVariable(value, (range_min, range_max))

function StateVariable(value::AT) where {DT,N,AT<:AbstractArray{DT,N}}
    range_min = zero(value)
    range_max = zero(value)

    range_min .= typemin(DT)
    range_max .= typemax(DT)

    StateVariable(value, (range_min, range_max), falses(axes(value)))
end

StateVariable(value, ::NullPeriodicity) = StateVariable(value)

StateVariable(s::StateVariable) = StateVariable(parent(s), range(s), periodic(s))
StateVariable(s::StateVariable{DT,N,AT}, range::Tuple{AT,AT}) where {DT,N,AT<:AbstractArray{DT,N}} = StateVariable(parent(s), range)

value(s::StateVariable) = s.value
Base.range(s::StateVariable) = s.range
periodic(s::StateVariable) = s.periodic

value(s::StateVariable, i) = s.value[i]
Base.range(s::StateVariable, i) = (s.range[begin][i], s.range[end][i])

parent(s::StateVariable) = value(s)

Base.axes(s::StateVariable) = axes(parent(s))
Base.eachindex(s::StateVariable) = eachindex(parent(s))

isperiodic(s::StateVariable) = any(periodic(s))
isperiodic(s::StateVariable, i) = periodic(s)[i]

zero(s::StateVariable) = StateVariable(zero(parent(s)), range(s), periodic(s))

verifyrange(s::StateVariable, i) = value(s, i) ≥ range(s, i)[begin] && value(s, i) ≤ range(s, i)[end]
verifyrange(s::StateVariable) = BitArray(verifyrange(s::StateVariable, i) for i in eachindex(s))

struct VectorfieldVariable{DT,N,AT<:AbstractArray{DT,N}} <: AbstractStateVariable{DT,N,AT}
    value::AT
end
VectorfieldVariable(x::VectorfieldVariable) = VectorfieldVariable(parent(x))
VectorfieldVariable(x::StateVariable) = VectorfieldVariable(zero(parent(x)))

parent(v::VectorfieldVariable) = v.value

struct AlgebraicVariable{DT,N,AT<:AbstractArray{DT,N}} <: AbstractStateVariable{DT,N,AT}
    value::AT
end

AlgebraicVariable(x::AlgebraicVariable) = AlgebraicVariable(parent(x))
AlgebraicVariable(x::StateVariable) = AlgebraicVariable(zero(parent(x)))

parent(a::AlgebraicVariable) = a.value

struct Increment{DT,N,VT<:AbstractVariable{DT,N}} <: AbstractStateVariable{DT,N,VT}
    var::VT
end

Increment(x::Increment) = Increment(parent(x))

parent(i::Increment) = i.var

reset!(i::Increment) = parent(parent(i)) .= 0

function add!(s::VT, Δs::Increment{DT,N,VT}) where {DT,N,VT<:AbstractStateVariable{DT,N}}
    @assert axes(s) == axes(Δs)
    s .+= Δs
end

function add!(s::Increment{DT,N,VT}, Δs::AT) where {DT,N,AT<:AbstractArray{DT,N},VT<:AbstractStateVariable{DT,N,AT}}
    @assert axes(s) == axes(Δs)
    parent(parent(s)) .+= Δs
end

function add!(s::Increment{DT,N,VT}, Δs::VT) where {DT,N,VT<:AbstractStateVariable{DT,N}}
    add!(parent(parent(s)), parent(Δs))
end


"""
The `vectorfield` function returns a datastructure that stores the vectorfield for an
`AbstractStateVariable` `s` that holds the state of a system. By default it returns a `VectorfieldVariable` that
wraps `zero(parent(s))`, i.e., the same kind of array as the state variable, but custom methods
can be implemented in order to account for more specific use cases, e.g., when `s` also contains
constant fields that should not be present in the vector field.
"""
vectorfield(s::AbstractStateVariable) = VectorfieldVariable(zero(parent(s)))


struct StateWithError{DT,N,VT<:AbstractStateVariable{DT,N}} <: AbstractStateVariable{DT,N,VT}
    state::VT
    error::VT

    function StateWithError(state::VT) where {DT,N,VT<:AbstractStateVariable{DT,N}}
        new{DT,N,VT}(state, zero(state))
    end
end

parent(s::StateWithError) = parent(s.state)
zero(s::StateWithError) = StateWithError(zero(s.state))
periodic(s::StateWithError, args...) = periodic(s.state, args...)
isperiodic(s::StateWithError, args...) = isperiodic(s.state, args...)
Base.range(s::StateWithError, args...) = range(s.state, args...)
verifyrange(s::StateWithError, args...) = verifyrange(s.state, args...)

const StateVariableWithError{DT,N,AT,RT,PT} = StateWithError{DT,N,StateVariable{DT,N,AT,RT,PT}} where {DT,N,AT,RT,PT}

function copy!(dst::StateWithError{DT,N,VT}, src::AT) where {DT,N,AT<:AbstractArray{DT,N},VT<:AbstractStateVariable{DT,N,AT}}
    @assert axes(dst) == axes(src)
    copy!(dst.state, src)
    dst.error .= 0
end

function copy!(dst::StateWithError{DT,N,VT}, src::VT) where {DT,N,VT<:AbstractStateVariable{DT,N}}
    @assert axes(dst) == axes(src)
    copy!(parent(dst), parent(src))
    dst.error .= 0
end

# This is necessarry to disambiguate `copy!(dst::AbstractVector, src::AbstractVector)`
function copy!(dst::StateWithError{DT,1,VT}, src::AT) where {DT,AT<:AbstractVector{DT},VT<:AbstractStateVariable{DT,1,AT}}
    @assert axes(dst) == axes(src)
    copy!(parent(dst), src)
    dst.error .= 0
end

function copy!(dst::StateWithError{DT,N,VT}, src::StateWithError{DT,N,VT}) where {DT,N,VT<:AbstractStateVariable{DT,N}}
    @assert axes(dst) == axes(src)
    copy!(dst.state, src.state)
    copy!(dst.error, src.error)
end

function add!(s::StateWithError{DT,N,VT}, Δs::AT) where {DT,N,AT<:AbstractArray{DT,N},VT<:AbstractStateVariable{DT,N,AT}}
    @assert axes(s) == axes(Δs)
    # compensated summation
    for k in eachindex(s.state, s.error, Δs)
        x = s.state[k]
        ε = s.error[k]
        δ = Δs[k]

        a = x
        ε = ε + δ
        x = a + ε
        ε = ε + (a - x)

        s.state[k] = x
        s.error[k] = ε
    end
    return s
end

function add!(s::StateWithError{DT,N,VT}, Δs::Increment{DT,N,VT}) where {DT,N,VT<:AbstractStateVariable{DT,N}}
    add!(s, parent(Δs))
end


"""
`StateVector{DT,VT}` is a vector of [`StateVariable`](@ref)s, where `DT` is the datatype of the state and `VT` is the
type of the vector.
"""
const StateVector{DT,VT} = VT where {DT,VT<:AbstractVector{<:AbstractStateVariable{DT}}}

"""
`zerovector(X::StateVector)` returns a new [`StateVector`](@ref) with [`zero`](@ref) applied all elements of `X`.
"""
zerovector(X::ST) where {VT,ST<:StateVector{<:Number,VT}} = VT[zero(x) for x in X]


const TimeStep = Increment{<:TimeVariable}

Base.:(+)(t::TimeVariable, Δt::TimeStep) = TimeVariable(value(t) + value(parent(Δt)))
