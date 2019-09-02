-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local fibonacci = {}

local function F(n)
    if n == 0 then
        return 0
    elseif n == 1 then
        return 1
    else
        return F(n - 1) + F(n - 2)
    end
end

function fibonacci.encode(x)
    local n = 1
    while F(n) <= x do
        n = n + 1
    end
    local b = {}
    local r = x
    for i = n - 1, 2, -1 do
        if F(i) <= r then
            r = r - F(i)
            b[i - 1] = 1
        else
            b[i - 1] = 0
        end
    end
    b[n - 1] = 1
    return b
end

function fibonacci.decode(x)
    local w = 0
    for i = 1, #x - 1 do
        w = w + F(i + 1) * x[i]
    end
    return w
end

return fibonacci
