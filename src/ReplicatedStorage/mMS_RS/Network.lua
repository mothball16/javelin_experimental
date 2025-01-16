--!strict

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local TypedRemote = require(Packages:WaitForChild("TypedRemote"))
local Types = require(Modules:WaitForChild("Types"))
-- Get the RF and RE instance creators, which create RemoteEvents/RemoteFunctions
-- within the given parent (the script in this case):
local RF, RE = TypedRemote.parent(script)

-- Redeclare the TypedRemote types for simplicity:
type RF<T..., R...> = TypedRemote.Function<T..., R...>
type RE<T...> = TypedRemote.Event<T...>

-- Define network table:
return {
    --client -> server
    RequestRegisterMissile = RE("RegisterMissile") :: RE<Types.MissileFields,Types.MissileSnapshot>,
    RequestUpdateMissile = RE("UpdateMissile") :: RE<string, Types.MissileSnapshot>,
    RequestExplodeMissile = RE("ExplodeMissile") :: RE<string, RaycastResult>,

    --server -> client
	OnMissileFired = RE("OnFired") :: RE<Types.MissileReplData, Types.MissileSnapshot>,
    OnMissileUpdated = RE("OnUpdated") :: RE<string, Types.MissileSnapshot>,
	OnMissileDestroyed = RE("OnDestroyed") :: RE<...any>,
}