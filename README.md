# HybridStructs.jl

`HybridStructs.jl` is a package that provides a simple way to create both mutable and immutable versions of a struct from a single definition.
This can be particularly useful when you want to switch between mutable and immutable implementations.

## Usage

```julia
using HybridStructs

@hybrid @kwdef MyStruct
    const x::Int
    y::Float64
    z = 3
end
```

This will generate:

1. A mutable struct `MyStruct_Mutable`
2. An immutable struct `MyStruct_Immutable`
3. Constructors for `MyStruct` that can create either the mutable or immutable version

You can then create instances of your struct:

```julia
# Create an immutable instance
immutable_instance = MyStruct(1, 2.0)

# Create a mutable instance
mutable_instance = MyStruct(1, 2.0, mutable=true)
```

## Contributing

Contributions to HybridStructs.jl are welcome! Please feel free to submit issues, pull requests, or suggestions to improve the package.
