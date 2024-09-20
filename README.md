# HybridStructs.jl

[![CI](https://github.com/Tortar/HybridStructs.jl/workflows/CI/badge.svg)](https://github.com/Tortar/HybridStructs.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/Tortar/HybridStructs.jl/graph/badge.svg?token=F8W0MC53Z0)](https://codecov.io/gh/Tortar/HybridStructs.jl)

This package provides a simple way to create both mutable and immutable versions 
of a struct from a single definition. This can be particularly useful when you want to switch between
mutable and immutable implementations without adding redundant code to define each version.

## Usage

```julia
julia> using HybridStructs

julia> @hybrid struct S
           const x::Int
           y::Float64
           z
       end
```

This will generate:

1. An immutable struct `S_Immut`;
2. A mutable struct `S_Mut`;
3. Constructors for `S` that can create either the mutable or immutable version.

It is then possible to create instances of the specified version with

```julia
julia> s1 = S(1, 2, 3; mutable=true)
S_Mut(1, 2.0, 3)

julia> s2 = S(1, 2, 3; mutable=false)
S_Immut(1, 2.0, 3)
```

For ease of use it is also possible to use a macro to mutate both versions
of a struct

```julia
julia> @update s1.y = 1.0
S_Mut(1, 1.0, 3)

julia> @update s2.y = 3.0
S_Immut(1, 3.0, 3)
```

Importantly, there are some catches to keep in mind:

- The constructors are backed by a struct of the same name (e.g `S` in the example above) which means
  that you shouldn't dispatch on it. Use one of the versions of the structs or the abstract type instead;
- For an immutable type, the mutation actually involve thecreation of a new instance with
  [Accessors.jl](https://github.com/JuliaObjects/Accessors.jl).


## Contributing

Contributions to HybridStructs.jl are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.
