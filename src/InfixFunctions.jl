__precompile__()

module InfixFunctions

using MacroTools: @capture
using Base.Meta: quot

export @infix


struct InfixFunction <: Function
    name::Symbol
    operator::Function

end

InfixFunction(operator::Function) = InfixFunction(gensym(), operator)

(infix::InfixFunction)(arg₁, arg₂) = infix.operator(arg₁, arg₂)

Base.methods(infix::InfixFunction) = methods(infix.operator)

function Base.show(io::IO, infix::InfixFunction)
    n_methods = length(methods(infix.operator))
    _methods = n_methods == 1 ? "method" : "methods"
    name = infix.name

    println(io, "$name (generic infix function with $n_methods $_methods)")
end

Base.display(infix::InfixFunction) = show(infix)

function Base.:|(arg₁, infix::InfixFunction)
    return InfixFunction(arg₂ -> infix.operator(arg₁, arg₂))
end


Base.:|(infix::InfixFunction, arg₂) = infix.operator(arg₂)


"""
    @infix function_expression::Expr

# Usage

```julia
julia> using InfixFunctions

julia> @infix foo(x, y) = x + y
foo (generic infix function with 1 method)

julia> @infix function foo(x::T, y::T) where {T<:Int}
           return Complex(x + y)
       end
foo (generic infix function with 2 methods)

julia> @infix (foo(x::T, y::S)::S) where {T<:Int, S<:Float64} = x - y
foo (generic infix function with 3 methods)

julia> 3.0 |foo| π
6.141592653589793

julia> 3 |foo| 5
8 + 0im

julia> 3 |foo| 5.
-2.0
```
"""
macro infix(operator::Expr)
    @capture(operator, function name_(arg₁_, arg₂_)::ret_typ_ where parameters__ body_ end)    ||
    @capture(operator, function name_(arg₁_, arg₂_) where parameters__ body_ end)              ||

    @capture(operator, (name_(arg₁_, arg₂_)::ret_typ_) where parameters__ = body_)             ||
    @capture(operator, name_(arg₁_, arg₂_) where parameters__ = body_)                         ||

    @capture(operator, function name_(arg₁_, arg₂_)::ret_typ_ body_ end)                       ||
    @capture(operator, function name_(arg₁_, arg₂_) body_ end)                                 ||

    @capture(operator, (name_(arg₁_, arg₂_)::ret_typ_) = body_)                                ||
    @capture(operator, name_(arg₁_, arg₂_) = body_)                                            ||

    error("syntax: expected a binary function")

    dummy_params = [:(__Dummy <: __AbstractDummy)]
    _parameters = parameters === nothing ? dummy_params : parameters

    dummy_ret_typ = :__Dummy
    _ret_typ = ret_typ === nothing ? dummy_ret_typ : ret_typ

    return quote
        if !isdefined($(quot(name)))
            if !($(quot(_parameters)) == $(quot(dummy_params)))
                if !($(quot(_ret_typ)) == $(quot(dummy_ret_typ)))
                    const $name = $InfixFunction($(quot(name)), (($arg₁, $arg₂) where $(_parameters...)) -> $body::$ret_typ)
                else
                    const $name = $InfixFunction($(quot(name)), (($arg₁, $arg₂) where $(_parameters...)) -> $body)
                end
            else
                if !($(quot(_ret_typ)) == $(quot(dummy_ret_typ)))
                    const $name = $InfixFunction($(quot(name)), ($arg₁, $arg₂) -> $body::$ret_typ)
                else
                    const $name = $InfixFunction($(quot(name)), ($arg₁, $arg₂) -> $body)
                end
            end
        else
            if !($(quot(_parameters)) == $(quot(dummy_params)))
                if !($(quot(_ret_typ)) == $(quot(dummy_ret_typ)))
                    ($name.operator($arg₁, $arg₂)::$ret_typ) where $(_parameters...) = $body
                else
                    $name.operator($arg₁, $arg₂) where $(_parameters...) = $body
                end
            else
                if !($(quot(_ret_typ)) == $(quot(dummy_ret_typ)))
                    ($name.operator($arg₁, $arg₂)::$ret_typ) = $body
                else
                    $name.operator($arg₁, $arg₂) = $body
                end
            end
            $name
        end
    end |> esc
end

"""
    @infix function_symbol::Symbol

# Usage

```julia
julia> using InfixFunctions

julia> @infix div
INFO: div has been infixified
div (generic function with 31 methods)

julia> 10 |div| 5
2
```
"""
macro infix(operator::Symbol)
    return quote
        $operator::Function

        function Base.:|(arg₁, infix::typeof($operator))
            return $InfixFunction(arg₂ -> infix(arg₁, arg₂))
        end

        Base.:|(infix::typeof($operator), arg₂) = infix(arg₂)

        info("$($operator) has been infixified")

        $operator
    end |> esc
end


end # module
