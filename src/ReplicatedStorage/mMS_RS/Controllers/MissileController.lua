--!strict
--[[
Handles the creation and replication of missiles from the client side.
]]


local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = RS:WaitForChild("Packages")
local Missile = require(Modules:WaitForChild("Missile"))
local Types = require(Modules:WaitForChild("Types"))
local Net = require(Packages:WaitForChild("Net"))
local GlobalConfig = require(Modules:WaitForChild("GC"))


local MissileUpdates: {[string]: {
	main: Missile.Missile,
	from: Types.MissileSnapshot?
}} = {}

local MissileController = {
	Name = "MissileController",
}


function MissileController:Init()	
	local function HandleRegister(data: Types.MissileReplData, snapshot: Types.MissileSnapshot)
		local missile = Missile.new(data.fields)
		missile.main.Anchored = true
		MissileUpdates[data.identifier] = {
			main = missile,
			from = snapshot,
		}
		game.Debris:AddItem(missile.object, GlobalConfig.MissileMaxLifeTime)
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

	
	Net:Connect("OnMissileRegistered", HandleRegister)
	Net:Connect("OnMissileUpdated", HandleUpdate)
	Net:Connect("OnMissileDestroyed", HandleDestroy)

	print("MissileController started !!")
end

--register (for replication) and then start the missile
function MissileController:RegisterMissile(fields: Types.MissileFields): Missile.Missile
	local missile: Missile.Missile = Missile.new(fields)
	coroutine.resume(coroutine.create(function()
		missile:Init()
		--send a request to the server to register the missile
		Net:RemoteEvent("RegisterMissile"):FireServer(missile.fields,missile:Snapshot())

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
			task.wait(GlobalConfig.MissileReplicationDelay)
		end
	end))
	return missile
end

function MissileController:UpdateMissile(missile: Missile.Missile)
	Net:RemoteEvent("UpdateMissile"):FireServer(missile.fields.identifier :: string, missile:Snapshot())
end



return MissileController

