--!strict

local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Net = require(Packages:WaitForChild("Net"))
local Types = require(Modules:WaitForChild("Types"))


export type MissileUpdData = {
	cf: CFrame,
	active: boolean,
}

local DEBUG_MODE = true

local MissileService = {
	Name = "MissileService",
	MissileData = {}
}


--do vars in KnitInit


function MissileService:Init()

	Net:RemoteEvent("RegisterMissile").OnServerEvent:Connect(function(player: Player,config: Types.MissileFields, snapshot: Types.MissileSnapshot)
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
			self.Client.MissileRegistered:Fire(v,missileData, snapshot)
		end
	end)
	
	
	


	Net:RemoteEvent("UpdateMissile").OnServerEvent:Connect(function(player: Player, id: string, snapshot: Types.MissileSnapshot)
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
			self.Client.MissileUpdated:Fire(v, id, snapshot)
		end
	end)



	
	Net:RemoteEvent("DestroyMissile").OnServerEvent:Connect(function(player: Player, id: string)
		
	end)


	print("MissileService initalized !!")
end





return MissileService