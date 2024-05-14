local m = require('memoize')

local memod = {
    sin = m.memoize(math.sin),
    cos = m.memoize(math.cos),
    tan = m.memoize(math.tan),
    atan2 = m.memoize(math.atan2),
}

local raw = {
    sin = math.sin,
    cos = math.cos,
    tan = math.tan,
    atan2 = math.atan2,
}

return raw