--!strict
--[[
Listens to and handles the creation, replication, and destruction of missiles from the client.
(The explosions are handled server-side for consistency.)
]]


local RS = 				game:GetService("ReplicatedStorage")
local Packages = 		RS:WaitForChild("Packages")
local mMS_RS = 			RS:WaitForChild("mMS_RS")
local Modules = 		mMS_RS:WaitForChild("Modules")

local Network = 		require(mMS_RS:WaitForChild("Network"))
local Types = 			require(Modules:WaitForChild("Types"))
local Missile = 		require(Modules:WaitForChild("Missile"))
local GlobalConfig = 	require(Modules:WaitForChild("GC"))

--local Signal = 			require(Packages:WaitForChild("Signal"))

local MissileUpdates: {[string]: {
	main: Missile.Missile,
	from: Types.MissileSnapshot?
}} = {}

local MissileHandler = {
	Name = "MissileHandler",
}

function MissileHandler:Init(EventBus: Types.EventBus)

	local function UpdateMissile(missile: Missile.Missile)
		Network.RequestUpdateMissile:FireServer(missile.fields.identifier :: string, missile:Snapshot())
	end


	-- Server connections -------------------------------------------------------------------------

	--- Register the missile on our client.
	Network.OnMissileFired.OnClientEvent:Connect(function(data, snapshot)
		local newMissile = Missile.new(data.fields)
		newMissile.main.Anchored = true
		MissileUpdates[data.identifier] = {
			main = newMissile,
			from = snapshot,
		}
		game.Debris:AddItem(newMissile.object, GlobalConfig.MissileMaxLifeTime)
	end)
	
	--- Update the missile on our client if it exists. 
	--- [!] There are some edge cases where the client may join while a missile is going through its run time.
	--- While this may cause missiles to appear invisible and cause "ghost" explosions, this is not an incredibly big issue
	--- because it's not like missiles last that long anyways.
	Network.OnMissileUpdated.OnClientEvent:Connect(function(id, snapshot)
		--ensure there is a missile state for the corresponding ID
		local updateData = MissileUpdates[id]

		if not updateData then return end
		
		if updateData.from then
			local delta = snapshot.ver - updateData.from.ver
			updateData.main:Interp(updateData.from, snapshot, delta)
		end
		updateData.from = snapshot
	end)

	--- Remove and clean up the missile from the registry.
	Network.OnMissileDestroyed.OnClientEvent:Connect(function(id: string)
		print("stub")
	end)


	-- Client connections -------------------------------------------------------------------------


	--- Create a missile on the client and send a request for the server to register the missile.
	--- Use callback if needed.
	EventBus.Missile.SendCreationRequest:Connect(function(fields, callback)
		local newMissile: Missile.Missile = Missile.new(fields)
		coroutine.resume(coroutine.create(function()
			newMissile:Init()
			--send a request to the server to register the missile
			Network.RequestRegisterMissile:FireServer(newMissile.fields,newMissile:Snapshot())
	
			--frequently update the missile until it takes off, as it is closest to the view of the player
			repeat 
				task.wait() 
				UpdateMissile(newMissile)
			until newMissile.active
			
			--run the missile loop
			while newMissile do
				newMissile:Run()
				-- provide updates for replication after done running
				UpdateMissile(newMissile)
				task.wait(GlobalConfig.MissileReplicationDelay)
			end
		end))
		
		if callback then 
			callback(newMissile)
		end
	end)




	print("MissileHandler started !!")
end




return MissileHandler

