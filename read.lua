-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local love = require('love')
love.audio = require('love.audio') -- RecordingDevice
love.sound = require('love.sound') -- SoundData
love.thread = require('love.thread')
love.timer = require('love.timer')

local chirpy = require('chirpy')
local nu = require('libnu')

local state = chirpy.getstate(...)

love.thread.getChannel('read.tock'):push(true)
while true do
    local tick = love.thread.getChannel('read.tick'):demand()
    if tick == false then
        break
    end
    local n = 0
    while n < state.mic.nsamples do
        local j = love.thread.getChannel('j'):pop()
        if j ~= nil then
            n = n - j
        end
        local m = state.mic.device:getSampleCount()
        if m > math.min(state.mic.nsamples - n, 2 ^ 10) then
            local data = state.mic.device:getData()
            if data ~= nil then
                m = data:getSampleCount()
                for k = 0, m - 1 do
                    local sample = data:getSample(k)
--                  assert(sample >= -1 and sample <= 1, sample)
                    local i = n + k
                    if i >= 0 and i < state.mic.nsamples then
                        state.samples[i] = sample
                    end
                end
                local mean, _ = nu.sum.meanvar(state.samples + n, m)
                for i = n, n + m - 1 do
                    state.samples[i] = state.samples[i] - mean
                end
                love.thread.getChannel('read.stat'):push({n, n + m})
                n = n + m
            end
        end
        love.timer.sleep(1e-3)
    end
    love.thread.getChannel('read.tock'):push(true)
end
