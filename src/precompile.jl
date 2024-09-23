
using PrecompileTools

@setup_workload let
    @compile_workload let
        _hybrid(:(struct A
        	x::Int
		  end)
        )
        _hybrid(:(struct B{X} <: AbstractB{X}
		      x::X
		      y::Int
		      const z
		      B{X}(x, y) where X = new{X}(x, y, 1)
		      B{X}(x, y, z) where X = new{X}(x, y, z)
		      function B(x::X, y, z) where X
		          return new{X}(x, y, z)
		      end
		  end)
        )
    end
end
