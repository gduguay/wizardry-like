local Object = require("object")
local lines = require("lines")

Maze = Object:new()
Floor = Object:new()
HorizontalWall = Object:new()
VerticalWall = Object:new()
Encounter = Object:new()

HorizontalWall:augment({
    __init__ = function(self, y, x1, x2)
        self.y = y
        self.x1 = x1
        self.x2 = x2
    end,

    to_string = function(self)
        return "HorizontalWall: y = " .. self.y .. ", x1 = " .. self.x1 .. ", x2 = " .. self.x2
    end
})

VerticalWall:augment({
    __init__ = function(self, x, y1, y2)
        self.x = x
        self.y1 = y1
        self.y2 = y2
    end,

    to_string = function(self)
        return "VerticalWall: x = " .. self.x .. ", y1 = " .. self.y1 .. ", y2 = " .. self.y2
    end
})

local function test_vertical_walls(x1, y1, x2, y2, _, floor)

    local dx = x2 - x1
    local dy = y2 - y1

    if dx == 0 then
        return
    end

    local next_x

    if dx > 0 then
        next_x = math.floor(x1) + 1
    else
        next_x = math.ceil(x1) - 1
    end

    local next_y = y1 + (next_x - x1) * dy / dx

    local found, wall = floor:vwall_at(next_x, next_y)

    if found then
        return next_x, next_y, wall
    end

    while true do

        if dx > 0 then
            next_x = next_x + 1
            next_y = next_y + dy / dx
        else 
            next_x = next_x - 1
            next_y = next_y - dy / dx
        end


        if dx > 0 and next_x > x2 then return nil end
        if dx < 0 and next_x < x2 then return nil end
        if dy > 0 and next_y > y2 then return nil end
        if dy < 0 and next_y < y2 then return nil end

        found, wall = floor:vwall_at(next_x, next_y)

        if found then
            return next_x, next_y, wall
        end
    end
end

local function test_horizontal_walls(x1, y1, x2, y2, _, floor)

    local dx = x2 - x1
    local dy = y2 - y1

    if dy == 0 then
        return
    end

    local next_y

    if dy > 0 then
        next_y = math.floor(y1) + 1
    else
        next_y = math.ceil(y1) - 1
    end

    local next_x = x1 + (next_y - y1) * dx / dy

    local found, wall = floor:hwall_at(next_x, next_y)

    if found then
        return next_x, next_y, wall
    end

    while true do

        if dy > 0 then
            next_y = next_y + 1
            next_x = next_x + dx / dy
        else 
            next_y = next_y - 1
            next_x = next_x - dx / dy
        end


        if dy > 0 and next_y > y2 then return nil end
        if dy < 0 and next_y < y2 then return nil end
        if dx > 0 and next_x > x2 then return nil end
        if dx < 0 and next_x < x2 then return nil end

        found, wall = floor:hwall_at(next_x, next_y)

        if found then
            return next_x, next_y, wall
        end
    end
end


Floor:augment({
    __init__ = function(self, w, h)
        self.width = w
        self.height = h
        self.hwalls = {}
        self.vwalls = {}
        for x = 1, w + 1, 1 do
            self.vwalls[x] = {}
        end
        for y = 1, h + 1, 1 do
            self.hwalls[y] = {}
        end
    end,

    add_hwall = function(self, y, x1, x2)
        table.insert(self.hwalls[y], HorizontalWall:new(y, x1, x2))
    end,

    add_vwall = function(self, x, y1, y2)
        table.insert(self.vwalls[x], VerticalWall:new(x, y1, y2))
    end,

    test_horizontal_walls = function(self, x1, y1, x2, y2, dg)
        return test_horizontal_walls(x1, y1, x2, y2, dg, self)
    end,

    test_vertical_walls = function(self, x1, y1, x2, y2, dg)
        return test_vertical_walls(x1, y1, x2, y2, dg, self)
    end,

    draw_at = function(self, x, y, scale)
        for cy = 1, self.height + 1, 1 do
            for _, wall in ipairs(self.hwalls[cy]) do
                love.graphics.line(x + wall.x1 * scale, y + wall.y * scale, x + wall.x2 * scale, y + wall.y * scale)
            end
        end
        for cx = 1, self.width + 1, 1 do
            for _, wall in ipairs(self.vwalls[cx]) do
                love.graphics.line(x + wall.x * scale, y + wall.y1 * scale, x + wall.x * scale, y + wall.y2 * scale)
            end
        end
    end,

    wall_at = function(self, x, y, direction)
        if direction == 'up' then
            return self:hwall_at(x + 0.5, y)
        elseif direction == 'down' then
            return self:hwall_at(x + 0.5, y + 1)
        elseif direction == 'left' then
            return self:vwall_at(x, y + 0.5)
        elseif direction == 'right' then
            return self:vwall_at(x + 1, y + 0.5)
        end
    end,

    hwall_at = function(self, x, y)
        if y < 1 or y > self.height + 1 then
            return false
        end
        local walls = self.hwalls[y]
        if not walls then
            error("No walls at y = " .. y .. " . " .. self.height)
        end
        for _, wall in ipairs(self.hwalls[y]) do
            if x >= wall.x1 and x <= wall.x2 then
                return true, wall
            end
        end
        return false
    end,

    vwall_at = function(self, x, y)
        if x < 1 or x > self.width + 1 then
            return false
        end
        local walls = self.vwalls[x]
        if not walls then
            error("No walls at x = " .. x .. " . " .. self.width)
        end
        for _, wall in ipairs(self.vwalls[x]) do
            if y >= wall.y1 and y <= wall.y2 then
                return true, wall
            end
        end
        return false
    end
})

return {
    Maze = Maze,
    Floor = Floor,
    HorizontalWall = HorizontalWall,
    VerticalWall = VerticalWall,
}
