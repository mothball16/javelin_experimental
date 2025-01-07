--!strict
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("mMS_RS"):WaitForChild("Modules"):WaitForChild("Types"))

local module: Types.MissileConfig = {
	peak = 160 * (1/0.3), --or 60 * (1/0.3) for direct arc, modified in script
	
}

return module
