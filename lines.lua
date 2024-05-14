local Object = require('object')

local Ray = Object:new()
local Vector = Object:new()

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- find the intersection of two line segments, if it exists
local function intersect(x1, y1, x2, y2, x3, y3, x4, y4)
    -- calculate the denominator
    local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    -- if the denominator is zero, the lines are parallel
    if den == 0 then
        return nil
    end

    local epsilon = 1e-10

    -- calculate the numerator
    local num_x = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
    local num_y = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)

    -- calculate the intersection point
    local x = num_x / den
    local y = num_y / den

    -- check if the intersection point is within the line segments
    if x >= math.min(x1, x2) - epsilon and x <= math.max(x1, x2) + epsilon and
        x >= math.min(x3, x4) - epsilon and x <= math.max(x3, x4) + epsilon and
        y >= math.min(y1, y2) - epsilon and y <= math.max(y1, y2) + epsilon and
        y >= math.min(y3, y4) - epsilon and y <= math.max(y3, y4) + epsilon then
        return x, y
    end

    -- if the intersection point is not within the line segments, return nil
    return nil
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

Ray:augment({
    __init__ = function(self, x1, y1, x2, y2)
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    end,

    to_string = function(self)
        return "Ray: (" .. self.x1 .. ", " .. self.y1 .. ") -> (" .. self.x2 .. ", " .. self.y2 .. ")"
    end,

    test_horizontal_wall = function(self, wall)
        -- Extracting coordinates from the ray
        local x1_ray, y1_ray, x2_ray, y2_ray = self.x1, self.y1, self.x2, self.y2

        -- Extracting coordinates from the wall
        local y_wall, x1_wall, x2_wall = wall.y, wall.x1, wall.x2

        -- Checking if the ray intersects with the horizontal wall
        if (y1_ray <= y_wall and y2_ray >= y_wall) or (y1_ray >= y_wall and y2_ray <= y_wall) then
            -- Calculating the x-coordinate of the intersection point
            local intersection_x = x1_ray + (y_wall - y1_ray) * (x2_ray - x1_ray) / (y2_ray - y1_ray)

            -- Checking if the intersection point lies within the wall boundaries
            if intersection_x >= x1_wall and intersection_x <= x2_wall then
                return intersection_x, y_wall, wall
            end
        end

        -- If there's no intersection or the intersection point is outside the wall boundaries, return nil
        return nil
    end,

    test_vertical_wall = function(self, wall)
        -- Extracting coordinates from the ray
        local x1_ray, y1_ray, x2_ray, y2_ray = self.x1, self.y1, self.x2, self.y2

        -- Extracting coordinates from the wall
        local x_wall, y1_wall, y2_wall = wall.x, wall.y1, wall.y2

        -- Checking if the ray intersects with the vertical wall
        if (x1_ray <= x_wall and x2_ray >= x_wall) or (x1_ray >= x_wall and x2_ray <= x_wall) then
            -- Calculating the y-coordinate of the intersection point
            local intersection_y = y1_ray + (x_wall - x1_ray) * (y2_ray - y1_ray) / (x2_ray - x1_ray)

            -- Checking if the intersection point lies within the wall boundaries
            if intersection_y >= y1_wall and intersection_y <= y2_wall then
                return x_wall, intersection_y, wall
            end
        end

        -- If there's no intersection or the intersection point is outside the wall boundaries, return nil
        return nil
    end

})

Vector.left = Vector:new(-1, 0)
Vector.right = Vector:new(1, 0)
Vector.up = Vector:new(0, -1)
Vector.down = Vector:new(0, 1)

return {
    Vector = Vector,
    Ray = Ray,
    distance = distance,
    intersect = intersect
}
