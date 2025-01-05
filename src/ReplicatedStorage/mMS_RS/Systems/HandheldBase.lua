--!strict

--[[
this script is the boilerplate for any tool-based missile launchers. It provides a constructor ( And thats basically it cause tools vary greatly )
]]

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))
local Signal = require(Packages:WaitForChild("Signal"))

----------------------------------------------------------------
local STATE_NAME = "mMS_State"



local HandheldBase = {}
HandheldBase.__index = HandheldBase

type self = {}

export type HandheldBase = typeof(setmetatable({} :: self, HandheldBase)) & Types.MissileSystem

function HandheldBase.new(args: {
    object: Model,
    state: Folder | nil,
}): HandheldBase

    local self = setmetatable({} :: HandheldBase, HandheldBase)
    self.OnFire = Signal.new()
    self.object = args.object


    -- ensure that state exists
    local _state = args.state or args.object:FindFirstChild(STATE_NAME)
    assert(_state and _state:IsA("Folder"), "state doesn't exist for HandheldBase of type " .. self.object.Name)
    
    self.state = _state
    return self
end

--- this should do at minimum 2 things:
--- Initialize the UI
--- Set up the function that fires self.OnFire
function HandheldBase.Setup(self: HandheldBase)
    warn("HandheldBase.Setup should have a custom implementation")
end

--- this should remove anything that shouldn't be here after the tool is unequipped (ui, connections, etc)
function HandheldBase.Cleanup(self: HandheldBase)
    warn("HandheldBase.Cleanup should have a custom implementation")
end


return HandheldBase