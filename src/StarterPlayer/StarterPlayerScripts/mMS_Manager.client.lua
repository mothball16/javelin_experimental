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
local MissileController = Knit.GetController("MissileController")
--remote stuff
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")

local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")

local Types = require(Modules:WaitForChild("Types")

--plr references
local player = game.Players.LocalPlayer
local char: Instance = player.Character or player.CharacterAdded:Wait()

--current tool
local system: Types.MissileSystem?


--- sets up and connects the newly loaded system
--- @param newSys: Types.MissileSystem - the system to load in
local function SetupSystem(newSys: Types.MissileSystem)
	--since we know a new system is now being introduced, clean out the current system
	if system then
		system.Cleanup()
		system = nil
	end
	newSys.Setup()

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
	local newSys: any = Systems:FindFirstChild(toRequire == "" and child.Name or toRequire)
	if not newSys then return end
	newSys = require(newSys) :: any
	newSys.object = child

	SetupSystem(newSys :: Types.MissileSystem)
end)

char.ChildRemoved:Connect(function()
	
end)


--[[
UIS.InputBegan:Connect(function(input,chatting)
	if not chatting then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isLocked then
			local MRC = Knit.GetController("MissileController")
			local passAtt = lockAtt:Clone()
			passAtt.Parent = lockAtt.Parent
			local data = {
				origin = missileTube.Main.Front.WorldPosition,
				initOrient = missileTube.Main.Front.WorldCFrame,
				target = lockAtt.WorldPosition,
				att = passAtt,
			} :: Missile.MissileFields
			local missile = MRC:RegisterMissile(data)


			endLock()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			if (head.Position - camera.CFrame.Position).Magnitude < 1  and  lockTime == 0 then
				isZoomed = not isZoomed
				if isZoomed then
					javHud.Visible = true
					player.CameraMaxZoomDistance = 0.5
					camera.FieldOfView = 30

					local grainImage = Instance.new("ImageLabel")
					grainImage.Size = UDim2.new(1, 0, 1, 0)
					grainImage.BackgroundTransparency = 1
					grainImage.ImageTransparency = 0.85
					grainImage.ScaleType = Enum.ScaleType.Tile
					grainImage.Image = "http://www.roblox.com/asset/?id=28756351"
					grainImage.ZIndex = 1
					grainImage.Name = "FilmGrain"
					grainImage.Parent = ui
					local u1 = 0
					local new = UDim2.new
					local random = math.random
					game:GetService("RunService").Heartbeat:Connect(function()
						if tick() - u1 < 0.020833333333333332 then
							return
						end
						u1 = tick()
						grainImage.TileSize = new(random(213.6, 266.40000000000003) / 1000, 0, random(213.6, 266.40000000000003) / 1000, 0)
					end)
				else
					javHud.Visible = false
					if ui:FindFirstChild("FilmGrain") then ui:FindFirstChild("FilmGrain"):Destroy() end
					player.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance


					--backup stuff
					camera.FieldOfView = 70
					--hum.WalkSpeed = 16
				end

			end
		elseif input.KeyCode == Enum.KeyCode.F and tool.IsLoaded.Value == true and isZoomed then
			ui.CropFrame.Visible = establishLockAtt()
		end
	end
end)



UIS.InputEnded:Connect(function(input,chatting)
	if not chatting then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then

		elseif input.KeyCode == Enum.KeyCode.F and isZoomed then
			endLock()
		end
	end

end)

RUS.RenderStepped:Connect(function(dt)
	if ui.CropFrame.Visible and lockAtt and isZoomed then
		local pos,visible = camera:WorldToScreenPoint(lockAtt.WorldPosition)
		if visible and 
			math.abs(pos.X-screenCenter.X) <= (camera.ViewportSize.Y-36) * 0.15*1.5 and 
			math.abs(math.abs(pos.Y/(camera.ViewportSize.Y-72))-0.5) <= 0.15 
		then
			lockTime = math.min(lockSpeed,lockTime + dt)
			ui.LockFrame.Visible = true
			ui.LockFrame.Position = UDim2.new(0,pos.X,0,pos.Y+36)
			ui.LockFrame.Size = UDim2.new(numLerp(0.1,0.025,lockTime/lockSpeed),0,1,0)
			if lockTime >= lockSpeed then
				isLocked = true
			end
		else

			endLock()
		end
	end





end)


RUS.Heartbeat:Connect(function()
	if isZoomed then
		for i,v in pairs(tool:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
	else
		for i,v in pairs(missileTube:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = tool.loadAttached.Value == true and 0 or 1
			end
		end

		for i,v in pairs(tool.CLU:GetDescendants()) do
			if v:IsA("BasePart")then
				v.Transparency = 0
			end
		end

		missileTube["FGM-148"].Transparency = tool.IsLoaded.Value == true and 0 or 1
	end
end)

hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	if isZoomed and hum.WalkSpeed > 0 then
		hum.WalkSpeed = 0
	end
end)]]