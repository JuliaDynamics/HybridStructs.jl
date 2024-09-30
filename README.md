# HybridStructs.jl

[![CI](https://github.com/JuliaDynamics/HybridStructs.jl/workflows/CI/badge.svg)](https://github.com/JuliaDynamics/HybridStructs.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/JuliaDynamics/HybridStructs.jl/graph/badge.svg?token=F8W0MC53Z0)](https://codecov.io/gh/JuliaDynamics/HybridStructs.jl)

This package provides a simple way to create both mutable and immutable versions 
of a struct from a single definition. This can be particularly useful when you want
to switch between mutable and immutable implementations without adding redundant code
to define each version.

## Usage

A `@hybrid` macro can be attached to a struct definition to define the two version
all at once:

```julia
julia> using HybridStructs

julia> abstract type AbstractS{Y} end

julia> @hybrid struct S{Y} <: AbstractS{Y}
           const x::Int
           y::Y
           z::Float64
       end
```

which in this case it generates:

```julia
julia> abstract type AbstractS_Mut{Y} <: AbstractS{Y} end

julia> abstract type AbstractS_Immut{Y} <: AbstractS{Y} end

julia> mutable struct S_Mut{Y} <: AbstractS_Mut{Y}
           const x::Int
           y::Y
           z::Float64
       end

julia> struct S_Immut{Y} <: AbstractS_Immut{Y}
           x::Int
           y::Y
           z::Float64
       end

julia> const S = Union{S_Immut{Y}, S_Mut{Y}} where Y
```

It is then possible to create instances of the specified version with

```julia
julia> s1 = S_Mut(1, 2, 3.0)
S_Mut{Int}(1, 2, 3.0)

julia> s2 = S_Immut(1, 2, 3.0)
S_Immut{Int}(1, 2.0, 3.0)
```

For ease of use it is also possible to use a macro to mutate both versions
of a struct:

```julia
julia> @update s1.y = 1
S_Mut{Int}(1, 1, 3.0)

julia> @update s2.y = 3
S_Immut{Int}(1, 3, 3.0)
```

Importantly, for an immutable type, the mutation actually involve the creation
of a new instance with [Accessors.jl](https://github.com/JuliaObjects/Accessors.jl).


## Contributing

Contributions are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.
