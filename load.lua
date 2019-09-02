-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local love = require('love')
love.audio = require('love.audio')
love.thread = require('love.thread')

local array = require('array')
local chirp = require('chirp')
local chirpy = require('chirpy')
local math = require('math')
local nu = require('libnu')
local str = require('str')

nu.array.gc = function (x) return x end

local function getMic(mics, samplerates, formats, samplecounts)
    local channels = 1
    for _, dev in ipairs(mics) do
        for _, samplerate in ipairs(samplerates) do
            for _, format in ipairs(formats) do
                for _, samplecount in ipairs(samplecounts) do
                    local ok = dev:start(
                        samplecount,
                        samplerate,
                        format,
                        channels
                    )
                    if ok then
                        return dev, samplerate, format, samplecount
                    end
                end
            end
        end
    end
    return nil
end

local state = chirpy.getstate(...)

state.mics = love.audio.getRecordingDevices()
while state.mic.device == nil do
    local device, samplerate, format, samplecount = getMic(
        state.mics,
        state.mic.samplerates,
        state.mic.formats,
        state.mic.samplecounts
    )
    state.mic.device = device
    state.mic.samplerate = samplerate
    state.mic.format = format
    state.mic.samplecount = samplecount
end
love.thread.getChannel('log'):push({
    tostring(state.mic.device),
    '    ' .. state.mic.samplerate .. ' Hz',
    '    ' .. state.mic.format .. ' bits',
    '    ' .. state.mic.samplecount .. ' samples',
})
state.chirp.size = math.floor(state.chirp.duration * state.mic.samplerate)
state.mic.nsamples = math.floor(1.0 * state.mic.samplerate)
state.xcor.size = state.mic.nsamples + state.chirp.size
state.xcor.size = math.ceil(state.xcor.size / (2 * 3 * 5)) * (2 * 3 * 5)
for x, t in pairs(state.pointers) do
    local n = state.xcor.size
    while state[x] == nil do
        state[x] = nu.array.new(t, n)
        if state[x] ~= nil then
            nu.array.zero(state[x], n)
        end
    end
end
local band = state.chirp.band
local duration = state.chirp.duration
local size = state.chirp.size
chirp.linear(array.reverse(band), duration, state.chirp0, size)
chirp.linear(band, duration, state.chirp1, size)
love.thread.getChannel('log'):push({
    'chirp:',
    '    ' .. str.join('-', band) .. ' Hz ',
    '    ' .. duration .. ' s',
    '    ' .. size .. ' samples',
})
love.thread.getChannel('load'):push(chirpy.sendstate(state))
