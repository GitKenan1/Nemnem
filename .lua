task.wait(3)

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local RS              = game:GetService("ReplicatedStorage")
local Lighting        = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LP              = Players.LocalPlayer

do
    local t0 = os.clock()
    while type(_G.MeerkoBootWait) ~= "function" and os.clock() - t0 < 20 do task.wait(0.1) end
end
if type(_G.MeerkoBootWait)      ~= "function" then _G.MeerkoBootWait = function() end end
if type(_G.MeerkoCarpetEngaging) ~= "function" then _G.MeerkoCarpetEngaging = function() return false end end
if type(_G.MeerkoSaveSettings)   ~= "function" then _G.MeerkoSaveSettings = function() end end

local function equipCarpet() if _G.MeerkoEquipCarpet then return _G.MeerkoEquipCarpet() end end
local function scanAllPets() if _G.MeerkoScanAllPets then return _G.MeerkoScanAllPets() end return {} end

if _G.MeerkoAntiFlash        == nil then _G.MeerkoAntiFlash        = true end
if _G.MeerkoAntiBee          == nil then _G.MeerkoAntiBee          = true end
if _G.MeerkoInfJump          == nil then _G.MeerkoInfJump          = true end
if _G.MeerkoInvisDepth       == nil then _G.MeerkoInvisDepth       = 4.2  end
if _G.MeerkoInvisAngle       == nil then _G.MeerkoInvisAngle       = 180  end
if _G.MeerkoAlertMinGen      == nil then _G.MeerkoAlertMinGen      = 80e6 end
if _G.MeerkoCarpetSpeedValue == nil then _G.MeerkoCarpetSpeedValue = 140  end
if _G.MeerkoFOVEnabled       == nil then _G.MeerkoFOVEnabled       = false end

-- MOBİL ÜÇÜN AÇ/BAĞLA DÜYMƏSİ (FLOATİNG TOGGLE BUTTON)
task.spawn(function()
    pcall(function()
        local playerGui = LP:WaitForChild("PlayerGui", 10)
        if not playerGui then return end
        
        -- Əgər əvvəlcədən varsa silək
        if playerGui:FindFirstChild("MeerkoMobileToggle") then
            playerGui.MeerkoMobileToggle:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MeerkoMobileToggle"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = playerGui

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "ToggleButton"
        toggleBtn.Size = UDim2.new(0, 55, 0, 55)
        toggleBtn.Position = UDim2.new(0, 20, 0, 150)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        toggleBtn.BorderColor3 = Color3.fromRGB(100, 100, 255)
        toggleBtn.BorderSizePixel = 2
        toggleBtn.Text = "⚙️"
        toggleBtn.TextSize = 26
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Active = true
        toggleBtn.Draggable = true -- Mobil üçün sürüklənə bilən düymə
        toggleBtn.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = toggleBtn

        -- Düyməyə toxunanda menyunu göstərmək/gizlətmək üçün funksionallıq
        toggleBtn.MouseButton1Click:Connect(function()
            -- Əgər əsas UI mövcuddursa onun görünürlüyünü dəyişirik
            local mainUI = playerGui:FindFirstChild("MeerkoMainUI") or playerGui:FindFirstChild("MeerkoUI")
            if mainUI then
                mainUI.Enabled = not mainUI.Enabled
            else
                -- Əgər UI hələ yaradılmayıbsa, bildiriş verə bilərik
                print("[Meerko] Mobil menyu düyməsi aktivdir.")
            end
        end)
    end)
end)

-- FOV Tənzimlənməsi
task.spawn(function()
    while true do
        if _G.MeerkoFOVEnabled then
            local cam = workspace.CurrentCamera
            local target = tonumber(_G.MeerkoFOV) or 70
            if cam and math.abs(cam.FieldOfView - target) > 0.1 then
                cam.FieldOfView = target
            end
        end
        task.wait(0.2)
    end
end)

;(function()
    local FX = { ParticleEmitter = true, Beam = true, Trail = true, Fire = true,
        Smoke = true, Sparkles = true, Explosion = true, PointLight = true,
        SpotLight = true, SurfaceLight = true }

    local function kill(item)
        if pcall(function() item:Destroy() end) then return end
        pcall(function()
            for _, d in ipairs(item:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                    d.CanCollide = false
                    d.CanQuery = false
                    d.CastShadow = false
                    d.LocalTransparencyModifier = 1
                elseif FX[d.ClassName] then
                    d.Enabled = false
                elseif d:IsA("Sound") then
                    d.Volume = 0
                    d:Stop()
                end
            end
        end)
    end

    local function strip(char)
        if not char or _G.MeerkoAntiFlash == false then return end
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Accessory") then kill(item) end
        end
    end

    local hooked = setmetatable({}, { __mode = "k" })
    local function hookChar(char)
        if not char or hooked[char] then return end
        hooked[char] = true
        strip(char)
        char.ChildAdded:Connect(function(c)
            if c:IsA("Accessory") and _G.MeerkoAntiFlash ~= false then
                task.defer(kill, c)
            end
        end)
    end
    local function hookPlayer(p)
        if p.Character then task.spawn(hookChar, p.Character) end
        p.CharacterAdded:Connect(hookChar)
    end
    for _, p in ipairs(Players:GetPlayers()) do pcall(hookPlayer, p) end
    Players.PlayerAdded:Connect(hookPlayer)

    workspace.DescendantAdded:Connect(function(d)
        if _G.MeerkoAntiFlash == false then return end
        if d.ClassName == "Accessory" then
            local par = d.Parent
            if par and par:FindFirstChildOfClass("Humanoid") then task.defer(kill, d) end
        end
    end)

    task.spawn(function()
        while true do
            if _G.MeerkoAntiFlash ~= false then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then strip(p.Character) end
                end
                for _, m in ipairs(workspace:GetChildren()) do
                    if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then strip(m) end
                end
            end
            task.wait(6) 
        end
    end)
end)()

;(function()
    local TeleportService = game:GetService("TeleportService")
    if _G.MeerkoCleanErrStop then pcall(_G.MeerkoCleanErrStop) end

    local _ref = cloneref or function(x) return x end
    local GS = _ref(game:GetService("GuiService"))
    local running, conns = true, {}

    task.spawn(function()
        while running do
            pcall(function() GS:ClearError() end)
            task.wait(0.1)
        end
    end)

    conns[#conns + 1] = TeleportService.TeleportInitFailed:Connect(function(plr, result, message, placeId)
        if plr ~= LP then return end
        local name = "Unknown"
        pcall(function() name = result and result.Name or tostring(result) end)
        _G.MeerkoCleanErrLast = {
            result = name, message = tostring(message or ""),
            placeId = placeId, at = os.clock(),
        }
    end)

    _G.MeerkoCleanErrStop = function()
        running = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        _G.MeerkoCleanErrStop = nil
    end
end)()

;(function()
    local held = false
    local function hop()
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        hrp.Velocity = Vector3.new(hrp.Velocity.X, hum.JumpPower or 50, hrp.Velocity.Z)
    end
    local function on() return _G.MeerkoInfJump ~= false end
    UIS.JumpRequest:Connect(function() if on() then hop() end end)
    UIS.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.Space then held = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.Space then held = false end
    end)
    RunService.Heartbeat:Connect(function() if held and on() then hop() end end)
end)()

if _G.AntiDieDisabled == nil then _G.AntiDieDisabled = false end
task.spawn(function()
local __P = game:GetService("Players")
while not __P.LocalPlayer do task.wait() end
local okAD, errAD = pcall(function()
    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP         = Players.LocalPlayer

    local _conn, _diedConn, _hbConn
    local function _harden(hum)
        pcall(function() hum.BreakJointsOnDeath = false end)
        pcall(function() hum.RequiresNeck = false end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
    end
    local function _revive(hum)
        pcall(function() hum.Health = hum.MaxHealth end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    local function _bind()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        _harden(hum)
        if _conn then pcall(function() _conn:Disconnect() end) end
        if _diedConn then pcall(function() _diedConn:Disconnect() end) end
        if _hbConn then pcall(function() _hbConn:Disconnect() end) end
        _conn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if _G.AntiDieDisabled then return end
            if hum.Health <= 0 then _revive(hum) end
        end)
        _diedConn = hum.Died:Connect(function()
            if _G.AntiDieDisabled then return end
            _revive(hum)
        end)
        local _lastHarden = 0
        _hbConn = RunService.Heartbeat:Connect(function()
            if _G.AntiDieDisabled or not hum or not hum.Parent then return end
            local now = os.clock()
            if now - _lastHarden >= 0.5 then _lastHarden = now; _harden(hum) end
            if hum.Health <= 0 then _revive(hum) end
            
            if _G.MeerkoStealHold and hum.Health < hum.MaxHealth then
                pcall(function() hum.Health = hum.MaxHealth end)
            end
            local char = hum.Parent
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hrp then
                local state = hum:GetState()
                local _rag = (state == Enum.HumanoidStateType.Physics
                    or state == Enum.HumanoidStateType.Ragdoll
                    or state == Enum.HumanoidStateType.FallingDown)
                if not _rag then
                    local _et = tonumber(LP:GetAttribute("RagdollEndTime"))
                    if _et and (_et - workspace:GetServerTimeNow()) > 0 then _rag = true end
                end
                if _rag then
                    pcall(function() LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                    if not _G.__meerkoResetBusy and LP:GetAttribute("Stealing") ~= true then
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
                    end
                    local cam = workspace.CurrentCamera
                    if cam and cam.CameraSubject ~= hum then
                        pcall(function() cam.CameraSubject = hum end)
                    end
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("BallSocketConstraint") or (obj.Name and obj.Name:find("RagdollAttachment")) then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
        end)
    end
    _bind()
    LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then _harden(hum) end
        task.wait(0.1)
        _bind()
    end)
end)
if not okAD then warn("[ANTI-DIE] BLOC EN ERREUR: " .. tostring(errAD)) end
end)

;(function()
    local Lighting = game:GetService("Lighting")
    local BAD = { Blue = true, DiscoEffect = true, BeeBlur = true,
        Flashbang = true, ColorCorrection = true }
    local function on() return _G.MeerkoAntiBee ~= false end

    local function nuke(o)
        if on() and o and o.Parent and BAD[o.Name] then pcall(function() o:Destroy() end) end
    end

    local buzz
    local function muteBuzz()
        if not on() then return end
        pcall(function()
            if not (buzz and buzz.Parent) then
                local ctl = RS:FindFirstChild("Controllers")
                local item = ctl and ctl:FindFirstChild("ItemController")
                local bee = item and item:FindFirstChild("BeeLauncherController")
                local s = bee and bee:FindFirstChild("Buzzing")
                if s and s:IsA("Sound") then buzz = s end
            end
            if buzz then
                buzz.Volume = 0
                if buzz.IsPlaying then buzz:Stop() end
            end
        end)
    end

    local guarded = {}
    local function guard(Controls, original)
        if not Controls or guarded[Controls] then return end
        local base = original or Controls.moveFunction
        if not base then return end
        local function safeMove(self, mv, rtc) return base(self, mv, rtc) end
        guarded[Controls] = safeMove
        Controls.moveFunction = safeMove
        RunService.Heartbeat:Connect(function()
            if not on() then return end
            if Controls.moveFunction ~= safeMove then Controls.moveFunction = safeMove end
        end)
    end
    local function protect()
        pcall(function()
            local cc = RS:FindFirstChild("Controllers")
            local mod = cc and cc:FindFirstChild("CharacterController")
            local m = mod and require(mod)
            if type(m) == "table" then guard(m.Controls, m.originalMoveFunction) end
        end)
        pcall(function()
            local ps = LP:WaitForChild("PlayerScripts", 5)
            local pm = ps and ps:FindFirstChild("PlayerModule")
            if pm then guard(require(pm):GetControls()) end
        end)
    end

    task.spawn(function()
        LP:WaitForChild("PlayerScripts", 8)
        _G.MeerkoBootWait()
        Lighting.DescendantAdded:Connect(nuke)
        do local n = 0
            for _, o in ipairs(Lighting:GetDescendants()) do
                n = n + 1; if n % 150 == 0 then task.wait() end
                nuke(o)
            end
        end
        protect()
        local acc = 1
        RunService.Heartbeat:Connect(function(dt)
            if not on() then return end
            local cam = workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - 20) < 0.01 then
                cam.FieldOfView = tonumber(_G.MeerkoFOV) or 70
            end
            acc = acc + dt
            if acc < 0.5 then return end
            acc = 0
            muteBuzz()
        end)
    end)
    LP.CharacterAdded:Connect(function() task.delay(1, protect) end)
end)()

;(function()
    local active, conns = false, {}
    local realHRP, cloneHRP, track, hip, origT
    local stuck, restarting = false, false
    local start, stop

    local function depth()
        return 0.01 + (math.clamp(tonumber(_G.MeerkoInvisDepth) or 4.2, 0, 10) / 10) * 0.19
    end
    local function angle()
        return math.clamp(tonumber(_G.MeerkoInvisAngle) or 0, 0, 360)
    end
    local function add(c) conns[#conns + 1] = c end
    local function rewire(char, from, to)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == from then v.Part0 = to end
                if v.Part1 == from then v.Part1 = to end
            end
        end
    end

    stop = function()
        active, stuck = false, false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        if origT then
            for p, v in pairs(origT) do
                if p and p.Parent then pcall(function() p.LocalTransparencyModifier = v end) end
            end
            origT = nil
        end
        if track then
            pcall(function() track:AdjustSpeed(1) track:Stop(0) track:Destroy() end)
            track = nil
        end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if realHRP and realHRP:IsDescendantOf(game) and hum then
            local tmp = Instance.new("Model")
            tmp.Parent = game
            char.Parent = tmp
            realHRP.Parent = char
            char.PrimaryPart = realHRP
            char.Parent = workspace
            realHRP.CanCollide = true
            rewire(char, cloneHRP, realHRP)
            if cloneHRP then
                local at = cloneHRP.CFrame
                cloneHRP:Destroy()
                cloneHRP = nil
                realHRP.CFrame = at
            end
            hum.HipHeight = hip or 0
            tmp:Destroy()
        end
        realHRP, cloneHRP = nil, nil
        _G.MeerkoInvisActive = false
    end

    local function animTrick(char, hum)
        if not (char and hum and hum.Health > 0) then return end
        local a = Instance.new("Animation")
        a.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
        local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        track = animator:LoadAnimation(a)
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play(0, 1, 0)
        a:Destroy()
        add(track.Stopped:Connect(function()
            if active then animTrick(char, hum) end
        end))
        task.defer(function()
            if not track then return end
            track.TimePosition = 0.7
            task.delay(0.1, function() if track then track:AdjustSpeed(math.huge) end end)
        end)
    end

    start = function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or active then return false end

        local folder = workspace:FindFirstChild(LP.Name)
        if folder then
            for _, n in ipairs({ "DoubleRig", "Constraints" }) do
                local x = folder:FindFirstChild(n)
                if x then x:Destroy() end
            end
            add(folder.ChildAdded:Connect(function(c)
                if c.Name == "DoubleRig" or c.Name == "Constraints" then c:Destroy() end
            end))
        end
        for _, s in ipairs({ "Dead", "FallingDown", "Ragdoll" }) do
            hum:SetStateEnabled(Enum.HumanoidStateType[s], false)
        end

        hip = hum.HipHeight
        realHRP = char:FindFirstChild("HumanoidRootPart")
        if not (realHRP and realHRP.Parent) then return false end

        local tmp = Instance.new("Model")
        tmp.Parent = game
        char.Parent = tmp
        cloneHRP = realHRP:Clone()
        cloneHRP.Parent = char
        realHRP.Parent = workspace.CurrentCamera
        cloneHRP.CFrame = realHRP.CFrame
        char.PrimaryPart = cloneHRP
        char.Parent = workspace
        rewire(char, realHRP, cloneHRP)
        tmp:Destroy()
