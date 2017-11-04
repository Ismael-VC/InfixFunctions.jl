__precompile__()

module InfixFunctions

using MacroTools: @capture

export @infix


struct InfixFunction <: Function
    operator::Function
end

(infix::InfixFunction)(arg₁, arg₂) = infix.operator(arg₁, arg₂)

function Base.:|(arg₁, infix::InfixFunction)
    return InfixFunction(arg₂ -> infix.operator(arg₁, arg₂))
end

Base.:|(infix::InfixFunction, arg₂) = infix.operator(arg₂)

"""
    @infix function_expr

# Usage

```julia
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

"""
macro infix(operator)
    @capture(
        operator,

        function (arg₁_, arg₂_)
            body_
        end                        |

        (arg₁_, arg₂_) -> body_

    ) || error("syntax: expected an anonymous function")

    return :($InfixFunction($operator)) |> esc
end


end # module
