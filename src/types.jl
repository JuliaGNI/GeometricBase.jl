
struct NullInvariants end
Base.getindex(::NullInvariants,i...) = error("Invariants were indexed but the invariants are `nothing`. You likely forgot to pass invariants to the Equation!")
Base.iterate(::NullInvariants) = error("Invariants were indexed but the invariants are `nothing`. You likely forgot to pass invariants to the Equation!")

struct NullParameters end
Base.getindex(::NullParameters,i...) = error("Parameters were indexed but the parameters are `nothing`. You likely forgot to pass parameters to the Equation!")
Base.iterate(::NullParameters) = error("Parameters were indexed but the parameters are `nothing`. You likely forgot to pass parameters to the Equation!")


const OptionalArray{arrayType} = Union{Nothing, arrayType} where {arrayType <: AbstractArray}

const OptionalAbstractArray = Union{Nothing, AbstractArray}
const OptionalFunction      = Union{Nothing, Function}
const OptionalNamedTuple    = Union{NamedTuple, Nothing}
const OptionalInvariants    = Union{NamedTuple, NullInvariants}
const OptionalParameters    = Union{NamedTuple, NullParameters}

const AbstractData = Union{Number, AbstractArray{<:Number}}

const State{DT <: Number} = AbstractArray{DT}
const StateVector{DT,VT} = VT where {DT, VT <: AbstractVector{<:State{DT}}}

Base.zero(X::ST) where {DT, VT, ST <: StateVector{DT,VT}} = VT[zero(x) for x in X]


SolutionVector{DT} = Union{Vector{DT}, Vector{TwicePrecision{DT}}}
