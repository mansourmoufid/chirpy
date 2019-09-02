-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local window = {}

local math = require('math')

function window.sine(N, x, n)
    local i = 0
    if x[0] == nil then
        i = 1
    end
    for j = 0, n - 1 do
        x[i + j] = x[i + j] * math.sin(2 * math.pi * j / N)
    end
end

return window
