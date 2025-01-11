--!strict


-- paths & services -----------------------------------------------------------------------
local RS =              game:GetService("ReplicatedStorage")
local RUS =             game:GetService("RunService")
local mMS_RS =          RS:WaitForChild("mMS_RS")
local Packages =        RS:WaitForChild("Packages")
local Modules =         mMS_RS:WaitForChild("Modules")
local Components =      mMS_RS:WaitForChild("Components")

-- dependencies ---------------------------------------------------------------------------
local React =           require(Packages.ReactLua)
local ReactRoblox =     require(Packages.ReactRoblox)
local Signal =          require(Packages:WaitForChild("Signal"))
local Input =           require(Packages:WaitForChild("Input"))
local Charm =           require(Packages:WaitForChild("Charm"))
local Maid =            require(Modules:WaitForChild("Maid"))
local TargetLocker =    require(Modules:WaitForChild("TargetLocker"))
local HandheldBase =    require(Modules:WaitForChild("HandheldBase"))
local CLUOptic =        require(Components:WaitForChild("JavelinCLU"):WaitForChild("CLUOptic"))

-- constants ------------------------------------------------------------------------------
local INDICATOR_DEFAULTS =  {
    ["BCU_PLUS"] =  {image = "rbxassetid://89722159180463", state = false},
    ["CLU"] =       {image = "http://www.roblox.com/asset/?id=99363953262967", state = false},
    ["CLU_PLUS"] =  {image = "rbxassetid://120742308197590", state = false},
    ["DAY"] =       {image = "rbxassetid://78672229303453", state = true},
    ["DIR"] =       {image = "rbxassetid://130596689947010", state = false},
    ["FAIL"] =      {image = "rbxassetid://87552336360294", state = false},
    ["FLTR"] =      {image = "rbxassetid://100690720477052", state = false},
    ["HANGFIRE"] =  {image = "rbxassetid://80690717062067", state = false},
    ["MSL"] =       {image = "rbxassetid://113910383142154", state = false},
    ["NFOV"] =      {image = "rbxassetid://116625289291108", state = false},
    ["NIGHT"] =     {image = "http://www.roblox.com/asset/?id=108927303018110", state = false},
    ["SEEK"] =      {image = "rbxassetid://122333432415827", state = false},
    ["TOP"] =       {image = "rbxassetid://81416663556280", state = true},
    ["WFOV"] =      {image = "rbxassetid://97724947789086", state = true},
}

local BINDS: {[string]: Enum.KeyCode} = {
    ["Seek"] = Enum.KeyCode.F,
    ["Path"] = Enum.KeyCode.T,
    ["NV"] = Enum.KeyCode.H,
    ["FOV"] = Enum.KeyCode.G,
}

--(wide is 4x, narrow is 9x)
local WIDE_FOV = 70/4
local NARROW_FOV = 70/9

-- vars ------------------------------------------------------------------------------------
local e = React.createElement
local Keyboard, Mouse = Input.Keyboard.new(), Input.Mouse.new()

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local PGui = plr.PlayerGui
local cam = game.Workspace.CurrentCamera

-------------------------------------------------------------------------------------------


local FGM148System = {}
FGM148System.__index = FGM148System

type self = {
    locker: TargetLocker.TargetLocker,
    rayParams: RaycastParams,
    indicators: {[string]: {image: string, state: boolean}},
    root: any,
    clu: ScreenGui,
    OnIndicatorsUpdated: Signal.Signal<{[string]: {image: string, state: boolean}}>,
    OnZoomToggled: Signal.Signal<boolean>,
    
    nv: Charm.Atom<boolean>,
    seeking: Charm.Atom<boolean>,
    zoomed: Charm.Atom<boolean>,
    zoomFov: Charm.Atom<number>,
    missilePath: Charm.Atom<string>,
}

export type FGM148System = typeof(setmetatable({} :: self, FGM148System)) & HandheldBase.HandheldBase


--- initialize object and set up self
function FGM148System.new(args: {
    object: Model,
}): FGM148System
    local self = setmetatable(HandheldBase.new({
        object = args.object,
    --    state = args.object:FindFirstChild("mMS_State") :: Folder
    }) :: FGM148System, FGM148System)
    self._maid = Maid.new()


    self.locker = TargetLocker.new({char,self.object})
    self.OnIndicatorsUpdated = Signal.new()
    self.OnZoomToggled = Signal.new()
    self.indicators = table.clone(INDICATOR_DEFAULTS)

    --guaranteed state vars on loadup
    self.zoomed = Charm.atom(false)
    self.seeking = Charm.atom(false)
    self.zoomFov = Charm.atom(WIDE_FOV)

    --not guaranteed state vars (but they R here for now.
    self.missilePath = Charm.atom("TOP")
    self.nv = Charm.atom(false)

    -- set up ray params: should ignore self and launcher
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterDescendantsInstances = {char, self.object}
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude


    self._maid:GiveTask(self.locker)
    self._maid:GiveTask(self.OnIndicatorsUpdated)
    self._maid:GiveTask(self.OnZoomToggled)
    return self
end


--- set up connections to create functionality
function FGM148System.Setup(self: FGM148System)
    -- set up the CLU
    self.root = ReactRoblox.createRoot(Instance.new("Folder"))
    self.root:render(ReactRoblox.createPortal(e(
        "ScreenGui",{
            IgnoreGuiInset = true
        },{
            e(CLUOptic,
            {
                indicators = self.indicators,
                updateSignal = self.OnIndicatorsUpdated,
                zoomSignal = self.OnZoomToggled, 
            })
        }),PGui))
    
    self._maid:GiveTask(function()
        self.root:unmount()
    end)
    

    self._maid:GiveTask(Mouse.LeftDown:Connect(function()
        print("leftDown")
    end))

    self._maid:GiveTask(Mouse.RightDown:Connect(function()
        self.zoomed(not self.zoomed())
    end))


    self._maid:GiveTask(Keyboard.KeyDown:Connect(function(key: Enum.KeyCode)
        if key == BINDS.Seek then
            self.seeking(true)
        elseif key == BINDS.FOV then
            self.zoomFov(self.zoomFov() == WIDE_FOV and NARROW_FOV or WIDE_FOV)
        elseif key == BINDS.Path then
            self.missilePath(self.missilePath() == "TOP" and "DIR" or "TOP")
        elseif key == BINDS.NV then
            self.nv(not self.nv())
        end
    end))

    self._maid:GiveTask(Keyboard.KeyUp:Connect(function(key: Enum.KeyCode)
        if key == BINDS.Seek then
            self.seeking(false)
        end
    end))


    --handle seeking updates
    self._maid:GiveTask(Charm.effect(function()
        if self.seeking() then
            print(self.seeking())
            self._maid.seekConnection = RUS.RenderStepped:Connect(function(dt: number)
                if not self.locker.lockAtt() then
                    self._maid.seekConnection = nil
                    return
                end

            end)
        else
            self._maid.seekConnection = nil
        end
    end))

    --handle indicator updates
    self._maid:GiveTask(Charm.effect(function()
        self.indicators.SEEK.state = self.seeking()
        self.indicators.TOP.state = self.missilePath() == "TOP"
        self.indicators.DIR.state = self.missilePath() == "DIR"
        self.indicators.NIGHT.state = self.nv()
        self.indicators.DAY.state = not self.nv()
        self.indicators.WFOV.state = self.zoomFov() == WIDE_FOV
        self.indicators.NFOV.state = self.zoomFov() == NARROW_FOV
        self.OnIndicatorsUpdated:Fire(self.indicators)       
    end))
end

function FGM148System.Destroy(self: FGM148System)
    self._maid:DoCleaning()
    --self.clu:Destroy()
end




return FGM148System