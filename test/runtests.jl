using InfixFunctions
using Base.Test


add = @infix (x, y) -> x + y

sub = @infix function (x, y)
    return x - y
end

x = 5

@test x |add| x == 10
@test x |sub| x == 0
