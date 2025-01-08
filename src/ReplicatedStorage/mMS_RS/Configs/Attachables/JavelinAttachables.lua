--!strict
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))



local configs: {[string]: Types.AttachableConfig} = {
    ["CLU"] = {
        name = "FGM-148 Command Launch Unit",
        forms = {
            Tool = false,
            Dropped = false,
            Embedded = true,
        },
        dropOnUnequip = false,
        
    },
    ["Housing"] = {
        name = "FGM-148 Launch Tube Assembly"
    }
}


return configs