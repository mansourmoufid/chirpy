-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local chirpy = {}

local love = require('love')
love.audio = require('love.audio')
love.data = require('love.data')
love.sound = require('love.sound')
love.thread = require('love.thread')
love.timer = require('love.timer')

local array = require('array')
local nu = require('libnu')
local pointer = require('pointer')

function chirpy.sendstate(state)
    local s = array.copy(state)
    for x, t in pairs(s.pointers) do
        s[x] = pointer.pack(t, s[x])
    end
    return s
end

function chirpy.getstate(state)
    local s = array.copy(state)
    for x, t in pairs(s.pointers) do
        s[x] = pointer.unpack(s[x])
    end
    return s
end

return chirpy
