local Scene = require('../../scene')
local Camera = require('../../camera')
local lines = require('../../lines')
local trig = require('../../trig')

local Expedition = Scene:new()

Expedition:augment({
    
    __init__ = function(self, game)
        self.game = game
        self.camera = Camera:new(2 * math.pi / 4, 800, 240)
    end,

    draw = function(self, scale)
        local p = self.game.blob
        local f = self.game.floor
        local cam = self.camera

        local half_scale = scale / 2

        f:draw_at(0, 0, half_scale)

        love.graphics.setColor(0, 1, 1)
        love.graphics.circle('fill', p.x * half_scale + half_scale / 2, p.y * half_scale + half_scale / 2, half_scale / 4)

        love.graphics.setColor(1, 1, 1)

        cam.x = 0.5 + p.x - p.vector.x * 0.45
        cam.y = 0.5 + p.y - p.vector.y * 0.45

        love.graphics.print(p:to_string(), 0, 0)
        love.graphics.print('Blob vector: ' .. p.vector:to_string(), 0, 20)
        love.graphics.print('Camera x: ' .. cam.x .. ' y: ' .. cam.y, 0, 40)
        love.graphics.print('Facing wall? ' .. (f:wall_at(p.coords_x, p.coords_y, p.direction) and 'yes' or 'no'), 0, 60)


        local setColor = love.graphics.setColor
        local line = love.graphics.line

        for x1, y1, x2, y2, i, dg in self.camera:cast_rays(p.vector:angle(), 3.5) do
            if i % 50 == 0 then
                setColor(1, 0, 0)
                line(cam.x * half_scale, cam.y * half_scale, x2 * half_scale, y2 * half_scale)
            end
        end

        local math_min = math.min
        local cos = trig.cos

        for x1, y1, x2, y2, i, dg in self.camera:cast_rays(p.vector:angle(), 3.5) do
            
            local hcx, hcy, hcwall = f:test_horizontal_walls(x1, y1, x2, y2, dg, self.game.floor)
            local vcx, vcy, vcwall = f:test_vertical_walls(x1, y1, x2, y2, dg, self.game.floor)

            if vcwall and hcwall then
                local dh = lines.distance(x1, y1, hcx, hcy)
                local dv = lines.distance(x1, y1, vcx, vcy)
                local d = math_min(dh, dv) * cos(dg)
                local s = 1.5 * scale / d
                local color = s / 250
                setColor(color, color, color)
                line(i, 300 - s, i, 300 + s)
            elseif hcwall then
                local d = lines.distance(x1, y1, hcx, hcy) * cos(dg)
                local s = 1.5 * scale / d
                local color = s / 250
                setColor(color, color, color)
                line(i, 300 - s, i, 300 + s)
            elseif vcwall then
                local d = lines.distance(x1, y1, vcx, vcy) * cos(dg)
                local s = 1.5 * scale / d
                local color = s / 250
                setColor(color, color, color)
                line(i, 300 - s, i, 300 + s)
            end
        end

        love.graphics.setColor(1, 1, 1)
    end,

    update = function(self, dt)
        self.game:update(dt)
    end,

    keypressed = function(self, key, scancode, isrepeat)
        if key == 'w' or key == 'up' then
            if self.game.floor:wall_at(self.game.blob.coords_x, self.game.blob.coords_y, self.game.blob.direction) then
                self.game.blob:bump()
                return
            end
            self.game.blob:forward(self.game.floor)
        elseif key == 'a' or key == 'left' then
            self.game.blob:turn_left()
        elseif key == 'd' or key == 'right' then
            self.game.blob:turn_right()
        elseif key == 's' or key == 'down' then
            self.game.blob:spin_around()
        end
    end
})

return Expedition