--!strict

local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("Players")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")

local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(Modules:WaitForChild("Types"))
export type MissileReplData = {
	identifier: string,
	owner: Player,
	config: Types.MissileFields,
	cf: CFrame,
	last: number?,
	active: boolean,
}

export type MissileUpdData = {
	cf: CFrame,
	active: boolean,
}

local DEBUG_MODE = true

local MissileReplService = Knit.CreateService({
	Name = "MissileReplService",
	Client = {
		MISSILE_MAX_TIME = Knit.CreateProperty(30),
		
		RegisterMissile = Knit.CreateSignal(),
		UpdateMissile = Knit.CreateUnreliableSignal(),
		DestroyMissile = Knit.CreateSignal(),
		
		MissileRegistered = Knit.CreateSignal(),
		MissileUpdated = Knit.CreateUnreliableSignal(),
		MissileDestroyed = Knit.CreateSignal(),
	},
	MissileData = {}
})


--do vars in KnitInit
function MissileReplService:KnitInit()
	self.Client.RegisterMissile:Connect(function(player: Player,config: Types.MissileFields, snapshot: Types.MissileSnapshot)
		assert(config.identifier,"no identifier on missile")
		local missileData: MissileReplData = {
			identifier = config.identifier, --necessary for client-side missile cache
			owner = player, -- necessary to avoid updates from other players
			config = config, -- necessary for the setup of the missile
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
	
	
	
	self.Client.UpdateMissile:Connect(function(player: Player, id: string, snapshot: Types.MissileSnapshot)
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
	
	self.Client.DestroyMissile:Connect(function(player: Player, id: string)
		
	end)
	print("MissileReplService initalized !!")
end





return MissileReplService