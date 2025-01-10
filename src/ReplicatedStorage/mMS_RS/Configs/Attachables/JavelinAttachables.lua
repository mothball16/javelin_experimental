--!strict
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("mMS_RS"):WaitForChild("Modules"):WaitForChild("Types"))

local configs: {[string]: Types.AttachableConfig} = {
    ["JavelinCLU"] = {
        name = "FGM-148 Command Launch Unit",
        forms = {
            Tool = false,
            Dropped = false,
            Embedded = true,
        },
        dropOnUnequip = false,

    },
    ["JavelinLTA"] = {
        name = "FGM-148 Launch Tube Assembly",
        forms = {
            Tool = true,
            Dropped = true,
            Embedded = true,
        },
        dropOnUnequip = true,
    }
}

return configs