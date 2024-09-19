module HybridStructs

using Accessors
using MacroTools

export @hybrid, @update

macro hybrid(expr)
    return esc(_hybrid(expr))
end

function _hybrid(expr)
    if expr.head != :struct
        error("@hybrid can only be applied to struct definitions")
    end

    struct_type = expr.args[2]
    if struct_type isa Expr && struct_type.head == :(<:)
        struct_type, abstract_type = struct_type.args
    else
        abstract_type = :(Any)
    end

    if struct_type isa Expr && struct_type.head == :curly
        struct_name = struct_type.args[1]
        type_params = struct_type.args[2:end]
    else
        struct_name = struct_type
        type_params = []
    end

    if abstract_type isa Expr && abstract_type.head == :curly
        abstract_struct_name = abstract_type.args[1]
        abstract_type_params = abstract_type.args[2:end]
    else
        abstract_struct_name = abstract_type
        abstract_type_params = []
    end

    struct_name_mut = Symbol(struct_name, :_Mut)
    struct_name_immut = Symbol(struct_name, :_Immut)
    abstract_struct_name_mut = Symbol(abstract_struct_name, :_Mut)
    abstract_struct_name_immut = Symbol(abstract_struct_name, :_Immut)

    abstract_struct_mut = abstract_type == :(Any) ? :(Any) : (:($abstract_struct_name_mut{$(abstract_type_params...)}))
    abstract_struct_immut = abstract_type == :(Any) ? :(Any) : (:($abstract_struct_name_immut{$(abstract_type_params...)}))

    struct_mut = :(mutable struct $struct_name_mut{$(type_params...)} <: $abstract_struct_mut
                       $(expr.args[3].args...)
                   end)

    struct_immut = :(struct $struct_name_immut{$(type_params...)} <: $abstract_struct_immut
                       $(expr.args[3].args...)
                   end)

    for (s, n) in zip((struct_mut, struct_immut), (struct_name_mut, struct_name_immut))
        for (i, field) in enumerate(s.args[3].args)
            if field isa Expr && inexpr(field.args[1], struct_name)
                func = splitdef(s.args[3].args[i])
                func[:name] = n
                s.args[3].args[i] = combinedef(func)
            end
        end
    end

    for (i, field) in enumerate(struct_immut.args[3].args)
        if field isa Expr && field.head == :const
            struct_immut.args[3].args[i] = field.args[end]
        end
    end

    struct_dummy = :(struct $struct_type <: $abstract_type 1 === 1 end)

    struct_constructors = [
            :(Base.@constprop :aggressive function $struct_name(args::Vararg{Any, _N_HY}; 
                    mutable=false) where {_N_HY}
                if mutable
                    return $struct_name_mut(args...)
                else
                    return $struct_name_immut(args...)
                end
            end)]

    if !isempty(type_params)
        push!(struct_constructors,
            :(Base.@constprop :aggressive function $struct_type(args::Vararg{Any, _N_HY};
                    mutable=false) where {$(type_params...), _N_HY}
                if mutable 
                    return $struct_name_mut{$(type_params...)}(args...)
                else
                    return $struct_name_immut{$(type_params...)}(args...)
                end
            end)
        )
    end

    return quote
        $struct_dummy
        if !(@isdefined $abstract_struct_name_mut) && $(namify(abstract_type)) != Any
            abstract type $abstract_struct_mut <: $abstract_type end
            abstract type $abstract_struct_immut <: $abstract_type end
        end
        $struct_mut
        $struct_immut
        $(struct_constructors...)
        nothing
    end
end

macro update(e)
    s = e.args[1].args[1]
    esc(quote
        if ismutabletype(typeof($s))
            $e
            $s
        else
            $HybridStructs.Accessors.@reset $e
        end
    end)
end

include("precompile.jl")

end