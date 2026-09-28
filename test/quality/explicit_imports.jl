using ExplicitImports
using GeometricBase
using Test

# Fails on a stale explicit import, on an explicit import or a qualified access through a module
# other than the owner of the name, and on a qualified access to a name of `GeometricBase` itself.
test_explicit_imports(
    GeometricBase;
    # `false` so that the guard has one form in every package of the stack;
    # GeometricBase itself passes this check
    no_implicit_imports = false,
    # `src/types.jl` imports `Base.Callable`, which `Base` does not mark `public`
    all_explicit_imports_are_public = false,
    # `src/data/state_variables.jl` extends `Base.broadcasted`, which `Base` does not mark `public`
    all_qualified_accesses_are_public = false
)
