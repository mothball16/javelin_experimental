--!strict

--[[
this script is the boilerplate for any tool-based missile launchers. It provides a constructor ( And thats basically it cause tools vary greatly )
]]


local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))
local Signal = require(Packages:WaitForChild("Signal"))
local Maid = require(Modules:WaitForChild("Maid"))
local GlobalConfig = require(mMS_RS:WaitForChild("Configs"):WaitForChild("GlobalConfig"))
----------------------------------------------------------------



local HandheldBase = {}
HandheldBase.__index = HandheldBase

type self = {}

export type HandheldBase = typeof(setmetatable({} :: self, HandheldBase)) & Types.MissileSystem

function HandheldBase.new(args: {object: Model}): HandheldBase
    --args.state = args.object:FindFirstChild(GlobalConfig.stateName)
    local self = setmetatable({} :: HandheldBase, HandheldBase)

    self._maid = Maid.new()
    self.OnFire = Signal.new()
    self._maid:GiveTask(self.OnFire)

    self.object = args.object



   -- self.state = self.object:FindFirstChild(GlobalConfig.stateName :: string) :: Folder
    return self
end


--- this should do at minimum 2 things:
--- Initialize the UI
--- Set up the function that fires self.OnFire
function HandheldBase.Setup(self: HandheldBase)
    warn("HandheldBase.Setup should have a custom implementation")
end

--- this should remove anything that shouldn't be here after the tool is unequipped (ui, connections, etc)
function HandheldBase.Destroy(self: HandheldBase)
    warn("HandheldBase.Cleanup should have a custom implementation")
end


return HandheldBase