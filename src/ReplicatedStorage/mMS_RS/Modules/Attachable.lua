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
	
		holdAnim = "",
		equipTime = 3,
		dropTime = 0.5,
		pickupDistance = 8,	
		interactionKey = Enum.KeyCode.F,
	}
end	


export type Attachable = typeof(setmetatable({} :: self, Attachable))
-------------------------------------------------------------------

-------------------------------------------------------------------

function Attachable.new(fields: Types.AttachableFields): Attachable
	--setup
	local self = setmetatable({} :: self, Attachable)
	self.fields = fields
	setmetatable(self.fields, {__index = ReturnDefaults(fields)})
	self.fields._maid = Maid.new()

	--weld model together if not already welded
	Welder:WeldM(self.fields.model)
	

	return self
end

--- converts the attachable to the specified type and does any necessary cleanup
--- @return the newly converted attachable!!!
function Attachable.ConvertTo(self: Attachable, newForm: string, ...)
	--check if conversion is needed
	if newForm == self.form then return end

	--parent the model to the workspace to avoid destruction alongside form instances
	self.fields.model.Parent = game.Workspace

	--turn off any pickups
	

	--clean up the previous form instances prior to conversion
	self.fields._maid:DoCleaning()

	--call the right method
	if newForm == "Tool" then
		return self:ToTool(...)
	elseif newForm == "Dropped" then
		return self:ToDropped(...)
	elseif newForm == "Embedded" then
		return self:ToEmbedded(...)
	end
end

--- convert the model to a tool with minimal disruption
--- 1. create and parent the model to tool container
--- 2. clone the primaryPart and use it as the handle
--- 3. weld clone and original, add formInstances
--- @return Tool
function Attachable.ToTool(self: Attachable): Tool
	local handle: Instance? = self.fields.model:FindFirstChild("Handle") or self.fields.model.PrimaryPart
	assert(handle, "Either child 'Handle' or PrimaryPart must exist for model to be converted into a tool.")
	assert(self.fields.model.PrimaryPart, "self.fields.model should have a PrimaryPart")
	
	--2: create and parent the model to tool container
	local tool = Instance.new("Tool")
	--3: parent the model to the tool container
	self.fields.model.Parent = tool

	--4: clone the primaryPart and use it as the handle, weld clone and original
	handle = handle:Clone()
	handle.Name = "Handle"
	handle.Parent = tool

	--Insert objects to be destroyed when the form is to be switched
	self.fields._maid:GiveTask(Welder:Weld(handle :: BasePart, self.fields.model.PrimaryPart))
	self.fields._maid:GiveTask(handle)
	return tool
end

--- convert the model to an inert object
function Attachable.ToDropped(self: Attachable)
	
end

--- convert the model to an embedded object
--- @param attach BasePart - the attachment point; the weld will go here
function Attachable.ToEmbedded(self: Attachable, attach: BasePart)
	assert(self.fields.model.PrimaryPart, "self.fields.model should have a PrimaryPart")
	self.fields._maid:GiveTask(Welder:Weld(attach, self.fields.model.PrimaryPart))
end

function Attachable.Destroy(self: Attachable)
	self.fields.model:Destroy()
	self.fields._maid:DoCleaning()
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
