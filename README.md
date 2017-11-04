# InfixFunctions

Julia infix function *hack*, based on this Python hack:

* http://code.activestate.com/recipes/384122-infix-operators

***

# Installation

```julia
julia> Pkg.clone("https://github.com/Ismael-VC/InfixFunctions.jl")
```

# Usage

```julia
julia> using InfixFunctions

julia> @infix foo(x, y) = x + y
foo (generic infix function with 1 method)

julia> @infix function foo(x::T, y::T) where {T<:Int}
           return Complex(x + y)
       end
foo (generic infix function with 2 methods)

julia> @infix foo(x::T, y::S) where {T<:Int, S<:Float64} = x - y
foo (generic infix function with 3 methods)

julia> 3.0 |foo| π
6.141592653589793

julia> 3 |foo| 5
8 + 0im

julia> 3 |foo| 5.
-2.0
```
