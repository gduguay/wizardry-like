local Object = require('object')
local maze = require('maze')
local PartyBlob = require('party_blob')

local Game = Object:new()

Game:augment({
    __init__ = function(self)
        self.blob = PartyBlob:new(self, 3, 3)
        self.floor = maze.Floor:new(10, 10)

        -- Add outer walls
        self.floor:add_hwall(2, 2, 5)
        self.floor:add_hwall(2, 6, 10)
        self.floor:add_hwall(10, 2, 5)
        self.floor:add_hwall(10, 6, 10)

        self.floor:add_hwall(5, 10, 11)
        self.floor:add_hwall(5, 1, 2)
        self.floor:add_hwall(6, 10, 11)
        self.floor:add_hwall(6, 1, 2)

        self.floor:add_vwall(2, 2, 5)
        self.floor:add_vwall(2, 6, 10)
        self.floor:add_vwall(10, 2, 5)
        self.floor:add_vwall(10, 6, 10)

        self.floor:add_vwall(5, 10, 11)
        self.floor:add_vwall(5, 1, 2)
        self.floor:add_vwall(6, 10, 11)
        self.floor:add_vwall(6, 1, 2)

    end,

    update = function(self, dt)
        self.blob:update(dt)
    end,
})

local game = Game:new()

return game
