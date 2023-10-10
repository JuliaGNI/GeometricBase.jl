
export DynamicalSystem
export LagrangianSystem, DegenerateLagrangianSystem, RegularLagrangianSystem
export HamiltonianSystem, CanonicalHamiltonianSystem, NoncanonicalHamiltonianSystem, PoissonSystem


abstract type AbstractSystem end

abstract type DynamicalSystem <: AbstractSystem end
abstract type LagrangianSystem <: DynamicalSystem end
abstract type HamiltonianSystem <: DynamicalSystem end

struct RegularLagrangianSystem <: LagrangianSystem end
struct DegenerateLagrangianSystem <: LagrangianSystem end

LagrangianSystem() = RegularLagrangianSystem()

struct CanonicalHamiltonianSystem <: HamiltonianSystem end
struct NoncanonicalHamiltonianSystem <: HamiltonianSystem end
struct PoissonSystem <: HamiltonianSystem end

HamiltonianSystem() = CanonicalHamiltonianSystem()
