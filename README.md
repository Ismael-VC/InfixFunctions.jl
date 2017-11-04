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
julia> using InfixFunctions: @infix

julia> add = @infix (x, y) -> x + y
(::InfixFunction) (generic function with 1 method)

julia> 5 |add| 5
10

julia> sub = @infix function (x, y)
           return x - y
       end
(::InfixFunction) (generic function with 1 method)

julia> 5 |sub| 5
0
```
