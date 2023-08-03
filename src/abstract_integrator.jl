
export AbstractIntegrator, isAbstractIntegrator
export integrate, integrate!


abstract type AbstractIntegrator end


"""
```julia
integrate(problem, method; kwargs...)
```

Integrate a `problem` with `method` and return the solution.
"""
function integrate end


"""
Solve one time step:
```julia
integrate!(integrator)
```
"""
function integrate! end


function isAbstractIntegrator(int::AbstractIntegrator)
    applicable(integrate!, int) || return false
    return true
end
