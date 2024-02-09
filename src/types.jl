
using Base: Callable, TwicePrecision


export NullInvariants, NullParameters, NullPeriodicity

export OptionalAbstractArray, OptionalArray,
       OptionalCallable, OptionalFunction,
       OptionalNamedTuple, OptionalTuple

export OptionalInvariants,
       OptionalParameters,
       OptionalPeriodicity

export AbstractData, AbstractStochasticProcess

export StateVariable, StateVector, SolutionVector

export vectorfield, zerovector


"""
`NullInvariants` is an empty struct that is used to indicate than an equation does not have invariants.
"""
struct NullInvariants end
Base.getindex(::NullInvariants, i...) = error("Invariants were indexed but the invariants are `NullInvariants`. You likely forgot to pass invariants to the Equation!")
Base.iterate(::NullInvariants) = error("Invariants were indexed but the invariants are `NullInvariants`. You likely forgot to pass invariants to the Equation!")

"""
`NullParameters` is an empty struct that is used to indicate than an equation does not have parameters.
"""
struct NullParameters end
Base.getindex(::NullParameters, i...) = error("Parameters were indexed but the parameters are `NullParameters`. You likely forgot to pass parameters to the Equation!")
Base.iterate(::NullParameters) = error("Parameters were indexed but the parameters are `NullParameters`. You likely forgot to pass parameters to the Equation!")

"""
`NullPeriodicity` is an empty struct that is used to indicate than an equation does not have periodic solution components.
"""
struct NullPeriodicity end
Base.getindex(::NullPeriodicity, i...) = error("Periodicity was indexed but the periodicity is `NullPeriodicity`. You likely forgot to pass periodicity to the Equation!")
Base.iterate(::NullPeriodicity) = error("Periodicity was indexed but the periodicity is `NullPeriodicity`. You likely forgot to pass periodicity to the Equation!")


const OptionalArray{arrayType} = Union{Nothing, arrayType} where {arrayType <: AbstractArray}

const OptionalAbstractArray = Union{Nothing, AbstractArray}
const OptionalCallable      = Union{Nothing, Callable}
const OptionalFunction      = Union{Nothing, Function}
const OptionalNamedTuple    = Union{Nothing, NamedTuple}
const OptionalTuple         = Union{Nothing, Tuple}

const OptionalInvariants    = Union{NamedTuple, NullInvariants}
const OptionalParameters    = Union{NamedTuple, NullParameters}
const OptionalPeriodicity   = Union{AbstractArray, NullPeriodicity}

const AbstractData = Union{Number, AbstractArray{<:Number}}

abstract type AbstractStochasticProcess{dType, ndim} end

"""
`StateVariable{T}` is a shortcut for `AbstractArray{T}` that can be extended in the future should the need arise.
"""
const StateVariable{T <: Number} = AbstractArray{T}

"""
The `vectorfield` function returns a datastructure that stores the vectorfield for an abstract
array `s` that holds the state of a system. By default it returns `zero(s)`, but custom methods
can be implemented in order to account for more specific use cases, e.g., when `s` also contains
constant fields that should not be present in the vector field.
"""
vectorfield(s::StateVariable) = zero(s)

"""
`StateVector{DT,VT}` is a vector of [`StateVariable`](@ref)s, where `DT` is the datatype of the state and `VT` is the 
type of the vector.
"""
const StateVector{DT,VT} = VT where {DT, VT <: AbstractVector{<:StateVariable{DT}}}

"""
`zerovector(X::StateVector)` returns a new [`StateVector`](@ref) with [`zero`](@ref) applied all elements of `X`.
"""
zerovector(X::ST) where {VT, ST <: StateVector{<: Number, VT}} = VT[zero(x) for x in X]

const SolutionVector{DT} = Union{Vector{DT}, Vector{TwicePrecision{DT}}}
