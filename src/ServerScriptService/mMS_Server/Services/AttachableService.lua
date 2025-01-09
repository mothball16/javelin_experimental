--!strict

local HTTPS = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")

local Maid = require(Modules:WaitForChild("Maid"))
local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(Modules:WaitForChild("Types"))
local Attachable = require(Modules:WaitForChild("Attachable"))
local Welder = require(Modules:WaitForChild("Welder"))

----------------------------------------------------------------------
local ATT_FOLDER = mMS_RS:WaitForChild("Models"):WaitForChild("Attachables")
local ATT_CONFIGS = mMS_RS:WaitForChild("Configs"):WaitForChild("Attachables")
----------------------------------------------------------------------
local DEBUG_MODE = true

local AttachableService = {
	Name = "AttachableService",
	Configs = {},
	Registry = {},
	
}

local function unpackNestedFolder(folder: Folder)

	local function traverse(obj: any): ()
		if obj:IsA("Folder") then
			for _, v in pairs(obj:GetChildren()) do
				traverse(v)
			end
		else
			obj.Parent = folder
		end
	end

	--look thru folders and parent any non folders to the main folder
	traverse(folder)

	--cleanup remaining folders
	for _,v in pairs(folder:GetChildren()) do
		if v:IsA("Folder") then v:Destroy() end
	end

	return {}
end
--do vars in KnitInit
function AttachableService:KnitInit()
	--unpack the folder structure
	unpackNestedFolder(ATT_CONFIGS)
	unpackNestedFolder(ATT_FOLDER)


	for _,v in pairs(ATT_CONFIGS:GetChildren()) do
		if not v:IsA("ModuleScript") then continue end
		--hacky intellisense fix
		local conf: any = require(v) :: any
		
		for name, data in pairs(conf) do
			if self.Configs[name] then
				warn("duplicate config match: " .. name .. " will be overwritten")
			end
			self.Configs[name] = data
		end

	end
	
	print("AttachableService initalized !!")
end


function AttachableService:Get(att: string)
	local model = ATT_FOLDER:FindFirstChild(att)
	local conf = self.Configs[att]
	if not (conf and model) then
		error("attachable " .. att .. " either has a missing config, missing model, or both.")
	end
	return model, conf
end

--- given the info to create the attachable, register and set it up (Separated so that already existing models can be set up)
function AttachableService:Register(model: Model, conf: Types.AttachableConfig): Attachable.Attachable
	--set up attachableFields
	assert(model.PrimaryPart,"model must have a primary part")
	conf["model"] = model
	conf["main"] = model.PrimaryPart
	local attachable = Attachable.new(conf :: Types.AttachableFields)
	local ID = HTTPS:GenerateGUID()
	attachable.fields.model:SetAttribute("Identification", ID)
	self.Registry[ID] = attachable 
	return attachable
end

--- create an attachable the usual way
function AttachableService:Create(att: string, overrides: Types.AttachableConfig?): (Attachable.Attachable, Model)
	local model, conf = AttachableService:Get(att)
	model = model:Clone()
	-- init fields
	return self:Register(model, conf), model
end



--[[
-- join two attachables
function AttachableService:JoinAttachable(): WeldConstraint
	
end

function AttachableService:HandleAction(player: Player, object: Attachable.Attachable)
	
end]]




return AttachableService