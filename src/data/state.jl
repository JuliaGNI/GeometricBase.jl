using Unicode: normalize

export HistoryState, State
export solution, state, vectorfield


# The `_state` function returns an appropriate empty state for a given state variable.
# _state(x::Number) = ScalarVariable(x)
_state(x::TimeVariable) = zero(x)
_state(x::StateVariable) = StateWithError(zero(x))
_state(x::VectorfieldVariable) = zero(x)
_state(x::AlgebraicVariable) = zero(x)
_state(x::StateWithError) = zero(x)

# The `_vectorfield` function returns an appropriate empty vectorfield for a given state variable.
# _vectorfield(x::Number) = missing
_vectorfield(x::TimeVariable) = missing
_vectorfield(x::StateVariable) = VectorfieldVariable(x)
_vectorfield(x::VectorfieldVariable) = missing
_vectorfield(x::AlgebraicVariable) = missing
_vectorfield(x::StateWithError) = _vectorfield(x.state)

# The `_convert` function returns an appropriate type for any given `AbstractVariable`.
# In particular, it returns the scalar value of a `TimeVariable`.
_convert(x::Missing) = x
_convert(x::AbstractVariable) = x
_convert(x::TimeVariable) = value(x)

# Adds a dot or bar to a symbol, indicating a time derivative or vector field, or a previous solution.
_add_symbol(s::Symbol, c::Char) = Symbol(normalize("$(s)$(c)"))
_add_bar(s::Symbol) = _add_symbol(s, Char(0x0304))
_add_dot(s::Symbol) = _add_symbol(s, Char(0x0307))

# Removes a dot or bar from a symbol.
_strip_symbol(s::Symbol, c::Char) = Symbol(strip(normalize(String(s); decompose=true), c))
_strip_bar(s::Symbol) = _strip_symbol(s, Char(0x0304))
_strip_dot(s::Symbol) = _strip_symbol(s, Char(0x0307))

# q̄ = Symbol(join([Char('q'), Char(0x0304)]))
# q̇ = Symbol(join([Char('q'), Char(0x0307)]))
# q = Symbol(strip(String(:q̄), Char(0x0304)))
# q = Symbol(strip(String(:q̇), Char(0x0307)))


"""
Holds the solution of a geometric equation at a single time step.

It stores all the information that is required to uniquely determine the state of a systen,
in particular all state variables and their corresponding vector fields.
"""
struct State{
    stateType<:NamedTuple,
    solutionType<:NamedTuple,
    vectorfieldType<:NamedTuple
}

    state::stateType
    solution::solutionType
    vectorfield::vectorfieldType

    function State(state, solution, vectorfield)
        new{typeof(state),typeof(solution),typeof(vectorfield)}(state, solution, vectorfield)
    end
end

function State(ics::NamedTuple; initialize=true)
    # create solution tuple for all variables in ics
    solution = map(x -> _state(x), ics)

    # create vectorfield vector for all state variables in ics
    vectorfield = map(x -> _vectorfield(x), ics)

    # remove all fields that are missing, i.e., that correspond to a variable without vectorfield
    vectorfield_filtered = NamedTuple{filter(k -> !all(ismissing.(vectorfield[k])), keys(vectorfield))}(vectorfield)

    # create vector field symbols with dotted solution symbols
    vectorfield_keys = map(k -> _add_dot(k), keys(vectorfield_filtered))
    vectorfield_dots = NamedTuple{vectorfield_keys}(values(vectorfield_filtered))

    # create state by merging solution fields with filtered vector fields
    state_fields = merge(solution, vectorfield_dots)

    # create state
    state = State(state_fields, solution, vectorfield_filtered)

    # copy initial conditions to state if initialize == true
    initialize && copy!(state, ics)

    return state
end

function Base.hasproperty(::State{ST}, s::Symbol) where {ST}
    hasfield(ST, s) || hasfield(State, s)
end

function Base.getproperty(st::State{ST}, s::Symbol) where {ST}
    if hasfield(ST, s)
        return _convert(getfield(getfield(st, :state), s))
    else
        return getfield(st, s)
    end
end

function Base.setproperty!(st::State{ST}, s::Symbol, x) where {ST}
    if hasfield(ST, s)
        return copy!(getfield(st, :state)[s], x)
    else
        return setfield!(st, s, x)
    end
end

state(st::State) = st.state
solution(st::State) = st.solution
vectorfield(st::State) = st.vectorfield

"""
    getindex(st::State, args...)

Passes `getindex` on to the state in `State`.
"""
Base.getindex(st::State, ::Val{s}) where {s} = getindex(state(st), s)
# Base.getindex(st::State, s::Symbol) = getindex(st, Val(s))

# Base.getindex(st::State, args...) = getindex(state(st), args...)
Base.nextind(st::State, args...) = nextind(state(st), args...)
Base.prevind(st::State, args...) = prevind(state(st), args...)
Base.eachindex(st::State) = eachindex(state(st))
Base.firstindex(st::State) = firstindex(state(st))
Base.lastindex(st::State) = lastindex(state(st))
Base.length(st::State) = length(state(st))

"""
    keys(st::State)

Return the keys of all the state variables in the `State`.
"""
Base.keys(st::State) = keys(state(st))

"""
    haskey(st::State, s::Symbol)

Checks if `s` is a valid state variable in the `State`.
"""
Base.haskey(st::State, s::Symbol) = haskey(state(st), s)

Base.in(st::State, args...) = in(state(st), args...)

Base.contains(st::State, args...) = contains(state(st), args...)

Base.iterate(st::State, args...) = iterate(state(st), args...)


"""
    copy!(st::State, sol::NamedTuple)

Copy the values from a `NamedTuple` `sol` to the `State` `st`.

The keys of `sol` must be a subset of the keys of the state.

# Arguments
- `st`: the state to copy into
- `sol`: the named tuple containing the solution values to copy
"""
function Base.copy!(st::State, sol::NamedTuple)
    @assert keys(sol) ⊆ keys(st)

    for k in keys(sol)
        copy!(st[Val(k)], sol[k])
    end

    return st
end

function Base.copy!(st::State, x::State)
    @assert keys(st) == keys(x)

    for k in keys(st)
        copy!(st[Val(k)], x[Val(k)])
    end

    return st
end

function Base.copy(oldstate::State)
    newstate = State(solution(oldstate))
    copy!(newstate, oldstate)
    return newstate
end


"""
    HistoryState(st::State)

Constructs a state whose symbols are decorated by a bar to indicate a previous value of the state.
"""
function HistoryState(st::State)
    # convert state
    history_state = NamedTuple{_add_bar.(keys(state(st)))}(values(state(st)))

    # convert solution
    history_solution = NamedTuple{_add_bar.(keys(solution(st)))}(values(solution(st)))

    # convert vectorfield
    history_vectorfield = NamedTuple{_add_bar.(keys(vectorfield(st)))}(values(vectorfield(st)))

    # create history state
    State(history_state, history_solution, history_vectorfield)
end
