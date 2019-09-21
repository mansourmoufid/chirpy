-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local pointer = {}

local ffi = require('ffi')

local function split(x)
    local t = ffi.typeof(x)
    local n = ffi.sizeof(t)
    local two = ffi.new(t, 2)
    local xs = {}
    for i = 1, n do
        local a = two ^ (8 * (i))
        local b = two ^ (8 * (i - 1))
        if b == 0 then
            break
        end
        local z = (a > 0) and (x % a / b) or (x / b)
        xs[i] = tonumber(z)
    end
    return xs
end

local function join(t, xs)
    local two = ffi.new(t, 2)
    local z = ffi.new(t, 0)
    for i, x in ipairs(xs) do
        z = z + x * two ^ (8 * (i - 1))
    end
    return z
end

function pointer.pack(type, x)
    return {type = type, address = split(ffi.cast('uintptr_t', x))}
end

function pointer.unpack(x)
    return ffi.cast(x.type .. ' *', join('uintptr_t', x.address))
end

return pointer
