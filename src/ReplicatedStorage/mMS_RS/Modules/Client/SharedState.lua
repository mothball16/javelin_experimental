--!strict
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))
local Charm = require(Packages:WaitForChild("Charm"))

type State = {
    currentSystem: Charm.Atom<Types.MissileSystem?>,
    systemIsSeat: Charm.Atom<boolean>,
}
local state: State = {
    currentSystem = Charm.atom(nil :: Types.MissileSystem?),
    systemIsSeat = Charm.atom(false),
    
}




return state