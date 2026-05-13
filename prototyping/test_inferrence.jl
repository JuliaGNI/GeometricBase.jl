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
        return getfield(getfield(st, :state), s)
    else
        return getfield(st, s)
    end
end

state(st::State) = st.state

Base.keys(st::State) = keys(state(st))
Base.getindex(st::State, ::Val{s}) where {s} = getindex(state(st), s)
Base.getindex(st::State, s::Symbol) = getindex(st, Val(s))


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

# Accessing fields of NamedTuple via getindex of Val{<:Symbol} is type stable

test_symbol(state, s) = state[s]

@inferred test_symbol(st, Val(:t))
@inferred test_symbol(st, Val(:x))

@inferred st[Val(:t)]
@inferred st[Val(:x)]


for k in keys(data)
    @inferred test_symbol(st, Val(k))
end

for k in (:t, :x)
    @inferred test_symbol(st, Val(k))
end

function test_symbols(state, keys)
    for k in keys
        @inferred test_symbol(state, Val(k))
    end
end

test_symbols(st, (:t, :x))
test_symbols(st, keys(st))


function test_symbols_index(state, keys)
    for k in keys
        @inferred state[Val(k)]
    end
end

test_symbols_index(st, (:t, :x))
test_symbols_index(st, keys(st))


function test_symbols_keys(state)
    for k in keys(state)
        @inferred state[Val(k)]
    end
end

test_symbols_keys(st)


# Accessing fields of NamedTuple via getindex of Symbol is not type stable

@inferred test_symbol(st, :t)
@inferred test_symbol(st, :x)
