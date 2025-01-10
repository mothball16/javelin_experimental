--!strict
--[[
This controller requests the creation and deletion of missile systems
]]




local RS = game:GetService("ReplicatedStorage")

local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")
local Client = Modules:WaitForChild("Client")
local State = require(Client:WaitForChild("SharedState"))
local Types = require(Modules:WaitForChild("Types"))
local Maid = require(Modules:WaitForChild("Maid"))
local GlobalConfig = require(Modules:WaitForChild("GC"))
------------------------------------------------------------------
--plr references
local player = game.Players.LocalPlayer


------------------------------------------------------------------

local SysController = {
	Name = "SysController",
}

function SysController:Init()
	local maid = Maid.new()

	local function CharChildAdded(child: Instance)
		-- if there is already a system loaded, don't let a new one get initialized
		if State.currentSystem then return end
		local isSeat = false
		--check if the child added was a seatweld -- if so, grab the seat
		if child:IsA("Weld") or child:IsA("WeldConstraint") then
			isSeat = true
			if child.Part0 and child.Part0:IsA("Seat") then
				child = child.Part0
			elseif child.Part1 and child.Part1:IsA("Seat") then
				child = child.Part1
			else return end
		end
	
		--check if the child has the identification for missile system
		local toRequire = child:GetAttribute(GlobalConfig.Identification) :: string?
		if not toRequire then return end
		local system = self:GetSystem(toRequire)
		if not system then return end
	
		--init
		self:LoadSystem(system :: Types.MissileSystem,isSeat)
	end
	
	
	local function CharChildRemoved(child: Instance)
		--we dont care if its not the system
		if not State.currentSystem then return end
	
		if State.systemIsSeat then
			--check if the weld was associated with a missile system
			if child:IsA("Weld") or child:IsA("WeldConstraint") then
				if child.Part0 and child.Part0:GetAttribute(GlobalConfig.Identification) then
				elseif child.Part1 and child.Part1:GetAttribute(GlobalConfig.Identification) then
				else return end
	
				self:UnloadSystem()
			end
		else
			--handheld logic for detectign unequip/drop
			if child:GetAttribute(GlobalConfig.Identification) then
				self:UnloadSystem()
			end
		end
	end
	

	
	--setup conns

	
	
	player.CharacterAdded:Connect(function(char)
		maid:GiveTask(char.ChildAdded:Connect(CharChildAdded))
		maid:GiveTask(char.ChildRemoved:Connect(CharChildRemoved))
	end)

	--not sure if this is necessary but doing it out of caution
	player.CharacterRemoving:Connect(function()
		maid:DoCleaning()
	end)

	print("SysController initialized !!")
end

--- validate that the controller implements MissileSystem, then require and return it
--- @param name string - the name of the system 
--- @return Types.MissileSystem - the system
function SysController:GetSystem(name: string): Types.MissileSystem?

	--check if the controller exists
	local found = Systems:FindFirstChild(name)
	if not found then 
		warn("missile system of type " .. name .. " not found in system directory (mMS_RS..Systems")
		return nil
	end
	--poopy typecheck bypass
	local sys: any = require(found) :: any

	return sys
end

function SysController:LoadSystem(system: Types.MissileSystem,isSeat: boolean,...)
	if State.currentSystem then
		self:UnloadSystem()
	end
	system:Setup(...)
	State.currentSystem = system
	State.systemIsSeat = isSeat
end

function SysController:UnloadSystem()
	if State.currentSystem then
		State.currentSystem:Destroy()
		State.currentSystem = nil
		State.systemIsSeat = false
	end
end










--[[
	ARCHIVED (old code from localscript)
	--bum way to circumvent unknown path false error ( Bad code jumpscare !! )
	local sysName: string = (toRequire == "" and child.Name or toRequire :: string)
	local newSys: any = Systems:FindFirstChild(sysName)
	if not newSys then 
		warn("missile system of type " .. sysName .. " not found in module directory")
		return 
	end

	systemIsSeat = isSeat
	newSys = require(newSys) :: any

	
	SetupSystem(newSys.new({
		object = child
	}) :: Types.MissileSystem)

function SysController:SetupSystem(newSys: Types.MissileSystem)
	local MissileController = Knit.GetController("MissileController")
	--since we know a new system is now being introduced, clean out the current system
	if system then
		system:Destroy()
		system = nil
	end
	newSys:Setup()

	--connect the signal to do literally the only thing this script was meant to do
	newSys.OnFire:Connect(function(fields: Types.MissileFields)
		MissileController:RegisterMissile(fields)
	end)
	system = newSys
end]]


return SysController
