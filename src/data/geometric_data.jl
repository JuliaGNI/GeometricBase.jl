"""
GeometricData is a wrapper for different types of data sets such as
the solution of a Lagrangian or Hamiltonian system.
"""
struct GeometricData{
        DataType <: AbstractDataType,
        SystemType <: AbstractSystem,
        TupleType <: NamedTuple
    }

    data::TupleType
end

@inline function Base.hasproperty(::GeometricData{DataType,SystemType,TupleType}, s::Symbol) where {DataType,SystemType,TupleType}
    hasfield(TupleType, s) || hasfield(GeometricData, s)
end

@inline function Base.getproperty(d::GeometricData{DataType,SystemType,TupleType}, s::Symbol) where {DataType,SystemType,TupleType}
    if hasfield(TupleType, s)
        return getfield(d, :data)[s]
    else
        return getfield(d, s)
    end
end
