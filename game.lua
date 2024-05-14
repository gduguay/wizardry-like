local Object = require('object')
local maze = require('maze')
local PartyBlob = require('party_blob')

local Game = Object:new()

Game:augment({
    __init__ = function(self)
        self.blob = PartyBlob:new(self, 1, 1)
        self.floor = maze.Floor:new(10, 10)

        -- Add outer walls
        self.floor:add_hwall(1, 1, 7)
        self.floor:add_hwall(6, 1, 6)
        self.floor:add_vwall(1, 1, 7)
        self.floor:add_vwall(6, 1, 6)

        --Add inner walls
        self.floor:add_hwall(2, 2, 5)
        self.floor:add_hwall(4, 2, 3)
        self.floor:add_vwall(2, 2, 5)
        self.floor:add_vwall(4, 2, 3)
        self.floor:add_hwall(2, 4, 5)
        self.floor:add_hwall(4, 4, 5)
        self.floor:add_vwall(2, 4, 5)
        self.floor:add_vwall(4, 4, 5)
    end,

    update = function(self, dt)
        self.blob:update(dt)
    end,
})

local game = Game:new()

return game
