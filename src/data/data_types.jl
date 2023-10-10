
export ObservableData, StateData, VectorFieldData, TangentVectorData
export state_symbols


abstract type AbstractDataType end

struct ObservableData <: AbstractDataType end
struct StateData <: AbstractDataType end
struct VectorFieldData <: AbstractDataType end
struct TangentVectorData <: AbstractDataType end

state_symbols(datatype::AbstractDataType, system::AbstractSystem) = missing

state_symbols(datatype::StateData, system::RegularLagrangianSystem) = (:q,:q̇)
state_symbols(datatype::VectorFieldData, system::RegularLagrangianSystem) = (:q̇,:q̈)
state_symbols(datatype::TangentVectorData, system::RegularLagrangianSystem) = (:q,:q̇,:q̈)

state_symbols(datatype::StateData, system::DegenerateLagrangianSystem) = (:q,)
state_symbols(datatype::VectorFieldData, system::DegenerateLagrangianSystem) = (:q̇,)
state_symbols(datatype::TangentVectorData, system::DegenerateLagrangianSystem) = (:q,:q̇,)

state_symbols(datatype::StateData, system::CanonicalHamiltonianSystem) = (:q,:p)
state_symbols(datatype::VectorFieldData, system::CanonicalHamiltonianSystem) = (:q̇,:ṗ)
state_symbols(datatype::TangentVectorData, system::CanonicalHamiltonianSystem) = (:q,:p,:q̇,:ṗ)

state_symbols(datatype::StateData, system::Union{NoncanonicalHamiltonianSystem,PoissonSystem}) = (:z,)
state_symbols(datatype::VectorFieldData, system::Union{NoncanonicalHamiltonianSystem,PoissonSystem}) = (:ż,)
state_symbols(datatype::TangentVectorData, system::Union{NoncanonicalHamiltonianSystem,PoissonSystem}) = (:z,:ż)
