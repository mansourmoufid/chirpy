-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local pointer = {}

local ffi = require('ffi')

local function split(x, w, n, f, g)
    local xs = {}
    local two = f(2)
    for i = 1, n do
        local j = i - 1
        local a = two ^ (w * (j + 1))
        local b = two ^ (w * j)
        if b == 0 then
            break
        end
        local z = (a > 0) and (x % a / b) or (x / b)
        xs[i] = g(z)
    end
    return xs
end

local function join(xs, w, f)
    local z = f(0)
    local two = f(2)
    for i, x in ipairs(xs) do
        local j = i - 1
        z = z + f(x) * two ^ (w * j)
    end
    return z
end

local tointptr = function (x) return ffi.new('uintptr_t', x) end

function pointer.pack(type, x)
    return {
        type = type,
        address = split(
            ffi.cast('uintptr_t', x),
            16,
            4,
            tointptr,
            tonumber
        ),
    }
end

function pointer.unpack(x)
    return ffi.cast(
        x.type .. ' *',
        join(
            x.address,
            16,
            tointptr
        )
    )
end

--local x = ffi.new('uint64_t', 31415926535)
--local f = function (x) return ffi.new('uint64_t', x) end
--local y = split(x, 8, 10, f, tonumber)
--local z = join(y, 8, f)
--assert(x == z)

return pointer
