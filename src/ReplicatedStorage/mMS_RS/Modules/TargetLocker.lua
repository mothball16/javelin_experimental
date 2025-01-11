--!strict

--[[
- composition for any locking mechanism
- can establish and destory a lock, as well as make/update the corresponding lockvisuals
]]


-- paths & services ------------------------------------------------------------
local RS =          game:GetService("ReplicatedStorage")
local mMS_RS =      RS:WaitForChild("mMS_RS")
local Packages =    RS:WaitForChild("Packages")
local Modules =     mMS_RS:WaitForChild("Modules")
local Components =  mMS_RS:WaitForChild("Components")

-- dependencies ----------------------------------------------------------------
local Charm =       require(Packages:WaitForChild("Charm"))
local ReactCharm =  require(Packages:WaitForChild("ReactCharm"))
local Signal =      require(Packages:WaitForChild("Signal"))
local React =       require(Packages:WaitForChild("ReactLua"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))
local Maid =        require(Modules:WaitForChild("Maid"))
local LockVisual =  require(Components:WaitForChild("FFOSys"):WaitForChild("LockVisual"))

-- vars ------------------------------------------------------------------------
local PGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")


--------------------------------------------------------------------------------
--local Types = require(Modules:WaitForChild("Types"))

local TargetLocker = {}
TargetLocker.__index = TargetLocker

type self = {
    root: any,
    lockAtt: Charm.Atom<Attachment?>,
    _maid: Maid.Maid,
    
    rayParams: RaycastParams,
	OnLockStarted: Signal.Signal<Attachment>,
	OnLockEnded: Signal.Signal<>,
}

export type TargetLocker = typeof(setmetatable({} :: self, TargetLocker))

function TargetLocker.new(ignore: {Instance})
    warn("TODO: allow targetlocker to provide multiple lockvisuals otherwise this is just a shitty wrapper")
    local self = setmetatable({} :: self, TargetLocker)
    
    self.lockAtt = Charm.atom(nil :: Attachment?)
    self._maid = Maid.new()
    self.OnLockEnded = Signal.new()
    self.OnLockStarted = Signal.new()

    --make rayparams
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
    self.rayParams.FilterDescendantsInstances = ignore
    
    --give signals to maid
    --self._maid:GiveTask(self.UpdateLock)
    self._maid:GiveTask(self.OnLockStarted)
    self._maid:GiveTask(self.OnLockEnded)
    
    --set up the React interface
    self.root = ReactRoblox.createRoot(Instance.new("Folder",PGui))
    self.root:render(ReactRoblox.createPortal(React.createElement(
        "ScreenGui",{
            IgnoreGuiInset = true
        },{ 
            React.createElement(LockVisual,
            {
                --updateSignal = self.UpdateLock
            })
    }),PGui))
    self._maid:GiveTask(function()
        self.root:unmount()
    end)

    return self
end

function TargetLocker.CreateLock(self: TargetLocker, origin: Vector3, target: Vector3): Attachment?
    local rayResult = game.Workspace:Raycast(origin,target,self.rayParams)
    if rayResult and rayResult.Instance then
        local att = Instance.new("Attachment",rayResult.Instance)
        self._maid:GiveTask(att)
        att.WorldPosition = rayResult.Position
        self.lockAtt(att)
        return att
    end
    return nil
end



function TargetLocker.DestroyLock(self: TargetLocker)
    if self.lockAtt() then 
        (self.lockAtt() :: Attachment):Destroy() 
        self.lockAtt(nil)
    end
end



function TargetLocker.Destroy(self: TargetLocker)
    self:DestroyLock()
    self._maid:DoCleaning()
end

    
return TargetLocker