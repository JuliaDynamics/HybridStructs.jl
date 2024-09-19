# HybridStructs.jl

`HybridStructs.jl` is a package that provides a simple way to create both mutable and immutable versions 
of a struct from a single definition. This can be particularly useful when you want to switch between
mutable and immutable implementations.

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

1. A mutable struct `S_Mut`;
2. An immutable struct `S_Immut`;
3. Constructors for `S` that can create either the mutable or immutable version.

You can then create instances of your struct with

```julia
julia> s1 = S(1, 2, 3; mutable=true)
S_Mut(1, 2.0, 3)

julia> s2 = S(1, 2, 3; mutable=false)
S_Immut(1, 2.0, 3)
```

You can also use a single macro to change both versions

```julia
julia> @update s1.y = 1.0
S_Mut(1, 1.0, 3)

julia> @update s2.y = 3.0
S_Immut(1, 3.0, 3)
```

## Contributing

Contributions to HybridStructs.jl are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.
