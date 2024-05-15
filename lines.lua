local Object = require('object')

local Vector = Object:new()

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

Vector:augment({
    __init__ = function(self, x, y)
        self.x = x
        self.y = y
    end,

    to_string = function(self)
        return "Vector: (" .. self.x .. ", " .. self.y .. ")"
    end,

    invert = function(self)
        return Vector:new(-self.x, -self.y)
    end,

    angle = function(self)
        return math.atan2(self.y, self.x)
    end,

    rotate = function(self, angle)
        local cos = math.cos(angle)
        local sin = math.sin(angle)
        local x = self.x * cos - self.y * sin
        local y = self.x * sin + self.y * cos
        return Vector:new(x, y)
    end,

    -- cast rays from a point in the vector's direction
    cast_rays_it = function(self, at_x, at_y, count, arc, mag)
        local arc = arc or math.pi * 2 / 3
        local vangle = self:angle()
        local angle = vangle
        return coroutine.wrap(function()
            for i = 1, count, 1 do
                local step = (i - 1) / (count - 1) - 0.5
                coroutine.yield(at_x, at_y, at_x + math.cos(angle) * mag, at_y + math.sin(angle) * mag, i, vangle - angle)
                angle = vangle + step * arc -- Increment the angle by the step size
            end
        end)
    end,
})

Vector.left = Vector:new(-1, 0)
Vector.right = Vector:new(1, 0)
Vector.up = Vector:new(0, -1)
Vector.down = Vector:new(0, 1)

return {
    Vector = Vector,
    distance = distance
}
