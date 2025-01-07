--!strict

type self = {
	
}


local module = {}
module.__index = module

function module.new()
	
end




return module





--[=[

--services
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RUS = game:GetService("RunService")
local Packages = mMS_RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
--remote stuff
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local RunService = game:GetService("RunService")

local Events = mMS_RS:WaitForChild("Events")
local Models = mMS_RS:WaitForChild("Models")
local Modules = mMS_RS:WaitForChild("Modules")

local Missile = require(Modules:WaitForChild("Missile"))

--plr references
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local head = char:WaitForChild("Head")
local camera = game.Workspace.CurrentCamera

--tool references
local tool = char:WaitForChild("FGM-148 Javelin")
local CLU = tool:WaitForChild("CLU")
local missileTube = tool:WaitForChild("Missile")

--ui
local ui = script.Parent
local javHud = ui.HUD

--bools
local isZoomed = false
local isLocked = false

--lock info
local lockAtt = nil
local lockWeld = nil
local lockTime = 0
local lockSpeed = 0.5
local screenCenter = Vector2.new(camera.ViewportSize.X/2,(camera.ViewportSize.Y+36)/2)

function numLerp(a: number, b: number, t: number): (number)
	return a + (b - a) * t
end


local establishLockAtt = function()
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char,camera}
	local rayResult = game.Workspace:Raycast(camera.CFrame.Position,(camera.CFrame * CFrame.new(0,0,-10000).Position)-camera.CFrame.Position,rayParams)
	if rayResult and rayResult.Instance then
		local att = Instance.new("Attachment",rayResult.Instance)
		att.WorldPosition = rayResult.Position
		lockAtt = att
		camera.FieldOfView = 20
		return true
	end
	return false
end


local endLock = function()
	lockTime = 0
	ui.CropFrame.Visible = false
	isLocked = false
	if lockAtt then
		lockAtt:Destroy()
		lockAtt = nil
	end

	ui.LockFrame.Visible = false
	ui.LockFrame.Position = UDim2.new(0.5,0,0.5,0)
	ui.LockFrame.Size = UDim2.new(0.1,0,1,0)
	camera.FieldOfView = 30
end


char.ChildAdded:Connect(function(child)
	if child:GetAttribute("MissileSystem") then
		
	end
end)


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


--[[
hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	if isZoomed and hum.WalkSpeed > 0 then
		hum.WalkSpeed = 0
	end
end)]]




--]=]
