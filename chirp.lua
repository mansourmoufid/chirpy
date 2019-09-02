-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local chirp = {}

local math = require('math')

function chirp.linear(bandwidth, T, x, n)
    local i = 0
    if x[0] == nil then
        i = 1
    end
    local fmin, fmax = unpack(bandwidth)
    local fmid = (fmin + fmax) / 2
    for j = 0, n - 1 do
        local f = (fmin * n + (fmid - fmin) * j) / n;
        local t = T * j / n;
        x[i + j] = math.sin(2 * math.pi * f * t)
    end
end

return chirp
