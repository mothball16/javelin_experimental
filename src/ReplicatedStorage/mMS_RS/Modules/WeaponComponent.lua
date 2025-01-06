--!strict

--[[
- A launcher should have one main WeaponComponent to communicate the state of the weapon assembly
- Components cache and maintain the ability to attach and detach child components
- Any component can return a tree including itself and any lower components
]]

-------------------------------------------------------------------

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = RS:WaitForChild("Packages")
local Types = require(Modules:WaitForChild("Types"))
local Signal = require(Packages:WaitForChild("Signal"))
local Welder = require(Modules:WaitForChild("Welder"))
-------------------------------------------------------------------

local WeaponComponent = {}
WeaponComponent.__index = WeaponComponent


type self = {
	name: string,
	model: Model,
	attached: boolean,
	components: {[string]: WeaponComponent},
	weld: WeldConstraint,
}



export type WeaponComponent = typeof(setmetatable({} :: self, WeaponComponent))
-------------------------------------------------------------------

-------------------------------------------------------------------


function WeaponComponent.new(args: Types.WeaponComponentConfig): WeaponComponent
	assert(args.attach.Parent, "attach is parented to nil")
	local self = setmetatable({} :: self, WeaponComponent)
	local container = args.attach.Parent
	
	--overload for converting incomplete child components
	if typeof(args.model) == "string" then
		local cComponent = container:FindFirstChild(args.model) :: Model
		if cComponent then
			args.model = cComponent
		else
			error("Child weapon components must exist directly under the parent")
		end
	end
	
	-- set up model
	self.model = (args.model :: Model):Clone()
	self.attached = args.attached or (container:GetAttribute(self.model.Name .. "Attached") :: boolean)
	container:SetAttribute(self.model.Name .. "Attached", self.attached)
	Welder:WeldM(self.model)


	assert(self.model.PrimaryPart, "no primarypart exists for component " .. self.model.Name)
	
	-- parent under CFolder, make if not already made
	if not container:FindFirstChild("CFolder") then
		local f = Instance.new("Folder")
        f.Name = "CFolder"
        f.Parent = container
	end
	self.model.Parent = container
	
	-- look for slot if we are looking to slot something
	local slots = args.attach.Parent:FindFirstChild("CAttachments")
	if args.slot and slots then
		local slotPoint = slots:FindFirstChild(args.slot)
		if slotPoint and slotPoint:GetAttribute("MaxAttachments") or 1 > #(slotPoint :: BasePart):GetChildren() then
			self.model:PivotTo((slotPoint :: BasePart).CFrame)
			self.weld = Welder:Weld(slotPoint :: BasePart, self.model.PrimaryPart)		
		else
			self.model:PivotTo(args.attach.CFrame)
			self.weld = Welder:Weld(args.attach, self.model.PrimaryPart)
		end
	else
		self.model:PivotTo(args.attach.CFrame)
		self.weld = Welder:Weld(args.attach, self.model.PrimaryPart)
	end

	self.components = {}
	--generate children components and get them via callback
	if args.children then
		for _, cPartial in args.children do
			self.components[typeof(cPartial.model) == "string" and cPartial.model or (cPartial.model :: Model).Name] = 
				WeaponComponent.new({
					model = cPartial.model,
					slot = cPartial.slot,
					children = cPartial.children,
					attached = cPartial.attached,
					attach = self.model.PrimaryPart,
				})
		end
	end

	return self
end



function WeaponComponent.GetTree(self: WeaponComponent)
	local tree = {}

	if not next(self.components) then return tree end

	for k, v in pairs(self.components) do
		tree[k] = v:GetTree()
	end
	return tree
end

function WeaponComponent.Detach(self: WeaponComponent, detachOffset: Vector3?)
	self.model:Destroy()
	--if the parent component is gone, the children components should be gone too
	for _, children in pairs(self.components) do
		children:Detach()
	end
end




return WeaponComponent
