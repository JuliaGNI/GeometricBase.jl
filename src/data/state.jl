using Unicode: normalize

export HistoryState, State
export solution, state, timevariable, vectorfield

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
_vectorfield(x::StateWithError) = _vectorfield(state(x))

# Adds a dot or bar to a symbol, indicating a time derivative or vector field, or a previous solution.
_add_symbol(s::Symbol, c::Char) = Symbol(normalize("$(s)$(c)"))
_add_bar(s::Symbol) = _add_symbol(s, Char(0x0304))
_add_dot(s::Symbol) = _add_symbol(s, Char(0x0307))

# Removes a dot or bar from a symbol.
_strip_symbol(s::Symbol, c::Char) = Symbol(strip(normalize(String(s); decompose = true), c))
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
    timeType <: TimeVariable,
    stateType <: NamedTuple,
    solutionType <: NamedTuple,
    vectorfieldType <: NamedTuple,
    stateKeys,
    solutionKeys,
    vectorfieldKeys
}
    time::timeType
    state::stateType
    solution::solutionType
    vectorfield::vectorfieldType

    function State(time, state, solution, vectorfield)
        stateKeys = Val.(keys(state))
        solutionKeys = Val.(keys(solution))
        vectorfieldKeys = Val.(keys(vectorfield))

        new{typeof(time), typeof(state), typeof(solution),
            typeof(vectorfield), stateKeys, solutionKeys, vectorfieldKeys}(
            time, state, solution, vectorfield)
    end
end

function State(initialtime::Real, ics::NamedTuple; initialize = true)
    # create time variable
    time = TimeVariable(zero(initialtime))

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
    state = State(time, state_fields, solution, vectorfield_filtered)

    # copy initial conditions to state if initialize == true
    initialize && copy!(time, initialtime)
    initialize && copy!(state, ics)

    return state
end

function State(initialtime::TimeVariable, ics::NamedTuple; kwargs...)
    State(value(initialtime), ics; kwargs...)
end
State(st::State; kwargs...) = State(time(st), solution(st); kwargs...)
State(st::StateWithError; kwargs...) = State(state(st); kwargs...)

"""
    keys(st::State)

Return the keys of all the state variables in the `State`.
"""
Base.keys(st::State) = keys(state(st))

function statekeys(::State{TT, stT, solT, vecT, stKeys, solKeys,
        vecKeys}) where {TT, stT, solT, vecT, stKeys, solKeys, vecKeys}
    stKeys
end
function solutionkeys(::State{TT, stT, solT, vecT, stKeys, solKeys,
        vecKeys}) where {TT, stT, solT, vecT, stKeys, solKeys, vecKeys}
    solKeys
end
function vectorfieldkeys(::State{TT, stT, solT, vecT, stKeys, solKeys,
        vecKeys}) where {TT, stT, solT, vecT, stKeys, solKeys, vecKeys}
    vecKeys
end

"""
    haskey(st::State, ::Val{s})
    haskey(st::State, s::Symbol)

Checks if `s` is a valid state variable in the `State`.
"""
# Base.haskey(st::State, s::Val) = s ∈ keys(st)
# Base.haskey(st::State, s::Symbol) = haskey(st, Val(s))
Base.haskey(st::State, s::Symbol) = haskey(state(st), s)

function Base.hasproperty(st::State, s::Symbol)
    s === :t || haskey(st, s) || hasfield(State, s)
end

function Base.getproperty(st::State, s::Symbol)
    if haskey(getfield(st, :state), s)
        return getfield(st, :state)[s]
    elseif s === :t
        return value(getfield(st, :time))
    else
        return getfield(st, s)
    end
end

function Base.setproperty!(st::State, s::Symbol, x)
    if haskey(getfield(st, :state), s)
        return copy!(getfield(st, :state)[s], x)
    elseif s === :t
        return copy!(getfield(st, :time), x)
    else
        return setfield!(st, s, x)
    end
end

timevariable(st::State) = st.time
Base.time(st::State) = value(timevariable(st))
state(st::State) = st.state
solution(st::State) = st.solution
vectorfield(st::State) = st.vectorfield
variables(st::State) = values(state(st))

"""
    getindex(st::State, args...)

Passes `getindex` on to the state in `State`.
"""
Base.getindex(st::State, ::Val{s}) where {s} = getindex(state(st), s)
Base.getindex(st::State, s::Symbol) = getindex(st, Val(s))
Base.getindex(st::State, i::Int) = getindex(st, keys(st)[i])

Base.nextind(st::State, args...) = nextind(keys(st), args...)
Base.prevind(st::State, args...) = prevind(keys(st), args...)
Base.eachindex(st::State) = eachindex(keys(st))
Base.firstindex(st::State) = firstindex(keys(st))
Base.lastindex(st::State) = lastindex(keys(st))

Base.length(st::State) = length(keys(st))
Base.iterate(st::State, i = 1) = i > length(st) ? nothing : (st[i], i + 1)
Base.isnan(st::State) = mapfoldl(isnan, |, variables(st))

"""
    initialize!(st::State, ics::NamedTuple)

Copy the values from a `NamedTuple` `ics` to the `State` `st`.

The keys of `ics` must be the same as the solution keys of the state.

# Arguments
- `st`: the state to copy into
- `ics`: the named tuple containing the initial values to copy
"""
function copy!(st::State, sol::NamedTuple)
    # @assert keys(sol) == keys(solution(st))
    # map((x, y) -> copy!(x, y), values(solution(st)), values(sol))
    # println("  keys(sol) = ", keys(sol))
    # println("  keys(st)  = ", keys(st))
    @assert keys(sol) ⊆ keys(st)
    map(k -> copy!(state(st)[k], sol[k]), keys(sol))
    return st
end

function copy!(st::State, t::Union{Real, TimeVariable}, sol::NamedTuple)
    copy!(st, sol)
    copy!(st.time, t)
    return st
end

"""
    copy!(dst::State, src::State)

Copy the values from one `State` `src` to another `State` `dst`.

The keys of `src` and `dst` must identical.

# Arguments
- `src`: the state to copy into
- `dst`: the state containing the solution values to copy
"""
function Base.copy!(dst::State, src::State)
    @assert keys(dst) == keys(src)
    copy!(dst.time, src.time)
    map((x, y) -> copy!(x, y), variables(dst), variables(src))
    return dst
end

function Base.copy(st::State)
    copy!(zero(st), st)
end

function Base.zero(st::State)
    State(time(st), solution(st); initialize = false)
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
    State(timevariable(st), history_state, history_solution, history_vectorfield)
end
