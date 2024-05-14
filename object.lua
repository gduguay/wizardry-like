Object = {}

function Object:new(...)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if self.__init__ then self.__init__(o, ...) end
    return o
end

function Object:__init__(...)
    -- This method can be overridden in subclasses to initialize the object
end

function Object:augment(methods)
    for k, v in pairs(methods) do
        self[k] = v
    end
end

return Object