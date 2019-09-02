-- Copyright 2019, Mansour Moufid <mansourmoufid@gmail.com>

local love = require('love')

local array = require('array')
local button = require('button')
local chirpy = require('chirpy')
local fibonacci = require('fibonacci')
local mobile = require('mobile')
local nu = require('libnu')
local str = require('str')
local utf8 = require('utf8')

local state = {
    chirp = {
        band = {2000, 8000},
        duration = 1 / 4,
        size = 0,
    },
    codes = {
        ETX = 0x03,
        STX = 0x02,
    },
    debug = true,
    init = false,
    input = {
        caret = '▎',
        ctrl = false,
    },
    log = {},
    mic = {
        device = nil,
        format = nil,
        formats = {
            16,
            8,
        },
        max = 0,
        nsamples = 0,
        read = {0, 0},
        samplecount = 0,
        samplecounts = {
            2 ^ 16,
            2 ^ 15,
            2 ^ 14,
            2 ^ 13,
            2 ^ 12,
            2 ^ 11,
            2 ^ 10,
        },
        samplerate = 0,
        samplerates = {
--          48000,
--          44100,
--          44056,
--          37800,
            32000,
            22050,
            16000,
--          11025,
--          8000,
        },
    },
    mics = {},
    pointers = {
        chirp0 = 'float',
        chirp1 = 'float',
        samples = 'float',
        xcor0 = 'float',
        xcor1 = 'float',
        CHIRP0 = 'nu_complex',
        CHIRP1 = 'nu_complex',
        SAMPLES = 'nu_complex',
        XCOR0 = 'nu_complex',
        XCOR1 = 'nu_complex',
    },
    rx = {
        state = false,
        bits = {},
        bytes = {},
        text = {
            '',
        },
    },
    tx = {
        bits = {},
        bytes = {},
        text = '',
    },
    window = {
        colours = {
            bg = {0.8, 0.8, 0.8},
            fg = {0.1, 0.1, 0.1},
            hl = {0.3, 0.3, 0.5, 0.5},
        },
        flags = {
            fullscreen = mobile,
            highdpi = true,
            minheight = 320,
            minwidth = 320,
            msaa = 2,
            resizable = true,
            vsync = true,
        },
        fonts = {
            default = {'fonts/DejaVuSans.ttf', 16},
            big = {'fonts/DejaVuSans.ttf', 22},
        },
        fps = 0,
        title = 'Chirpy',
    },
    xcor = {
        size = 0,
    },
}

local function log(x)
    if type(x) == 'table' then
        for _, y in ipairs(x) do
            log(y)
        end
    else
        state.log[#state.log + 1] = tostring(x)
        io.write(tostring(x), '\n')
    end
end

local function plot(box, x, n)
    local x0, y0, w, h = unpack(box)
    if x == nil then
        return
    end
    assert(w < n)
    local l = math.floor(n / w)
    local min = nu.array.min(x, n)
    local max = nu.array.max(x, n)
    local maxy = math.max(math.abs(min), math.abs(max))
    if maxy == 0 then
        maxy = 1
    end
    for j = 0, w - 2 do
        assert(j * l + l < n)
        min = nu.array.min(x + j * l, l)
        max = nu.array.max(x + j * l, l)
        min = min / maxy
        max = max / maxy
        local x1 = x0 + j
        local x2 = x1
        local y1 = y0 - (h / 2) * max
        local y2 = y0 - (h / 2) * min
        love.graphics.line(x1, y1, x2, y2)
    end
end

local Button = button.Button
local buttons = {
    debug = Button:new({
        label = function (self)
            return 'debug'
        end,
        radius = 40,
        resize = function (self, w, h)
            self.center = {w / 4, h / 2}
        end,
        state = function (self)
            return state.debug
        end,
        toggle = function (self)
            state.debug = not state.debug
        end,
    }),
    mic = Button:new({
        label = function (self)
            return 'mic' .. ' ' .. (state.rx.state and 'on' or 'off')
        end,
        radius = 40,
        resize = function (self, w, h)
            self.center = {w / 2, h / 2}
        end,
        state = function (self)
            return state.rx.state
        end,
        toggle = function (self)
            state.rx.state = not state.rx.state
        end,
    }),
    keyboard = Button:new({
        label = function (self)
            return 'keyboard'
        end,
        radius = 40,
        resize = function (self, w, h)
            self.center = {3 * w / 4, h / 2}
        end,
        state = love.keyboard.hasTextInput,
        toggle = function (self)
            love.keyboard.setTextInput(not self.state())
        end,
    }),
}

function love.load()
    love.window.setTitle(state.window.title)
    local width, height = 480, 640
    love.window.setMode(width, height, state.window.flags)
    if mobile then
        width, height = love.graphics.getDimensions()
    end
    love.resize(width, height)
    state.threads = {
        play = love.thread.newThread('play.lua'),
        read = love.thread.newThread('read.lua'),
        xcor = love.thread.newThread('xcor.lua'),
    }
    state.load = love.thread.newThread('load.lua')
    state.load:start(chirpy.sendstate(state))
end

function love.update(dt)
    state.window.fps = love.timer.getFPS()
    if dt < 1 / 30 then
        love.timer.sleep(1 / 30 - dt)
    end
    if not state.init then
        local s = love.thread.getChannel('load'):pop()
        if s ~= nil then
            state = chirpy.getstate(s)
            for t, x in pairs(state.threads) do
                x:start(chirpy.sendstate(state))
                love.thread.getChannel('log'):push(
                    'thread "' .. t .. '" started'
                )
            end
            for i, f in pairs(state.window.fonts) do
                state.window.fonts[i] = love.graphics.newFont(unpack(f))
            end
            love.keyboard.setKeyRepeat(true)
            love.thread.getChannel('read.tick'):push(true)
            state.init = true
        end
        return
    end
    for _, b in pairs(buttons) do
        b:update(dt)
    end
    local x = love.thread.getChannel('log'):pop()
    if x ~= nil then
        log(x)
    end
    local tock = love.thread.getChannel('read.tock'):pop()
    if tock ~= nil then
        love.thread.getChannel('read.tick'):push(true)
        if state.rx.state then
            love.thread.getChannel('xcor.tick'):push(true)
        end
    end
    local read = love.thread.getChannel('read.stat'):pop()
    if read ~= nil then
        state.mic.read = read
        local a, b = unpack(state.mic.read)
        if b - a > 0 then
            state.mic.max = nu.array.max(state.samples + a, b - a)
        end
    end
    local bit = love.thread.getChannel('bits'):pop()
    if bit ~= nil then
        if bit == 0 or bit == 1 then
            state.rx.bits[#state.rx.bits + 1] = bit
        else
            state.rx.bits = {}
        end
        if array.equal(array.last(state.rx.bits, 2), {1, 1}) then
            local byte = fibonacci.decode(state.rx.bits)
            log(str.join(' ', {
                'received',
                str.join('', state.rx.bits),
                byte,
            }))
            if byte == 0 then
            elseif byte == state.codes.STX then
                state.rx.text[#state.rx.text] = ''
            elseif byte == state.codes.ETX then
                state.rx.text[#state.rx.text + 1] = ''
                state.rx.bytes = {}
            else
                state.rx.bytes[#state.rx.bytes + 1] = byte
                local text = utf8.char(unpack(state.rx.bytes))
                state.rx.text[#state.rx.text] = text
            end
            state.rx.bits = {}
        end
    end
    local tx = love.thread.getChannel('tx'):pop()
    if tx ~= nil then
        log('sending ' .. '"' .. state.tx.text .. '"')
        local stx = utf8.char(state.codes.STX)
        local etx = utf8.char(state.codes.ETX)
        state.tx.text = stx .. state.tx.text .. etx
        for _, c in utf8.codes(state.tx.text) do
            local bits =  fibonacci.encode(c)
            log(str.join(' ', {
                '    ',
                c,
                str.join('', bits),
            }))
            love.thread.getChannel('play.tick'):push(bits)
        end
        state.tx.text = ''
    end
end

function love.draw()
    local window = state.window
    local colours = window.colours
    local w, h, x, y
    love.graphics.setColor(colours.bg)
    love.graphics.rectangle('fill', 0, 0, window.width, window.height)
    local line = {
        height = 20,
    }
    if not state.init then
        return
    end
    local font = state.window.fonts.default
    if font ~= nil then
        love.graphics.setFont(font)
        line.height = font:getHeight() * font:getLineHeight()
    end
    if state.debug then
        love.graphics.setColor(colours.hl)
        w = window.width
        h = 100
        x = 0
        y = window.height - 2 * h
        plot({x, y, w, h}, state.xcor0, state.xcor.size)
        plot({x, y + h, w, h}, state.xcor1, state.xcor.size)
        y = y + h / 2
        for i = 1, state.mic.nsamples / state.chirp.size do
            local a = state.chirp.size / 2
            x = (a + (i - 1) * state.chirp.size) / state.xcor.size * w
            love.graphics.line(x, y - h, x, y + h)
            love.graphics.print(i, x, y - h)
        end
        for i, text in ipairs(state.log) do
            x = 20
            y = window.height - (#state.log - i + 2) * line.height
            love.graphics.print(text, x, y)
        end
        love.graphics.print(state.window.fps .. ' fps', w - 80, 10)
        local a, b = unpack(state.mic.read)
        local n = state.mic.nsamples
        x = a / n * window.width
        y = 0
        w = (b - a) / n * window.width
        h = line.height
        love.graphics.rectangle('fill', x, y, w, h)
        love.graphics.rectangle(
            'fill',
            0,
            h,
            window.width * state.mic.max,
            h
        )
    end
    for _, b in pairs(buttons) do
        b:draw()
    end
    font = state.window.fonts.big
    if font ~= nil then
        love.graphics.setFont(font)
        line.height = font:getHeight() * font:getLineHeight()
    end
    w = window.width
    h = line.height
    x = w / 4
    y = window.height / 4
    love.graphics.setColor(colours.fg)
    for i, text in pairs(array.reverse(state.rx.text)) do
        love.graphics.print('▶', x - 30, y - (i + 1) * h)
        love.graphics.print(text, x, y - (i + 1) * h)
    end
    if buttons.keyboard:state() then
        colours.bg, colours.fg = colours.fg, colours.bg
        love.graphics.setColor(colours.bg)
        love.graphics.rectangle('fill', 0, y, w, h)
        love.graphics.setColor(colours.fg)
        love.graphics.print('▶', x - 30, y)
        local text = state.tx.text .. state.input.caret
        love.graphics.print(text, x, y)
        colours.bg, colours.fg = colours.fg, colours.bg
    end
end

local function stop()
    state.rx.state = false
    for t, _ in pairs(state.threads) do
        love.thread.getChannel(t .. '.tick'):clear()
        love.thread.getChannel(t .. '.tock'):clear()
        love.thread.getChannel(t .. '.tick'):push(false)
    end
end

local function quit()
    for _, x in pairs(state.threads) do
        x:wait()
    end
    if state.mic.device ~= nil then
        state.mic.device:stop()
    end
    love.audio.stop()
    love.event.quit()
end

function love.keypressed(key)
    for _, k in pairs({'lctrl', 'rctrl', 'lgui', 'rgui'}) do
        if k == key then
            state.input.ctrl = true
        end
    end
    if key == 'v' and state.input.ctrl then
        state.tx.text = state.tx.text .. love.system.getClipboardText()
    end
    if key == 'return' then
        love.thread.getChannel('tx'):push(true)
    end
    if key == 'backspace' then
        local i = utf8.offset(state.tx.text, -1)
        if i ~= nil then
            state.tx.text = string.sub(state.tx.text, 1, i - 1)
        end
    end
    if key == 'escape' then
        stop()
    end
end

function love.keyreleased(key)
    for _, k in pairs({'lctrl', 'rctrl', 'lgui', 'rgui'}) do
        if k == key then
            state.input.ctrl = false
        end
    end
    if key == 'escape' then
        quit()
    end
end

function love.mousepressed(x, y)
    for _, b in pairs(buttons) do
        b:mousepressed(x, y)
    end
end

function love.mousereleased(x, y)
    for _, b in pairs(buttons) do
        b:mousereleased(x, y)
    end
end

function love.resize(w, h)
    state.window.width = w
    state.window.height = h
    for _, b in pairs(buttons) do
        b:resize(w, h)
    end
end

function love.textinput(t)
    state.tx.text = state.tx.text .. t
end
