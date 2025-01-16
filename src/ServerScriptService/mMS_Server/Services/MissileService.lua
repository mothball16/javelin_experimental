--!strict

-- paths & services -------------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")

-- dependencies -----------------------------------------------------------
local Network = require(mMS_RS:WaitForChild("Network"))
local Types = require(Modules:WaitForChild("Types"))

-- constants --------------------------------------------------------------
-- vars -------------------------------------------------------------------
---------------------------------------------------------------------------

export type MissileUpdData = {
	cf: CFrame,
	active: boolean,
}

local DEBUG_MODE = true

local MissileService = {
	Name = "MissileService",
	MissileData = {}
}




function MissileService:Init()
	Network.RequestRegisterMissile.OnServerEvent:Connect(function(player, config, snapshot)
		assert(config.identifier,"no identifier on missile")
		local missileData: Types.MissileReplData = {
			identifier = config.identifier, --necessary for client-side missile cache
			owner = player, -- necessary to avoid updates from other players
			fields = config, -- necessary for the setup of the missile
			ver = snapshot.ver,
			active = snapshot.active, -- necessary to know when to stop updating the missile
			cf = snapshot.cf,
		}

		--set states
		self.MissileData[config.identifier] = missileData
		
		--fire updates
		for _, v in PS:GetPlayers() do
			if not DEBUG_MODE and v == player then continue end
			Network.OnMissileFired:FireClient(v,missileData, snapshot)
		end
	end)
	
	
	


	Network.RequestUpdateMissile.OnServerEvent:Connect(function(player, id, snapshot)
		local thisMissile: Types.MissileReplData = self.MissileData[id]
		if not thisMissile then 
			warn("missile not found?") 
			return 
		end
		
		--validate
		if thisMissile.owner ~= player then
			player:Kick("missile owner update mismatch")
		end
		
		--set states
		for _,v in snapshot do
			thisMissile[v] = snapshot[v]
		end
		
		--fire updates
		for _,v in PS:GetPlayers() do
			if not DEBUG_MODE and v == thisMissile.owner then continue end
			Network.OnMissileUpdated:FireClient(v, id, snapshot)
		end
	end)

	print("MissileService initalized !!")
end





return MissileService