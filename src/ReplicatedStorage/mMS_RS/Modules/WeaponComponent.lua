--!strict

--[[
WeaponComponents are used to attach parts of a tool separately so that it looks like it's being "loaded/unloaded"
]]

local WeaponComponent = {}
-------------------------------------------------------------------

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Welder = require(Packages:WaitForChild("Welder"))
-------------------------------------------------------------------


WeaponComponent.__index = WeaponComponent


type self = {
	model: Model,
	attached: boolean,
	components: {WeaponComponent},
	StateChanged: Signal.Signal<any>
}



export type WeaponComponent = typeof(setmetatable({} :: self, WeaponComponent))
-------------------------------------------------------------------
local OPACITY_ATTR = "mMS_OriginalTransparency"


-------------------------------------------------------------------


function WeaponComponent.new(model: Model, components: {WeaponComponent})	
	local self = setmetatable({} :: self, WeaponComponent)
	-- set up model
	self.model = model:Clone()
	Welder:WeldM(self.model)

	for _,part in self.model:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part:SetAttribute(OPACITY_ATTR,part.Transparency)
		end
	end

	--set up child components
	self.components = components
	if self.components[1] then
		local folder = Instance.new("Folder")
		folder.Parent = self.model
		folder.Name = "Components"
	end

	-- set up signals
	self.StateChanged = Signal.new()
	
	return self
end


function WeaponComponent:Toggle(on: boolean)
	for _,part in self.model:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("MeshPart") then
			part.Transparency = on and part:GetAttribute(OPACITY_ATTR) or 1
		end
	end

	self.attached = on
	self.StateChanged:Fire()

	--if the parent component is gone, the children components should be gone too
	if not on then
		for _, children in self.components do
			children:Toggle(on)
		end
	end
	
end

function WeaponComponent:Attach(handle: BasePart)
	local tool = handle.Parent :: Model | Tool
	self.model.Parent = tool:FindFirstChild("Components") or tool
	self:Toggle(self.attached)
end



return WeaponComponent
