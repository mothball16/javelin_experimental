--!strict

local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = RS:WaitForChild("Packages")
local Missile = require(Modules:WaitForChild("Missile"))
local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(Modules:WaitForChild("Types"))


--Client-side storage of updated missile data.
local MissileUpdates: {[string]: {
	main: Missile.Missile,
	from: Types.MissileSnapshot?
}} = {}

local MissileReplController = Knit.CreateController({
	Name = "MissileReplController"
})

function MissileReplController:KnitInit()
	print("MissileReplController initalized")
end
function MissileReplController:KnitStart()
	local MissileReplService = Knit.GetService("MissileReplService")
	
	
	local function HandleRegister(data: Types.MissileReplData, snapshot: Types.MissileSnapshot)
		local missile = Missile.new(data.fields)
		missile.main.Anchored = true
		local updateData = MissileUpdates[data.identifier]
		MissileUpdates[data.identifier] = {
			main = missile,
			from = snapshot,
		}
		game.Debris:AddItem(missile.object, MissileReplService.MISSILE_MAX_TIME:Get())
	end
	
	local function HandleUpdate(id: string, snapshot: Types.MissileSnapshot)
		--ensure there is a missile state for the corresponding ID
		local updateData = MissileUpdates[id]

		if not updateData then return end
		
		if updateData.from then
			local delta = snapshot.ver - updateData.from.ver
			updateData.main:Interp(updateData.from, snapshot, delta)
		end
		updateData.from = snapshot
	end
	
	local function HandleDestroy(id: string)
		
	end
	
	MissileReplService.MissileRegistered:Connect(HandleRegister)
	MissileReplService.MissileUpdated:Connect(HandleUpdate)
	MissileReplService.MissileDestroyed:Connect(HandleDestroy)
	print("MissileReplController started")
end

--register (for replication) and then start the missile
function MissileReplController:RegisterMissile(fields: Types.MissileFields): Missile.Missile
	local missile: Missile.Missile = Missile.new(fields)
	coroutine.resume(coroutine.create(function()
		local MissileReplService = Knit.GetService("MissileReplService")
		missile:Init()
		--send a request to the server to register the missile
		MissileReplService.RegisterMissile:Fire(missile.fields,missile:Snapshot())
		
		--frequently update the missile until it takes off, as it is closest to the view of the player
		repeat 
			task.wait() 
			self:UpdateMissile(missile)
		until missile.active
		
		--run the missile loop
		while missile do
			missile:Run()
			-- provide updates for replication after done running
			self:UpdateMissile(missile)
			task.wait(0.1)
		end
	end))
	return missile
	
end

function MissileReplController:UpdateMissile(missile: Missile.Missile)
	local MissileReplService = Knit.GetService("MissileReplService")
	MissileReplService.UpdateMissile:Fire(missile.fields.identifier,missile:Snapshot())
end



return MissileReplController

