using InfixFunctions
using Base.Test


@infix add(x, y) = x + y

@infix function sub(x, y)
    return x - y
end

x = 5

@test x |add| x == 10
@test x |sub| x == 0

@infix function foo(x::T, y::T) where {T<:Int}
    return Complex(x + y)
end

@infix foo(x::T, y::S) where {T<:Int, S<:Float64} = x - y

@test 3 |foo| 5 == 8 + 0im
@test 3 |foo| 5. == -2.0
