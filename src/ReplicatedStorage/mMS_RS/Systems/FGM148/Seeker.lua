--!strict

--[[
Wrapper around TargetLocker for functionality matching the FGM-148.
The FGM-148 has a delay between when the seeker trigger is pushed and when the seeker actually activates
According to the manual this should be no more than 3 seconds
For gameplay purposes it is made so that longer-distance targets take longer to lock onto
]]

-- paths & services -----------------------------------------------------------------------
local RS =              game:GetService("ReplicatedStorage")
local RUS =             game:GetService("RunService")
local mMS_RS =          RS:WaitForChild("mMS_RS")
local Packages =        RS:WaitForChild("Packages")
local Modules =         mMS_RS:WaitForChild("Modules")
-- dependencies ---------------------------------------------------------------------------
local Types =           require(Modules:WaitForChild("Types"))
local TargetLocker =    require(Modules:WaitForChild("TargetLocker"))
local Charm =           require(Packages:WaitForChild("Charm"))
local Maid =            require(Modules:WaitForChild("Maid"))
local Signal =          require(Packages:WaitForChild("Signal"))
local Input =           require(Packages:WaitForChild("Input"))
-- constants ------------------------------------------------------------------------------
local SEEK_BASE = 1
local SEEK_ADD_PER_HUNDRED = 0.25



local FGM148Seeker = {}
FGM148Seeker.__index = FGM148Seeker

type self = {
    Maid: Maid.Maid,
    Targeter: TargetLocker.TargetLocker,
    Seeker: BasePart,

    seekerActivated: Charm.Atom<boolean>,
    seekTimeRequired: Charm.Atom<number>,
    preSeekDuration: Charm.Atom<number>,
    seekerBattery: Charm.Atom<number>,
}

export type FGM148Seeker = typeof(setmetatable({} :: self, FGM148Seeker))

function FGM148Seeker.new(args: {
    TargeterConfig: Types.TargetLockerConfig,
    FOVFrame: Frame,
    Seeker: BasePart,
}): FGM148Seeker
    
    local self = setmetatable({} :: self, FGM148Seeker)

    self.Maid = Maid.new()
    self.Targeter = TargetLocker.new(args.TargeterConfig)
    self.Seeker = args.Seeker

    --init state
    self.preSeekDuration = Charm.atom(0)
    self.seekerBattery = Charm.atom(100)
    self.seekerActivated = Charm.atom(false)
    self.seekTimeRequired = Charm.atom(SEEK_BASE)



    return self
end

-- cam.CFrame.LookVector.Unit * 1000
--- Given the seeker part and the direction
function FGM148Seeker.TryLock(self: FGM148Seeker, dir: Vector3): boolean
    --if creating the lock attachment was successful...
    if self.Targeter:CreateLock(self.Seeker.Position, dir) then
        self.Maid.seekConnection = self:CreateCheckLoop()
        
        return true
    end
    return false
end

--- Helper method to declutter TryLock. Returns the RenderStepped connection for updating the targeter.
function FGM148Seeker.CreateCheckLoop(self: FGM148Seeker): RBXScriptConnection
    return RUS.RenderStepped:Connect(function(dt: number)
        local lockAtt = self.Targeter.lockAtt()
        if lockAtt then
            --Get the ray to the attachment
            local dir = (lockAtt.WorldPosition - self.Seeker.Position).Unit * self.Targeter.config.maxDist :: number)
            --Verify whether the lock is still valid, either update the timer or 
            if self.Targeter:Check(self.Seeker.Position, dir) then
                self.Targeter:Update(dt)
            else
                self:EndLock()
            end
        else
            self:EndLock()
        end
    end)
end



function FGM148Seeker.EndLock(self: FGM148Seeker)
    self.preSeekDuration(0)
    self.seekerActivated(false)
    self.Maid.seekConnection = nil
    self.Targeter:DestroyLock()
end



function FGM148Seeker.Destroy(self: FGM148Seeker)
    self.Maid:DoCleaning()
end


return FGM148Seeker

