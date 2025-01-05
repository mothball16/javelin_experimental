--!strict
-- hook to get ripple to work in regular lua

--[[
info for self:

	interface SpringOptions {
		readonly damping?: number;
		readonly frequency?: number;
		readonly mass?: number;
		readonly tension?: number;
		readonly friction?: number;
		readonly position?: number;
		readonly velocity?: number;
		readonly impulse?: number;
		readonly restingVelocity?: number;
		readonly restingPosition?: number;
	}


]]


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local react = require(ReplicatedStorage.Packages.ReactLua)
local ripple = require(ReplicatedStorage.Packages.Ripple)



function useMotion<T>(initialValue: T)
    local motion = react.useMemo(function()
        return ripple.createMotion(initialValue)
    end, {})

    local binding, setValue = react.useBinding(initialValue)

    react.useEffect(function()
        local connection = RunService.Heartbeat:Connect(function(dt)
            local value = motion:step(dt)

            if value ~= binding:getValue() then
                setValue(value)
            end
        end)

        return function()
            connection:Disconnect()
        end
    end, {})

    return binding, motion
end

return useMotion

