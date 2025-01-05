--!strict
--use-motion.lua

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

