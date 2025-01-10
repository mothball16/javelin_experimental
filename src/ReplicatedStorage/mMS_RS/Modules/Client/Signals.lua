--[[
I gave up on oop : ()
Poopy event bus for easier client - client communication
]]

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))

local Signals = {
    --missilecontroller input
    Missile = {
        Fire = Signal.new(),
    },

    System = {
        Setup = Signal.new(),
        Destroy = Signal.new(),
    }

}


return Signals