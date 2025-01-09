--!strict
--[[
Really simple service for replicating object states
]]

local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")

local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(Modules:WaitForChild("Types"))

local DEBUG_MODE = true
local STATE_FOLDER_NAME = "StateFolder"

local StateService = Knit.CreateService({
	Name = "StateService",
	Client = {
		UpdateLauncher = Knit.CreateSignal(),
		OnStateUpdated = Knit.CreateSignal(),
		RequestStateUpdate = Knit.CreateSignal(),
	},
	Data = {}
})

--do vars in KnitInit
function StateService:KnitInit()
	
	print("StateService initalized !!")
end

--- if doesn't exist, init and return created state from default
--- if does exist, return the state
function StateService:Create(config: Instance, default: {["string"]: any}): {["string"]: any}
	local StateID = model:GetAttribute("StateGUID")
	if not StateID then
		
	end
end

function StateService:Get(model: Model)
	local StateID = model:GetAttribute("StateGUID")
	if not StateID then return nil end
end

function StateService:Set()
	
end



return StateService