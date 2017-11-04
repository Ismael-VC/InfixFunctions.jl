using InfixFunctions
using Base.Test


# Test short and long function definitions:
@infix add(x, y) = x + y
@infix function sub(x, y)
    return x - y
end

x = 5

@test x |add| x == 10
@test x |sub| x == 0

# Test multiple dispatch and type parameters:
@infix function foo(x::T, y::T) where {T<:Int}
    return Complex(x + y)
end

@infix foo(x::T, y::S) where {T<:Int, S<:Float64} = x - y

@test 3 |foo| 5 == 8 + 0im
@test 3 |foo| 5.0 == -2.0


# Test infixifying normal functions:
@infix div
@infix div  # should work again

@test 10 |div| 5 == 2

# Test return types:
@infix function bar(x::T, y::T)::T where {T<:Int}
    return x + y
end

@infix (bar(x::T, y::S)::S) where {T<:Int, S<:Float64} = x - y

@test (5 |bar| 5)::Int == 10
@test (5 |bar| 5.0)::Float64 == 0.0
@test (10 |div| 5)::Int == 2

# Test normal function call syntax:
@test x |add| x == add(x, x)
@test x |sub| x == sub(x, x)
@test 3 |foo| 5 == foo(3, 5)
@test 3 |foo| 5.0 == foo(3, 5.0)
@test 10 |div| 5 == div(10, 5)
@test (5 |bar| 5)::Int == bar(5, 5)::Int
@test (5 |bar| 5.0)::Float64 == bar(5, 5.0)::Float64
@test (10 |div| 5)::Int == div(10, 5)::Int
