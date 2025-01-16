--!strict
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("mMS_RS"):WaitForChild("Modules"):WaitForChild("Types"))

local TOP_PEAK = 160 * 1/0.3
local DIR_PEAK = 60 * 1/0.3
local TOP_PEAK_THETA = 60
local DIR_PEAK_THETA = 35
local PHASE_BREAKPOINT = 0.25


local function numLerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end


local function FGM148Warhead(opts: {
	attackDir: "TOP" | "DIR",
	dist: number,
}): Types.MissileConfig
	--create config
	local conf: Types.MissileConfig = {}
	--get the necessary variables for the altitude computer
	local peak = opts.attackDir == "TOP" and TOP_PEAK or DIR_PEAK
	peak = math.min(peak :: number, math.tan(math.rad(opts.attackDir == "TOP" and TOP_PEAK_THETA or DIR_PEAK_THETA)) * (opts.dist * PHASE_BREAKPOINT))

	-- modeled after https://www.desmos.com/calculator/l2kb4axhr4
	conf.functions = {
		["GetDesiredAltitude"] = function(_: any, progress: number, origin: Vector3, target: Vector3): number
			local desiredAlt: number
			progress = math.clamp(progress,0,1)
			if progress < PHASE_BREAKPOINT then
				desiredAlt = (math.sin(2 * math.pi * progress)^0.5 * peak) + numLerp(origin.Y, target.Y, progress/(PHASE_BREAKPOINT * 2))
			else
				desiredAlt = (math.sin((2 * math.pi) / 3 * (progress + 0.5)) * peak) + target.Y
			end
			return desiredAlt
		end,
		["Explode"] = function()
			
		end
	}

	conf.serverFunctions = {
		["Explode"] = function()
			
		end
	}


	
	return conf
end


return FGM148Warhead
