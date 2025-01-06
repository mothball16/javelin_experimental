

local tool = script.Parent.Parent
local prompt = tool.Missile.Main.Action
local isLoaded = tool.IsLoaded
local loadAttached = tool.loadAttached
local RS = game:GetService("RunService")
local CS = game:GetService("CollectionService")
local loadingMissile = nil


local getNearestPayload = function()
	local mag = math.huge
	local nearestMissile = nil
	for i,v in pairs(CS:GetTagged("JavLoad")) do
		if v.Parent.Parent == game.Workspace then
			local mMag = (v.Position - tool.Missile.Main.Position).Magnitude
			if mMag < mag then
				nearestMissile = v
				mag = mMag
			end
		end
		
	end
	return {nearestMissile,mag}
end

RS.Stepped:Connect(function()
	if loadAttached.Value and not isLoaded.Value then
		prompt.Enabled = true
		prompt.ActionText = "Dispose Housing"
		prompt.HoldDuration = 5
	elseif not loadAttached.Value and getNearestPayload()[1] ~= nil and getNearestPayload()[2] < 8 then
		prompt.Enabled = true
		prompt.ActionText = "Attach Load"
		prompt.HoldDuration = 8
	else
		prompt.Enabled = false
	end
	
	for i,v in pairs(tool.Missile:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = tool.loadAttached.Value == true and 0 or 1
		end
	end
	tool.Missile["FGM-148"].Transparency = tool.IsLoaded.Value == true and 0 or 1
end)

prompt.Triggered:Connect(function()
	if loadAttached.Value and not isLoaded.Value then
		loadAttached.Value = false
		local debrisMissile = tool.Missile:Clone()
		
		
		for i,v in pairs(tool.Missile:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.CanQuery = false
			end
		end
		
		for i,v in pairs(debrisMissile:GetDescendants()) do
			if v.Name == "JAV" then
				
				local weld = Instance.new("Weld")
				weld.Part0 = v
				weld.Part1 = debrisMissile.Main
				local CJ = CFrame.new(v.Position)
				weld.C0 = v.CFrame:inverse()*CJ
				weld.C1  =debrisMissile.Main.CFrame:inverse()*CJ
				weld.Parent = debrisMissile.Main
				
			elseif v.Name == "FGM-148" then
				v:Destroy()
			end
		end
		debrisMissile.Main.Position = tool.Missile.Main.Position
		debrisMissile.Main.Action:Destroy()
		debrisMissile.Parent = game.Workspace
		
	elseif not loadAttached.Value and loadingMissile ~= nil then
		loadAttached.Value = true
		isLoaded.Value = true
		loadingMissile.Parent:Destroy()
		for i,v in pairs(tool.Missile:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
				v.CanQuery = true
			end
		end
	end
	
end)

prompt.PromptButtonHoldBegan:Connect(function()
	if getNearestPayload()[1] ~= nil and getNearestPayload()[2] < 8 then
		loadingMissile = getNearestPayload()[1]
	end
end)

prompt.TriggerEnded:Connect(function()
	loadingMissile = nil
end)


