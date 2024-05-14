local Object = require('object')
local trig = require('trig')

local Camera = Object:new()

Camera:augment({

    __init__ = function(self, fov, ppWidth, ppHeight)
        self.fov = fov
        self.ppWidth = ppWidth
        self.ppHeight = ppHeight
        self.x = 0
        self.y = 0
    end,

    cast_rays = function(self, angle, mag)
        local forward_x = trig.cos(angle);
        local forward_y = trig.sin(angle);

        local right_x = forward_y
        local right_y = -forward_x

        local halfWidth = trig.tan(self.fov / 2.0);

        local w = self.ppWidth

        return coroutine.wrap(function()
            local atan2 = trig.atan2
            local pi = math.pi
            for i = 1, w, 1 do
                local offset = (1.0 - (i * 2 / (w + 1))) * halfWidth

                local ray_vector_x = forward_x + offset * right_x;
                local ray_vector_y = forward_y + offset * right_y;

                local ray_angle = atan2(ray_vector_y, ray_vector_x)
                local delta_angle = angle - ray_angle
                delta_angle = ((delta_angle + pi) % (2 * pi)) - pi

                coroutine.yield(self.x, self.y, self.x + ray_vector_x * mag, self.y + ray_vector_y * mag, i, delta_angle)
            end
        end)
    end,

})

return Camera
