
export GeometricIntegrator, isGeometricIntegrator
export DeterministicIntegrator, StochasticIntegrator
export integrate, integrate!


abstract type GeometricIntegrator end

abstract type DeterministicIntegrator <: GeometricIntegrator end
abstract type StochasticIntegrator <: GeometricIntegrator end


"""
```julia
integrate(problem, method; kwargs...)
```

Integrate a `problem` with `method` and return the solution.

Some convenience methods exist for the integration of ODEs,
```julia
integrate(v, x₀, tableau, Δt, ntime; t₀=0., kwargs...)
```
where `v` is the function for the vector field, `x₀` the initial condition
and `t₀` the initial time, and for PODEs
```julia
integrate(v, f, q₀, p₀, tableau, Δt, ntime; t₀=0., kwargs...)
```
with vector fields `v` and `f` and initial conditions `q₀` and `p₀`.
"""
function integrate end


"""
Solve one time step:
```julia
integrate!(integrator)
```
"""
function integrate! end


function isGeometricIntegrator(int::GeometricIntegrator)
    applicable(integrate!, int) || return false
    # applicable(integrate, problem, method) || return false
    return true
end
