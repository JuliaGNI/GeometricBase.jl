using Test

# The type `State` has only one field that is a `NamedTuple`
struct State{stateType<:NamedTuple}
    state::stateType
end

function State(data::NamedTuple)
    State{typeof(data)}(data)
end

# `hasproperty` checks if `s` is either a key of the `NamedTuple` or a field in `State`
function Base.hasproperty(::State{ST}, s::Symbol) where {ST}
    hasfield(ST, s) || hasfield(State, s)
end

# `getproperty` checks if `s` is a key of the `NamedTuple` and if so returns the corresponding value,
# if not it returns the corresponding field of `State`
function Base.getproperty(st::State{ST}, s::Symbol) where {ST}
    if hasfield(ST, s)
        return getfield(st, :state)[s]
        # return getproperty(getfield(st, :state), s)
    else
        return getfield(st, s)
    end
end

# `getindex` is just forwarded to the `getindex` method of the `NamedTuple`
Base.getindex(st::State, args...) = getindex(st.state, args...)


### Test for type stability ###

# Create a `State` instance based on some arbitrary data

data = (
    t=0.0,
    x=rand(3),
)

st = State(data)

# Accessing fields of NamedTuple via forwarding in getproperty works fine:

test_t(state) = state.t
test_x(state) = state.x

@inferred test_t(st)
@inferred test_x(st)

# Accessing fields of NamedTuple via getindex is not type stable

test_symbol(state, s) = state[s]

@inferred test_symbol(st, :t)
@inferred test_symbol(st, :x)
