local Object = require('object')

local Queue = Object:new()
local TweenQueue = Object:new()
local Tween = Object:new()

Queue:augment({
    __init__ = function(self)
        self.first = 0
        self.last = -1
        self.list = {}
    end,

    push = function(self, value)
        self.last = self.last + 1
        self.list[self.last] = value
    end,

    pop = function(self)
        if self.first > self.last then
            return nil
        end
        local value = self.list[self.first]
        self.list[self.first] = nil
        self.first = self.first + 1
        return value
    end,

    head = function(self)
        return self.list[self.first]
    end,

    is_empty = function(self)
        return self.first > self.last
    end,
})

TweenQueue:augment({
    __init__ = function(self)
        self.queue = Queue:new()
    end,

    push = function(self, tween_props)
        self.queue:push(Tween:new(tween_props))
    end,

    update = function(self, dt)
        if dt <= 0 then
            return
        end
        local tween = self.queue:head()
        if tween then
            local finished, rt = tween:update(dt)
            if finished then
                self.queue:pop()
                self:update(rt)
            end
        end
    end,
})

local function easeIn(t)
    return t * t
end

local function easeInOut(t)
    return t * t * (3 - 2 * t)
end

local function easeOut(t)
    return t * (2 - t)
end

local function easeLinear(t)
    return t
end

Tween:augment({
    __init__ = function(self, props)

        self.duration = props.duration or 1
        self.callback = props.callback or function() end
        self.init = props.init or function() end
        self.easing = props.easing or easeLinear

        self.elapsed = 0
        self.started = false
    end,

    update = function(self, dt)
        if not self.started then
            self.started = true
            self.init()
        end
        self.elapsed = self.elapsed + dt
        local progress = self.elapsed / self.duration
        if progress >= 1 then
            self.callback(1)
            return true, (progress - 1) * dt
        else
            self.callback(self.easing(progress))
            return false, 0
        end
    end,
})

return {
    TweenQueue = TweenQueue,
    Tween = Tween,
    easeIn = easeIn,
    easeInOut = easeInOut,
    easeOut = easeOut,
    easeLinear = easeLinear
}