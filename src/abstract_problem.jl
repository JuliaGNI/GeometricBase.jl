
export AbstractProblem, isAbstractProblem


abstract type AbstractProblem end


isAbstractProblem(::Any) = false

function isAbstractProblem(problem::AbstractProblem)
    return true
end
