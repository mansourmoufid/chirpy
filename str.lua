-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local str = {}

function str.join(sep, xs)
    if #xs == 0 then
        return ''
    end
    local ys = xs[1]
    for i = 2, #xs do
        ys = ys .. sep .. xs[i]
    end
    return ys
end

assert(str.join('', {'1', '2', '3'}) == '123')
assert(str.join('.', {'1', '2', '3'}) == '1.2.3')

function str.split(s, sep)
    local xs = {}
    local j = 1
    for i = 1, #s do
        local a = i
        local b = i + #sep - 1
        if string.sub(s, a, b) == sep then
            xs[#xs + 1] = string.sub(s, j, i - 1)
            j = i + #sep
        end
    end
    if j <= #s then
        xs[#xs + 1] = string.sub(s, j, -1)
    end
    return xs
end

assert(str.join('.', str.split('1.2.3', '.')) == '1.2.3')

return str
