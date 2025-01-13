--!strict

--[[
- composition for any locking mechanism
- can establish and destory a lock, as well as make/update the corresponding lockvisuals
- This is a container component for any LockVisuals.
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
local Types =       require(Modules:WaitForChild('Types'))
local LockVisual =  require(Components:WaitForChild("FFOSys"):WaitForChild("LockVisual"))

-- vars ------------------------------------------------------------------------
local PGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local cam = game.Workspace.CurrentCamera

--------------------------------------------------------------------------------
--local Types = require(Modules:WaitForChild("Types"))

local TargetLocker = {}
TargetLocker.__index = TargetLocker

type self = {
    config: Types.TargetLockerConfig,
    lockAtt: Charm.Atom<Attachment?>,
    lockPct: Charm.Atom<number>,
    lockPos: Charm.Atom<UDim2>,

    
    lastTick: number,
    root: any,
    _maid: Maid.Maid,
    
	OnLockStarted: Signal.Signal<Attachment>,
	OnLockEnded: Signal.Signal<>,
}

export type TargetLocker = typeof(setmetatable({} :: self, TargetLocker))



function TargetLocker.new(config: Types.TargetLockerConfig)
    local self = setmetatable({
        lockAtt = Charm.atom(nil :: Attachment?),
        lockPct = Charm.atom(0),
        lockPos = Charm.atom(UDim2.new(0,0,0,0)),
        
        config = config,
        _maid = Maid.new(),
        OnLockEnded = Signal.new(),
        OnLockStarted = Signal.new(),
        root = ReactRoblox.createRoot(Instance.new("Folder",PGui)),
    } :: self, TargetLocker)

    
    --give signals to maid
    --self._maid:GiveTask(self.UpdateLock)
    self._maid:GiveTask(self.OnLockStarted)
    self._maid:GiveTask(self.OnLockEnded)
    

    --set up the React interface, pass pct and pos as atoms
    self.root:render(ReactRoblox.createPortal(React.createElement(
        "ScreenGui",{
            Name = "TargetLocker",
            IgnoreGuiInset = true
        },{ 
            React.createElement(LockVisual,
            {
                pct = self.lockPct,
                pos = self.lockPos,
            })
    }),PGui))

    --cleanup after yourself !!!
    self._maid:GiveTask(function()
        self.root:unmount()
    end)

    return self
end

function TargetLocker.CreateLock(self: TargetLocker, from: Vector3, to: Vector3): Attachment?
    local result = self:Check(from, to,UDim2.fromOffset(cam.ViewportSize.X/2, cam.ViewportSize.Y/2))
    if not result then
        return nil
    end
    local att = Instance.new("Attachment",result.Instance)
    self._maid:GiveTask(att)
    att.WorldPosition = result.Position
    self.lockAtt(att)
    return att

end

function TargetLocker.GetPosOnScreen(self: TargetLocker): UDim2
    local DEFAULT_UDIM = UDim2.fromOffset(-9999999, -9999999)
    if not self.lockAtt() then
        return DEFAULT_UDIM
    end
    local pos, onScreen = cam:WorldToViewportPoint((self.lockAtt() :: Attachment).WorldPosition)


    return onScreen 
    and UDim2.fromOffset(pos.X, pos.Y) 
    or DEFAULT_UDIM
end


function TargetLocker.DestroyLock(self: TargetLocker)
    if self.lockAtt() then 
        (self.lockAtt() :: Attachment):Destroy() 
        self.lockAtt(nil)
    end
    self.lockPct(0)
end

--- determine whether the lock still fits within the valid params
--- @param from Vector3 - the origin of the ray
--- @param to Vector3 - the target of the ray
--- @return result (RaycastResult)
function TargetLocker.Check(self: TargetLocker, from: Vector3, to: Vector3, checkPos: UDim2?): RaycastResult?
    local rayResult = game.Workspace:Raycast(from,to,self.config.rayParams)
    local posOnScreen = checkPos or self:GetPosOnScreen()

    --if its not on screen you cant lock on it bozo
    if not posOnScreen then 
        return nil 
    end


    --easy magnitude check
    if self.config.maxDist then
        if (from - rayResult.Position).Magnitude > self.config.maxDist then
            return nil
        end
    end
--[[
    if not self.config.ignoreWalls then
        
    end]]

    --check within cam bounds
    if self.config.bounds then
        local bounds = self.config.bounds()
        print(posOnScreen, bounds)
        if 
            posOnScreen.X.Offset < bounds.pos.X or
            posOnScreen.X.Offset > bounds.pos.X + bounds.size.X or
            posOnScreen.Y.Offset < bounds.pos.Y or
            posOnScreen.Y.Offset > bounds.pos.Y + bounds.size.Y 
        then
            print("BREAK HERE")
            return nil
        end
    end

    return rayResult
end

---update the atoms in the
function TargetLocker.Update(self: TargetLocker)
    Charm.batch(function()  
        self.lockPos(self:GetPosOnScreen())
        self.lockPct(math.clamp(self.lockPct() + 0.005,0,1))
    end)
   
end


function TargetLocker.Destroy(self: TargetLocker)
    self:DestroyLock()
    self._maid:DoCleaning()
end

    
return TargetLocker