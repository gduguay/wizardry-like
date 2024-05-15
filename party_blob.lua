local Object = require('object')
local lines = require('lines')
local tween = require('tween')

local DIRECTION_VECTORS = {
    down = lines.Vector.down,
    up = lines.Vector.up,
    left = lines.Vector.left,
    right = lines.Vector.right
}

local PartyBlob = Object:new()

PartyBlob:augment({

    __init__ = function(self, game, x, y)
        self.x = x
        self.y = y
        self.coords_x = x
        self.coords_y = y
        self.game = game
        self.direction = 'down'
        self.vector = lines.Vector.down
        self.move_queue = tween.TweenQueue:new()
        self.animation_speed = 0.2
    end,

    direction_vector = function(self)
        return DIRECTION_VECTORS[self.direction]
    end,

    to_string = function(self)
        return "Blob: x = " .. self.x .. ", y = " .. self.y .. ", direction = " .. self.direction .. ", cx = " .. self.coords_x .. ", cy = " .. self.coords_y
    end,

    update = function(self, dt)
        self.move_queue:update(dt)
    end,

    bump = function(self)
        local x, y, vx, vy = self.x, self.y, self.vector.x, self.vector.y
        local bump_factor = 0.2
        self.move_queue:push({
            duration = self.animation_speed / 2,
            init = function()
                x, y = self.x, self.y
            end,
            callback = function(progress)
                -- bump up and back
                self.x = x + vx * progress * bump_factor
                self.y = y + vy * progress * bump_factor
            end,
            easing = tween.easeIn
        })
        self.move_queue:push({
            duration = self.animation_speed / 2,
            init = function()
                x, y = self.x, self.y
            end,
            callback = function(progress)
                -- bump up and back
                self.x = x - vx * progress * bump_factor
                self.y = y - vy * progress * bump_factor
            end,
            easing = tween.easeOut
        })
    end,

    forward = function(self, floor)

        local v = self:direction_vector()

        self.coords_x, self.coords_y = floor:clamp(self.coords_x + v.x, self.coords_y + v.y)

        local start_x = self.coords_x - v.x
        local start_y = self.coords_y - v.y

        self.move_queue:push({
            duration = self.animation_speed,
            init = function()
                self.x = start_x
                self.y = start_y
            end,
            callback = function(progress)
                self.x = start_x + v.x * progress
                self.y = start_y + v.y * progress
            end,
            easing = tween.easeIn
        })
    end,

    spin_around = function(self)

        if(self.direction == 'down') then
            self.direction = 'up'
        elseif(self.direction == 'up') then
            self.direction = 'down'
        elseif(self.direction == 'left') then
            self.direction = 'right'
        elseif(self.direction == 'right') then
            self.direction = 'left'
        end

        local v = self.vector
        self.move_queue:push({
            duration = self.animation_speed * 1.5,
            init = function()
                v = self.vector
            end,
            callback = function(progress)
                self.vector = v:rotate(progress * math.pi)
            end,
            easing = tween.easeIn
        })
    end,

    turn_left = function(self)

        if self.direction == 'down' then
            self.direction = 'right'
        elseif self.direction == 'right' then
            self.direction = 'up'
        elseif self.direction == 'up' then
            self.direction = 'left'
        elseif self.direction == 'left' then
            self.direction = 'down'
        end

        local v = self.vector
        self.move_queue:push({
            duration = self.animation_speed,
            init = function()
                v = self.vector
            end,
            callback = function(progress)
                self.vector = v:rotate(progress * -math.pi / 2)
            end,
            easing = tween.easeIn
        })
    end,

    turn_right = function(self)

        if self.direction == 'down' then
            self.direction = 'left'
        elseif self.direction == 'left' then
            self.direction = 'up'
        elseif self.direction == 'up' then
            self.direction = 'right'
        elseif self.direction == 'right' then
            self.direction = 'down'
        end

        local v = self.vector
        self.move_queue:push({
            duration = self.animation_speed,
            init = function()
                v = self.vector
            end,
            callback = function(progress)
                self.vector = v:rotate(progress * math.pi / 2)
            end,
            easing = tween.easeIn
        })
    end,

})

return PartyBlob