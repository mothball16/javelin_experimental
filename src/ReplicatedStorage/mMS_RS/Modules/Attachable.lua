--!strict

--[[

- attachables must be able to be generally applied to both: 
already existing models
models yet to be created

attachables must have:
- Equippable (movable)
- 

]]

-------------------------------------------------------------------

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = mMS_RS:WaitForChild("Packages")
local Configs = mMS_RS:WaitForChild("Configs")
local GlobalConfig = require(Configs:WaitForChild("GlobalConfig"))
local Types = require(Modules:WaitForChild("Types"))
local Signal = require(Packages:WaitForChild("Signal"))
local Welder = require(Modules:WaitForChild("Welder"))
local Maid = require(Modules:WaitForChild("Maid"))
-------------------------------------------------------------------

local Attachable = {}
Attachable.__index = Attachable

--object state
type self = {
	form: string,
	formInstances: {any},
	prompts: {[string]: ProximityPrompt},
	fields: Types.AttachableFields,
}

--defaults for the optional config
local function ReturnDefaults(fields: Types.AttachableFields): Types.AttachableConfig
	return {
		name = fields.model.Name,
		attachesTo = {fields.model.Name},
		forms = {
			Tool = true,
			Dropped = true,
			Embedded = true,
		},
	
		dropOnUnequip = true,
		toolOnDetach = true,

		holdAnim = "",
		equipTime = 3,
		detachTime = 0.5,
		interactionDistance = 8,	

	}
end	


export type Attachable = typeof(setmetatable({} :: self, Attachable))
-------------------------------------------------------------------

-------------------------------------------------------------------

--- handle prompt creation boilerplate
local function createPrompt(self: Attachable, parent: Attachment?, params: {
	desc: string,
	bind: Enum.KeyCode,
	timer: number,
	dist: number,
}, func: (player: Player) -> ()): ProximityPrompt
	if not parent then
		local att = Instance.new("Attachment", self.fields.main)
		att.Parent = self.fields.main
		parent = att
	end

	local prox = Instance.new("ProximityPrompt")
	prox.ActionText = params.desc
	prox.HoldDuration = params.timer
	prox.MaxActivationDistance = params.dist
	prox.Parent = parent
	prox.RequiresLineOfSight = false

	self.fields._oMaid:GiveTask(prox.Triggered:Connect(func))
	return prox
end


function Attachable.new(fields: Types.AttachableFields): Attachable
	--setup
	local self = setmetatable({} :: self, Attachable)
	self.fields = fields
	setmetatable(self.fields, {__index = ReturnDefaults(fields)})

	--oMaid for object runtime vars, fMaid for form vars
	self.fields._oMaid, self.fields._fMaid = Maid.new(), Maid.new()
	self.prompts = {}

	--weld model together if not already welded
	Welder:WeldM(self.fields.model)

	self.prompts["Tool"] = createPrompt(self, self.fields.main:FindFirstChild("Drop") :: Attachment?, {
		desc = "Drop " .. self.fields.model.Name,
		bind = GlobalConfig.detachBind,
		timer = self.fields.detachTime :: number,
		dist = self.fields.interactionDistance :: number,
	}, function(player:Player)
		self:ConvertTo(player, "Dropped")
	end)
	
	self.prompts["Dropped"] = createPrompt(self, self.fields.main:FindFirstChild("Equip") :: Attachment?, {
		desc = "Pickup " .. self.fields.model.Name,
		bind = GlobalConfig.detachBind,
		timer = self.fields.equipTime :: number,
		dist = self.fields.interactionDistance :: number,
	}, function(player:Player)
		self:ConvertTo(player, "Tool")
	end)

	self.fields._oMaid:GiveTask(self.fields.model)
	return self
end

--- converts the attachable to the specified type and does any necessary cleanup
--- @return the newly converted attachable!!!
function Attachable.ConvertTo(self: Attachable, player: Player, newForm: string, ...): Instance?
	--parent the model to the workspace to avoid destruction alongside form instances
	self.fields.model.Parent = game.Workspace

	--toggle the pickups
	for _, v in pairs(self.prompts) do
		if v.Name == newForm then
			print(v.Name)
			v.Enabled = true
		else
			v.Enabled = false
		end
	end
	
	--clean up the previous form instances prior to conversion
	self.fields._fMaid:DoCleaning()

	--call the right method
	if newForm == "Tool" then
		return self:ToTool(player, ...)
	elseif newForm == "Dropped" then
		return self:ToDropped(player, ...)
	elseif newForm == "Embedded" then
		return self:ToEmbedded(player, ...)
	end
	
	error("non-form was called for conversion")
end

--- convert the model to a tool with minimal disruption
--- 1. create and parent the model to tool container
--- 2. clone the primaryPart and use it as the handle
--- 3. weld clone and original, add formInstances
--- @return Tool
function Attachable.ToTool(self: Attachable, player: Player): Tool
	local handle: Instance? = self.fields.model:FindFirstChild("Handle") or self.fields.main
	assert(handle, "Either child 'Handle' or PrimaryPart must exist for model to be converted into a tool.")
	
	--2: create and parent the model to tool container
	local tool = Instance.new("Tool")
	tool.CanBeDropped = false
	
	--3: parent the model to the tool container
	self.fields.model.Parent = tool

	--4: clone the primaryPart and use it as the handle, weld clone and original
	handle = handle:Clone()
	handle.Name = "Handle"
	handle.Parent = tool

	tool.Parent = player.Backpack

	--Insert objects to be destroyed when the form is to be switched
	self.fields._fMaid:GiveTask(Welder:Weld(handle :: BasePart, self.fields.main))
	self.fields._fMaid:GiveTask(handle)
	return tool
end

--- convert the model to an inert object
function Attachable.ToDropped(self: Attachable, player: Player)
	return self.fields.model
end

--- convert the model to an embedded object, and attach
--- @param attach BasePart - the attachment point; the weld will go here
function Attachable.ToEmbedded(self: Attachable,  player: Player, attach: BasePart)
	self.fields.model:PivotTo(attach.CFrame)
	local weld = Welder:Weld(attach, self.fields.main)
	self.fields._fMaid:GiveTask(weld)
	return weld
end

function Attachable.Destroy(self: Attachable)
	self.fields._oMaid:DoCleaning()
	self.fields._fMaid:DoCleaning()
end

--[[
function Attachable.GetTree(self: Attachable)
	local tree = {}

	if not next(self.components) then return tree end

	for k, v in pairs(self.components) do
		tree[k] = v:GetTree()
	end
	return tree
end]]


return Attachable
