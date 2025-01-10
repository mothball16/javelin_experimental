--!strict
--[[
This controller requests the creation and deletion of missile systems
]]




local RS = game:GetService("ReplicatedStorage")

local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")
local Client = Modules:WaitForChild("Client")
local State = require(Client:WaitForChild("SharedState"))
local Signals = require(Client:WaitForChild("Signals"))
local Types = require(Modules:WaitForChild("Types"))
local Maid = require(Modules:WaitForChild("Maid"))
------------------------------------------------------------------
--plr references
local player = game.Players.LocalPlayer

local ID = "mothballMissileSystem"
------------------------------------------------------------------

local SysController = {
	Name = "SysController",
	OnEquip = Signal.new(),
	OnUnequip = Signal.new(),
}

function SysController:OnStart()
	local maid = Maid.new()

	--setup conns
	player.CharacterAdded:Connect(function(char)
		maid:GiveTask(char.ChildRemoved:Connect(self:OnChildRemoved()))
		maid:GiveTask(char.ChildAdded:Connect(self:OnChildAdded()))
	end)

	--not sure if this is necessary but doing it out of caution
	player.CharacterRemoving:Connect(function()
		maid:DoCleaning()
	end)

	print("SysController started")
end

--- validate that the controller implements MissileSystem, return success
--- @param name string - the name of the system 
--- @return boolean - whether verification succeeded
function SysController:LoadSystem(name: string): boolean

	--check if the controller exists
	local found = Systems:FindFirstChild(name)
	if not found then 
		warn("missile system of type " .. name .. " not found in system directory (mMS_RS..Systems")
		return false
	end
	--poopy typecheck bypass
	local sys: any = require(found) :: any

	sys:Setup()
	return true
end

function SysController:OnChildAdded(child: Instance)
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
	local toRequire = child:GetAttribute(ID) :: string?
	if not toRequire then return end
	if not self:VerifySystem(toRequire) then return end

	--init and save necessary data
	State.currentSystem = toRequire
	State.systemIsSeat = isSeat
end


function SysController:OnChildRemoved(child: Instance)
	--we dont care if its not the system
	if not current then return end

	if systemIsSeat then
		--check if the weld was associated with a missile system
		if child:IsA("Weld") or child:IsA("WeldConstraint") then
			if child.Part0 and child.Part0:GetAttribute(ID) then
			elseif child.Part1 and child.Part1:GetAttribute(ID) then
			else return end

			controllers[current]:Destroy()
			current = nil
		end
	else
		--handheld logic for detectign unequip/drop
		if child:GetAttribute(ID) then
			controllers[current]:Destroy()
			current = nil
		end
	end
end


return SysController







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
