--!strict

local module = {}
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = RS:WaitForChild("Packages")
local Signal = require(Packages:WaitForChild("Signal"))
local Maid = require(Modules:WaitForChild("Maid"))



--static data not relevant to customization plus the missile config
export type MissileFields = MissileConfig & {
	--required (static missile data)
	origin: Vector3,
	--this doesn't really need to exist because att makes it obsolete. TODO !!!
	target: Vector3,
	--this could honestly be combined with origin. TODO !!!
	initOrient: CFrame,
	--the name of the missile for lookup
	model: string,
	--the attachment for the missile to follow
	att: Attachment?,
	--GUID for missile registry
	identifier: string?,
	--Unpaid intern
	_maid: Maid.Maid,
}


--for missile config file intellisense
export type MissileConfig = {
	--really shouldn't be touched unless you're trying to intentionally make a faulty missile; determines the max iterations the prediction algorithm can run through
	iterations: number?,
	--peak flight altitude above the origin altitude
	peak: number?,
	--maximum studs per second the missile can reach
	maxSpeed: number?,
	--how many studs per second the missile speed increases by
	accel: number?,
	--speed of the missile as it comes out, modifies the InitVel mover
	initSpeed: number?,
	--amount in seconds for the missile to activate, prior to that it will be propelled by InitVel (0: immediately activates)
	initTime: number?,
	--blast radius
	radius: number?,
	--0: not tandem, >0: tandem, a second explosion will happen <tandem> units from the first explosion ignoring walls
	tandem: number?,
	--whether to raycast to targets or just kill them anyway Lol
	ignoreWalls: boolean?,
	--the power of the MainVel mover (less = more sluggish behavior)
	power: number?,
	--any override functions you want to add
	functions: {[string]: (any) -> any}?,
}

--relevant data for replication (on missile creation)
export type MissileReplData = MissileSnapshot & {
	identifier: string,
	owner: Player,
	fields: MissileFields,
}

--relevant data for replicating an already existing missile
export type MissileSnapshot = {
	ver: number,
	cf: CFrame,
	active: boolean,
}

--template for any system that fires missiles because they all have to go through mMS_Manager
export type MissileSystem = {
	object: Instance,
	state: Folder,
	_maid: Maid.Maid,
	new: (args: {[string]: any}) -> (MissileSystem),
	Setup: (self: MissileSystem) -> (),
	--When object is ready to go
	Destroy: (self: MissileSystem) -> (),
	--Send to the manager to keep missile after system is cleaned up
	OnFire: Signal.Signal<MissileFields>
}

export type AttachableFields = AttachableConfig & {
	model: Model,
	main: BasePart,
	_oMaid: Maid.Maid,
	_fMaid: Maid.Maid,
}
export type AttachableConfig = {
	name: string?,
	attachesTo: {string}?,
	forms: {
		Tool: boolean,
		Dropped: boolean,
		Embedded: boolean,
	}?,		
	dropOnUnequip: boolean?,
	toolOnDetach: boolean?,

	holdAnim: string?,
	equipTime: number?,
	detachTime: number?,
	interactionDistance: number?,
}

return module
