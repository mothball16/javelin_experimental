--!strict

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = mMS_RS:WaitForChild("Packages")
local Missile = require(Modules:WaitForChild("Missile"))
local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(Modules:WaitForChild("Types"))





--services
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local RUS = game:GetService("RunService")
local Packages = mMS_RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
--remote stuff

local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")

local Types = require(Modules:WaitForChild("Types"))

--plr references
local player = game.Players.LocalPlayer
local char: Instance = player.Character or player.CharacterAdded:Wait()

--current tool
local system: Types.MissileSystem?
local systemIsSeat: boolean






local ID = "mothballMissileSystem"
------------------------------------------------------------------
--- sets up and connects the newly loaded system
--- @param newSys: Types.MissileSystem - the system to load in

char.ChildAdded:Connect(function(child: Instance)
	
end)

char.ChildRemoved:Connect(
end)






local ItemController = Knit.CreateController({
	Name = "ItemController"
})

function ItemController:KnitInit()
	print("ItemController initalized")
end

function ItemController:KnitStart()
	
	print("ItemController started")
end


function ItemController:SetupSystem(newSys: Types.MissileSystem)
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
end



function ItemController:OnChildAdded(child: Instance)
	-- if there is already a system loaded, don't let a new one get initialized
	if system then return end
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
	local toRequire = child:GetAttribute(ID)
	if not toRequire then return end

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
end


function ItemController:OnChildRemoved(child: Instance)
	--we dont care if its not the system
	if not system then return end

	if systemIsSeat then
		--check if the weld was associated with a missile system
		if child:IsA("Weld") or child:IsA("WeldConstraint") then
			if child.Part0 and child.Part0:GetAttribute(ID) then
			elseif child.Part1 and child.Part1:GetAttribute(ID) then
			else return end

			system:Destroy()
			system = nil
		end
	else
		--handheld logic for detectign unequip/drop
		if child:GetAttribute(ID) then
			system:Destroy()
			system = nil
		end
	end
end


return ItemController

