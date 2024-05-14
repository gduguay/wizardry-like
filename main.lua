local maze = require('maze')
local game = require('game')

local Expedition = require('scenes/expedition/expedition')

local scene = Expedition:new(game)

function love.keypressed(key, scancode, isrepeat)
    scene:keypressed(key, scancode, isrepeat)
end

function love.draw()
    -- time the draw
    local start = love.timer.getTime()
    scene:draw(64)
    local finish = love.timer.getTime()
    print("Draw time: " .. (finish - start) * 1000)
end

function love.update(dt)
    scene:update(dt)
end

function love.load()
    love.window.setMode(800, 600)
end