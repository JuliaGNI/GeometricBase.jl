
export AbstractProblem, isAbstractProblem


abstract type AbstractProblem end


function isAbstractProblem(problem::AbstractProblem)
    return true
end
