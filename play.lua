-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local love = require('love')
love.audio = require('love.audio')
love.sound = require('love.sound')
love.thread = require('love.thread')
love.timer = require('love.timer')

local array = require('array')
local chirp = require('chirp')
local chirpy = require('chirpy')
local window = require('window')

local state = chirpy.getstate(...)

local samplerate = 48000
local bits = 16
local channels = 1
local duration = state.chirp.duration
local size = duration * samplerate
local band = state.chirp.band
local chirps = {[0] = {}, [1] = {}}
chirp.linear(array.reverse(band), duration, chirps[0], size)
chirp.linear(band, duration, chirps[1], size)
window.sine(2 * size, chirps[0], size, 1)
window.sine(2 * size, chirps[1], size, 1)
local src = {}
for bit = 0, 1 do
    local data = love.sound.newSoundData(
        size,
        samplerate,
        bits,
        channels
    )
    for i = 1, size do
        for j = 1, channels do
            data:setSample(i - 1, j, chirps[bit][i])
        end
    end
    src[bit] = love.audio.newSource(data)
end
while true do
    local tick = love.thread.getChannel('play.tick'):demand()
    if tick == false then
        break
    end
    for _, bit in ipairs(tick) do
        love.audio.play(src[bit])
        while src[bit]:isPlaying() do
            love.timer.sleep(1e-3)
        end
    end
end
