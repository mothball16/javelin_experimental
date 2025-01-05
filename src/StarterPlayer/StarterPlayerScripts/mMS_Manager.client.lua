--!strict

--[[
This script is used receive and carry out any actions that need to continue after the tool is unequipped (e.g. shooting a missile)
Originally this was literally the only purpose of the script but after making just that one task I was like "I need to add at least 3 more things to this"


( Is this how a framework works??? Ion know i should probably go to my cs lectures )
]]




--services
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RUS = game:GetService("RunService")
local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
--remote stuff
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")

local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")

local Types = require(Modules:WaitForChild("Types"))

--plr references
local player = game.Players.LocalPlayer
local char: Instance = player.Character or player.CharacterAdded:Wait()

--current tool
local system: Types.MissileSystem?


--- sets up and connects the newly loaded system
--- @param newSys: Types.MissileSystem - the system to load in
local function SetupSystem(newSys: Types.MissileSystem)
	local MissileController = Knit.GetController("MissileController")
	--since we know a new system is now being introduced, clean out the current system
	if system then
		system:Cleanup()
		system = nil
	end
	newSys:Setup()

	--connect the signal to do literally the only thing this script was meant to do
	newSys.OnFire:Connect(function(fields: Types.MissileFields)
		MissileController:RegisterMissile(fields)
	end)
	system = newSys

end


char.ChildAdded:Connect(function(child: Instance)
	--if system then
	
	--check if the child added was a seatweld -- if so, grab the seat, if not
	if child:IsA("Weld") or child:IsA("WeldConstraint") then
		if child.Part0 and child.Part0:IsA("Seat") then
			child = child.Part0
		elseif child.Part1 and child.Part1:IsA("Seat") then
			child = child.Part1
		else return end
	end


	--check if the child has the identification for missile system
	local toRequire = child:GetAttribute("mothballMissileSystem")
	if not toRequire then return end


	--bum way to circumvent unknown path false error ( Bad code jumpscare !! )
	local sysName: string = (toRequire == "" and child.Name or toRequire :: string)
	local newSys: any = Systems:FindFirstChild(sysName)
	if not newSys then 
		warn("missile system of type " .. sysName .. " not found in module directory")
		return 
	end
	newSys = require(newSys) :: any
	SetupSystem(newSys.new({
		object = child
	}) :: Types.MissileSystem)
end)

char.ChildRemoved:Connect(function()
	
end)
