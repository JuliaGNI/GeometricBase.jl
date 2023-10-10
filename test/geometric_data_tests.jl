using GeometricBase
using Test

import GeometricBase: AbstractSystem, AbstractDataType


@test typeof(LagrangianSystem()) <: AbstractSystem
@test typeof(LagrangianSystem()) <: DynamicalSystem
@test typeof(HamiltonianSystem()) <: AbstractSystem
@test typeof(HamiltonianSystem()) <: DynamicalSystem

@test typeof(RegularLagrangianSystem()) <: LagrangianSystem
@test typeof(DegenerateLagrangianSystem()) <: LagrangianSystem

@test typeof(CanonicalHamiltonianSystem()) <: HamiltonianSystem
@test typeof(NoncanonicalHamiltonianSystem()) <: HamiltonianSystem
@test typeof(PoissonSystem()) <: HamiltonianSystem


@test typeof(ObservableData()) <: AbstractDataType
@test typeof(StateData()) <: AbstractDataType
@test typeof(VectorFieldData()) <: AbstractDataType
@test typeof(TangentVectorData()) <: AbstractDataType


@test ismissing(state_symbols(ObservableData(), LagrangianSystem()))
@test ismissing(state_symbols(ObservableData(), HamiltonianSystem()))

@test state_symbols(StateData(), LagrangianSystem()) == (:q,:q̇)
@test state_symbols(VectorFieldData(), LagrangianSystem()) == (:q̇,:q̈)
@test state_symbols(TangentVectorData(), LagrangianSystem()) == (:q,:q̇,:q̈)

@test state_symbols(StateData(), DegenerateLagrangianSystem()) == (:q,)
@test state_symbols(VectorFieldData(), DegenerateLagrangianSystem()) == (:q̇,)
@test state_symbols(TangentVectorData(), DegenerateLagrangianSystem()) == (:q,:q̇)

@test state_symbols(StateData(), HamiltonianSystem()) == (:q,:p)
@test state_symbols(VectorFieldData(), HamiltonianSystem()) == (:q̇,:ṗ)
@test state_symbols(TangentVectorData(), HamiltonianSystem()) == (:q,:p,:q̇,:ṗ)

@test state_symbols(StateData(), NoncanonicalHamiltonianSystem()) == (:z,)
@test state_symbols(VectorFieldData(), NoncanonicalHamiltonianSystem()) == (:ż,)
@test state_symbols(TangentVectorData(), NoncanonicalHamiltonianSystem()) == (:z,:ż)

@test state_symbols(StateData(), PoissonSystem()) == (:z,)
@test state_symbols(VectorFieldData(), PoissonSystem()) == (:ż,)
@test state_symbols(TangentVectorData(), PoissonSystem()) == (:z,:ż)
