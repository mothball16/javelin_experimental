--!strict

--[[
composition for any locking mechanism. has mechanics for establishing, breaking a lock, and updating the interface as such
]]

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Components = mMS_RS:WaitForChild("Components")
local Signal = require(Packages:WaitForChild("Signal"))
local React = require(Packages:WaitForChild("ReactLua"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))
local LockVisual = require(Components:WaitForChild("FFOSys"):WaitForChild("LockVisual"))
local Maid = require(Modules:WaitForChild("Maid"))
--------------------------------------------------------------------------
local PGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")


--------------------------------------------------------------------------
--local Types = require(Modules:WaitForChild("Types"))

local TargetLocker = {}
TargetLocker.__index = TargetLocker

type self = {
    root: any,
    lockAtt: Attachment?,
	lockPercent: number,
    _maid: Maid.Maid,

    UpdateLock: Signal.Signal<number>,
	OnLockStarted: Signal.Signal<Attachment>,
	OnLockEnded: Signal.Signal<>,
}

export type TargetLocker = typeof(setmetatable({} :: self, TargetLocker))

function TargetLocker.new()
    local self = setmetatable({} :: self, TargetLocker)
    self.lockAtt = nil
    self._maid = Maid.new()
    self.UpdateLock = Signal.new()
    self.OnLockEnded = Signal.new()
    self.OnLockStarted = Signal.new()

    --give signals to maid
    self._maid:GiveTask(self.UpdateLock)
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
                updateSignal = self.UpdateLock
            })
    }),PGui))
    self._maid:GiveTask(function()
        self.root:unmount()
    end)

    return self
end

function TargetLocker.BeginLock(self: TargetLocker, origin: Vector3, target: Vector3, rayParams: RaycastParams): boolean
    local rayResult = game.Workspace:Raycast(origin,target,rayParams)
    if rayResult and rayResult.Instance then
        local att = Instance.new("Attachment",rayResult.Instance)
        self._maid:GiveTask(att)

        att.WorldPosition = rayResult.Position
        self.lockAtt = att
        self.OnLockStarted:Fire(self.lockAtt :: Attachment)
        return true
    end
    return false
end

function TargetLocker.EndLock(self: TargetLocker)
    if self.lockAtt then 
        self.lockAtt:Destroy() 
        self.lockAtt = nil
    end
    self.lockPercent = 0
    self.OnLockEnded:Fire()
end

function TargetLocker.Destroy(self: TargetLocker)
    self:EndLock()
    self._maid:DoCleaning()
end

    
return TargetLocker