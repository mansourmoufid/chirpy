-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local button = {}

local love = require('love')
love.graphics = require('love.graphics')

local function norm(x, y)
    local a, b = unpack(x)
    local c, d = unpack(y)
    return math.sqrt((c - a) ^ 2 + (d - b) ^ 2)
end

local Button = {
    label = function (self)
        return 'button'
    end,
    toggle = function (self)
    end,
    resize = function (self, w, h)
    end,
    update = function (self, dt)
    end,
    mousepressed = function (self, x, y)
        if norm({x, y}, self.center) > self.radius then
            return
        end
        self.border = self.border / 2
    end,
    mousereleased = function (self, x, y)
        if norm({x, y}, self.center) > self.radius then
            return
        end
        self.border = self.border * 2
        self:toggle()
    end,
    state = function ()
        return false
    end,
}

function Button:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.center = o.center or {0, 0}
    o.radius = o.radius or 40
    o.border = o.border or 2
    o.colours = o.colours or {
        fg = {0, 0, 0},
        bg = {1, 1, 1},
    }
    return o
end

function Button:draw()
    local bg, fg = self.colours.bg, self.colours.fg
    if self.state() then
        bg, fg = fg, bg
    end
    local x, y = unpack(self.center)
    love.graphics.setColor(fg)
    love.graphics.circle('fill', x, y, self.radius)
    love.graphics.setColor(bg)
    love.graphics.circle('fill', x, y, self.radius - self.border)
    love.graphics.setColor(fg)
    local font = love.graphics.getFont()
    local t = love.graphics.newText(font, self:label())
    local w, h = t:getDimensions()
    love.graphics.print(self:label(), x - w / 2, y - h / 2)
end

button.Button = Button

return button
