--!strict

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

local MissileController = Knit.CreateController({
	Name = "MissileController"
})

function MissileController:KnitInit()
	print("MissileController initalized")
end

function MissileController:KnitStart()
	local MissileService = Knit.GetService("MissileService")
	
	
	local function HandleRegister(data: Types.MissileReplData, snapshot: Types.MissileSnapshot)
		local missile = Missile.new(data.fields)
		missile.main.Anchored = true
		local updateData = MissileUpdates[data.identifier]
		MissileUpdates[data.identifier] = {
			main = missile,
			from = snapshot,
		}
		game.Debris:AddItem(missile.object, MissileService.MISSILE_MAX_TIME:Get())
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
	
	MissileService.MissileRegistered:Connect(HandleRegister)
	MissileService.MissileUpdated:Connect(HandleUpdate)
	MissileService.MissileDestroyed:Connect(HandleDestroy)
	print("MissileController started")
end

--register (for replication) and then start the missile
function MissileController:RegisterMissile(fields: Types.MissileFields): Missile.Missile
	local missile: Missile.Missile = Missile.new(fields)
	coroutine.resume(coroutine.create(function()
		local MissileService = Knit.GetService("MissileService")
		missile:Init()
		--send a request to the server to register the missile
		MissileService.RegisterMissile:Fire(missile.fields,missile:Snapshot())
		
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

function MissileController:UpdateMissile(missile: Missile.Missile)
	local MissileService = Knit.GetService("MissileService")
	MissileService.UpdateMissile:Fire(missile.fields.identifier,missile:Snapshot())
end



return MissileController

