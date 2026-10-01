using Test

import GeometricBase

# Every stub of `src/methods.jl` is meant to be extended by other packages, so each one is
# public: exported, or named in the `public` statement. The names are read from the file, so
# that a stub added without a `public` entry fails here.

const STUB = r"^function\s+(\S+)\s+end\s*$"

stubs = Symbol[]
for line in eachline(joinpath(pkgdir(GeometricBase), "src", "methods.jl"))
    m = match(STUB, line)
    m === nothing || push!(stubs, Symbol(m[1]))
end

# The regular expression finds the stubs at all: one from the start of the file, one from the end.
@test :datatype in stubs
@test :h5load in stubs

@testset "$name is public" for name in [stubs; :initialtime; :finaltime]
    @test Base.ispublic(GeometricBase, name)
end
