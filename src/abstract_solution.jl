
export AbstractSolution, isAbstractSolution

abstract type AbstractSolution{dType, tType} end


isAbstractSolution(::Any) = false

function isAbstractSolution(sol::AbstractSolution)
    applicable(step, sol) || return false
    applicable(ntime, sol) || return false
    applicable(nstore, sol) || return false
    applicable(timesteps, sol) || return false
    applicable(eachtimestep, sol) || return false

    return true
end


Base.write(::IOStream, sol::AbstractSolution) = error("Base.write(::IOStream, ::Solution) not implemented for ", typeof(sol))
