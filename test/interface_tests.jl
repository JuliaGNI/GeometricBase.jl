using GeometricBase
using Test

import Unicode

# A name this package *owns* while one of its dependencies owns a different function of the same
# name is a re-definition rather than an extension: the two generics never meet, and Julia reports
# nothing either way — an unexported upstream name is never in scope to clash with, and a
# definition here wins over an exported one anyway.
#
# It is worth asserting at the bottom of the stack rather than only downstream: `GeometricBase`
# declares the interface generics the whole ecosystem extends, so a name re-defined here would
# fragment every one of its consumers at once.
#
# The upstream list is derived so that a new dependency is covered without editing this test.
# `identify_package` is what answers "is this module a direct dependency of `mod`", which is the
# right scope: a transitively loaded package is not one this module can shadow by accident. Testing
# instead whether `mod` *binds* the module's name would miss a dependency reached as
# `using Dep: name` — the form this package uses for its only one, `Unicode`.

function upstream_modules(mod::Module)
    ups = Module[Base, Core]
    for m in values(Base.loaded_modules)
        (m === mod || m === Base || m === Core) && continue
        Base.identify_package(mod, String(nameof(m))) === nothing && continue
        push!(ups, m)
    end
    unique(ups)
end

function shadowed_generics(mod::Module)
    ups = upstream_modules(mod)
    scanned = 0
    shadows = Tuple{Symbol, Module}[]
    for n in names(mod; all = true)
        startswith(String(n), "#") && continue
        # Every module is given an `eval` and an `include`. Up to Julia 1.11 `parentmodule` reports
        # `mod` for both, from 1.12 `Core` and `Base`; they are generated rather than declared here
        # either way, so skipping them keeps the scan the same on every supported version.
        n in (:eval, :include) && continue
        isdefined(mod, n) || continue
        f = getglobal(mod, n)
        (f isa Function && parentmodule(f) === mod) || continue
        scanned += 1
        for up in ups
            isdefined(up, n) || continue
            g = getglobal(up, n)
            (g isa Function && parentmodule(g) === up) || continue
            g === f || (push!(shadows, (n, up)); break)
        end
    end
    (scanned = scanned, shadows = sort!(shadows; by = t -> String(t[1])))
end

# `Unicode` is named explicitly rather than asserting `⊇ [Base, Core]`, which cannot fail:
# `upstream_modules` seeds those two itself, so such an assertion would pin the seeding and say
# nothing about the derivation. `Unicode` is this package's only declared dependency, and it is
# reached as `using Unicode: normalize`.
@test upstream_modules(GeometricBase) ⊇ [Base, Core, Unicode]

result = shadowed_generics(GeometricBase)

# Asserted because a `scanned` of zero would make the check below pass without looking at anything:
# `names(mod; all = true)` lists only what the module declares itself.
@test result.scanned > 0
@test result.shadows == Tuple{Symbol, Module}[]
