-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local array = {}

function array.copy(xs)
    local ys = {}
    for i, x in pairs(xs) do
        if type(x) == 'table' then
            ys[i] = array.copy(x)
        else
            ys[i] = x
        end
    end
    return ys
end

local function sub(xs, a, b)
    local ys = {}
    if a < 0 then
        a = a + #xs + 1
    end
    if b < 0 then
        b = b + #xs + 1
    end
    for i = a, b do
        ys[#ys + 1] = xs[i]
    end
    return ys
end

array.sub = sub

local function equal(x, y)
    if type(x) ~= type(y) then
        return false
    end
    if type(x) == 'table' then
        if #x == 0 and #y == 0 then
            return true
        else
            local a = sub(x, 2, -1)
            local b = sub(y, 2, -1)
            return equal(x[1], y[1]) and equal(a, b)
        end
    else
        return x == y
    end
end

array.equal = equal

function array.take(xs, n)
    return sub(xs, 1, n)
end

function array.last(xs, n)
    return sub(xs, -n, -1)
end

function array.reverse(xs)
    local ys = {}
    for i, x in ipairs(xs) do
        ys[#xs + 1 - i] = x
    end
    return ys
end

function array.median(xs)
    local ys = array.copy(xs)
    table.sort(ys)
    local n = #ys
    if n % 2 == 0 then
        return 0.5 * (ys[n / 2] + ys[n / 2 + 1])
    else
        return ys[(n + 1) / 2]
    end
end

return array
