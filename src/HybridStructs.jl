module HybridStructs

export @hybrid

macro hybrid(expr)
    if expr.head != :struct
        error("@hybrid can only be applied to struct definitions")
    end

    mutable_name = Symbol(expr.args[2], "_Mutable")
    immutable_name = Symbol(expr.args[2], "_Immutable")
    orig_name = expr.args[2]

    mutable_def = Expr(:struct, true, mutable_name, expr.args[3])
    immutable_def = Expr(:struct, false, immutable_name, deepcopy(expr.args[3]))
    
    println(immutable_def)
    # Remove 'const' from immutable fields
    remove_const!(immutable_def.args[3])
    println(immutable_def)
    
    # Create constructors
    constructors = create_constructors(orig_name, mutable_name, immutable_name, expr.args[3])

    quote
        $mutable_def
        $immutable_def
        #$(constructors...)
    end
end

function remove_const!(block::Expr)
    for (i, arg) in enumerate(block.args)
        if arg isa Expr && arg.head == :(::) && arg.args[1] isa Expr && arg.args[1].head == :const
            block.args[i] = Expr(:(::), arg.args[1].args[1], arg.args[2])
        end
    end
end

function create_constructors(orig_name, mutable_name, immutable_name, block)
    fields = get_field_names(block)
    default_values = get_default_values(block)

    positional_constructor = quote
        function $orig_name($(fields...); mutable=false)
            mutable ? $mutable_name($(fields...)) : $immutable_name($(fields...))
        end
    end

    kwargs = [Expr(:kw, field, get(default_values, field, field)) for field in fields]
    keyword_constructor = quote
        function $orig_name(; $(kwargs...), mutable=false)
            mutable ? $mutable_name($(fields...)) : $immutable_name($(fields...))
        end
    end

    return [positional_constructor, keyword_constructor]
end

function get_field_names(block)
    fields = Symbol[]
    for arg in block.args
        if arg isa Expr && (arg.head == :(::) || arg.head == :(=))
            push!(fields, arg.args[1] isa Symbol ? arg.args[1] : arg.args[1].args[1])
        end
    end
    fields
end

function get_default_values(block)
    default_values = Dict{Symbol, Any}()
    for arg in block.args
        if arg isa Expr && arg.head == :(=)
            field_name = arg.args[1] isa Symbol ? arg.args[1] : arg.args[1].args[1]
            default_values[field_name] = arg.args[2]
        end
    end
    default_values
end

end
