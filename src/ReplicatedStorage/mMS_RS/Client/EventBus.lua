--!strict

--[[
Poopy event bus for easier client - client communication
]]

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = RS:WaitForChild('mMS_RS')
local Modules = mMS_RS:WaitForChild("Modules")

local Signal = require(Packages:WaitForChild("Signal"))
local Types = require(Modules:WaitForChild("Types"))


local EventBus = {
    Missile = {
        --for telling the server you did x, y, z...
        SendCreationRequest = Signal.new(),
        SendDestroyRequest = Signal.new(),
        --removed, missileHandler should be doing any update logic internally
        --SendUpdateRequest = Signal.new(),


        --[[ archived, thishas been delegated to Network
        --on replication connections
        OnFired = Signal.new(),
        OnUpdated = Signal.new(),
        OnDestroyed = Signal.new(),
        ]]
    },


    Generic = {},
}

setmetatable(EventBus,{__index = function(index: string)
    if not EventBus.Generic[index] then 
        warn("the signal (".. index .. ") doesn't exist! due to intellisense limitations i can't dynamically create these like how an eventbus should work so this will just return a placeholder signal i guess its useable but you probably shouldnt....")
        EventBus.Generic[index] = Signal.new()
    end
    return EventBus.Generic[index]
end})


return EventBus