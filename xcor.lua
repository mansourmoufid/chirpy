-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local love = require('love')
love.thread = require('love.thread')

local array = require('array')
local chirpy = require('chirpy')
local fft = require('libfftw.fftwf')
local nu = require('libnu')
local window = require('window')

if fft.threads then
    fft.init_threads()
    fft.plan_with_nthreads(2)
end

local function k(x, n)
    local i = nu.array.argmax(x, n)
    local j = nu.array.argmin(x, n)
    local max = x[i]
    local min = x[j]
    if math.abs(min) > math.abs(max) then
        i = j
    end
    local _, var = nu.sum.meanvar(x, n)
    local std = math.sqrt(var)
    return i, (max - min) / std
end

local state = chirpy.getstate(...)

nu.array.reverse(state.chirp0, state.chirp.size)
nu.array.reverse(state.chirp1, state.chirp.size)
for i = state.chirp.size, state.xcor.size - 1 do
    state.chirp0[i] = 0
    state.chirp1[i] = 0
end
window.sine(2 * state.chirp.size, state.chirp0, state.chirp.size)
window.sine(2 * state.chirp.size, state.chirp1, state.chirp.size)
fft.rfft(state.chirp0, state.xcor.size, state.CHIRP0)
fft.rfft(state.chirp1, state.xcor.size, state.CHIRP1)
while true do
    local tick = love.thread.getChannel('xcor.tick'):demand()
    if tick == false then
        break
    end
    for i = state.mic.nsamples, state.xcor.size - 1 do
        state.samples[i] = 0
    end
    fft.rfft(state.samples, state.xcor.size, state.SAMPLES)
    nu.array.cmul(state.XCOR0, state.SAMPLES, state.CHIRP0, state.xcor.size)
    nu.array.cmul(state.XCOR1, state.SAMPLES, state.CHIRP1, state.xcor.size)
    fft.irfft(state.XCOR0, state.xcor.size, state.xcor0)
    fft.irfft(state.XCOR1, state.xcor.size, state.xcor1)
--        for i = 0, state.chirp.size / 2 - 1 do
--            state.xcor0[i] = 0
--            state.xcor1[i] = 0
--            state.xcor0[state.xcor.size - 1 - i] = 0
--            state.xcor1[state.xcor.size - 1 - i] = 0
--        end
    local l = state.xcor.size
    local n = state.chirp.size
    local js = {}
    local x0 = state.xcor0 + n / 2
    local x1 = state.xcor1 + n / 2
    for i = 0, math.floor((l - n) / n) - 1 do
        local m = i * n
        assert(m + n <= l)
        local j0, k0 = k(x0 + m, n)
        local j1, k1 = k(x1 + m, n)
        local bit = nil
        local j = nil
        if k0 > 2 * k1 then
            bit = 0
            j = j0
        end
        if k1 > 2 * k0 then
            bit = 1
            j = j1
        end
        if bit ~= nil then
            love.thread.getChannel('bits'):push(bit)
            js[#js + 1] = j - n / 2
        end
    end
    if #js > 0 then
        local j = array.median(js)
        assert(j >= -n / 2 and j <= n / 2)
        love.thread.getChannel('j'):push(j)
    end
    love.thread.getChannel('xcor.tock'):push(true)
end
