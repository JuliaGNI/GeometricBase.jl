
import Base: Callable

export NullInvariants, NullParameters, NullPeriodicity

export OptionalAbstractArray, OptionalArray,
       OptionalCallable, OptionalFunction,
       OptionalNamedTuple, OptionalTuple

export OptionalInvariants,
       OptionalParameters,
       OptionalPeriodicity

export AbstractData, AbstractStochasticProcess


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
const OptionalPeriodicity   = Union{Tuple{AT,AT}, NullPeriodicity} where {AT <: AbstractArray}

const AbstractData = Union{Number, AbstractArray{<:Number}}

abstract type AbstractStochasticProcess end
