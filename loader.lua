-- // GENERATING RANDOM IDENTITY FOR BYPASS
local function GetRandomName()
    local s = ""
    for i = 1, 15 do s = s .. string.char(math.random(97, 122)) end
    return s
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS
local Settings = {
    Aimbot = false, AutoAim = false, AutoShot = false, ShotDelay = 1,
    Smooth = 1, AimPart = "Head", VisibleCheck = false, AimDistance = 500,
    FovEnabled = false, FovRadius = 150, FovVisible = true,
    Box = false, Bone = false, Name = false, Health = false, Distance = false, ESPVisibleCheck = false,
    ThirdPerson = false, TP_Distance = 15, ShiftLock = false, Crosshair = false,
    Fly = false, FlySpeed = 100, Noclip = false, 
    SpeedEnabled = false, WalkSpeed = 16,
    SpinBot = false, SpinSpeed = 50,
    AimKey = Enum.KeyCode.E,
    God9999 = false, GodNoDamage = false
}

-- // DRAWINGS (BYPASS)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1; FovCircle.Color = Color3.fromRGB(0, 255, 150); FovCircle.Transparency = 0.5

local ESP_Cache = {}
local lastShot = 0

-- // INTERNAL VISIBLE CHECK
local function IsVisible(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, targetPart.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return result == nil
end

-- // ESP MOTORU
local function StartESP(obj)
    if ESP_Cache[obj] or obj == LocalPlayer.Character then return end
    local box = Drawing.new("Square"); box.Thickness = 1
    local name = Drawing.new("Text"); name.Size = 13; name.Outline = true; name.Center = true
    local boneLines = {}
    local Bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"LowerTorso", "Left Leg"}, {"LowerTorso", "Right Leg"}}
    for i = 1, #Bones do boneLines[i] = Drawing.new("Line"); boneLines[i].Thickness = 1 end

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        local hum = obj:FindFirstChildOfClass("Humanoid")
        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
        if obj and obj.Parent and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local isVis = IsVisible(hrp)
                local col = (Settings.ESPVisibleCheck and not isVis) and Color3.new(1,0,0) or Color3.new(1,1,1)
                local h = math.abs(Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3.5,0)).Y)
                box.Visible = Settings.Box; box.Size = Vector2.new(h/1.5, h); box.Position = Vector2.new(pos.X - h/3, pos.Y - h/2); box.Color = col
                local info = (Settings.Name and obj.Name or "") .. (Settings.Distance and " ["..math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m]" or "") .. (Settings.Health and "\nHP: "..math.floor(hum.Health) or "")
                name.Visible = (info ~= ""); name.Text = info; name.Position = Vector2.new(pos.X, pos.Y - h/2 - 20); name.Color = col
                for i, bD in pairs(Bones) do
                    local b1, b2 = obj:FindFirstChild(bD[1]), obj:FindFirstChild(bD[2])
                    if b1 and b2 and Settings.Bone then
                        local p1, p2 = Camera:WorldToViewportPoint(b1.Position), Camera:WorldToViewportPoint(b2.Position)
                        boneLines[i].Visible = true; boneLines[i].From = Vector2.new(p1.X, p1.Y); boneLines[i].To = Vector2.new(p2.X, p2.Y); boneLines[i].Color = col
                    else boneLines[i].Visible = false end
                end
            else box.Visible = false; name.Visible = false; for _,v in pairs(boneLines) do v.Visible = false end end
        else box:Remove(); name:Remove(); for _,v in pairs(boneLines) do v:Remove() end ESP_Cache[obj] = nil; Connection:Disconnect() end
    end)
    ESP_Cache[obj] = true
end

-- // CORE ENGINE (STEALTH MODE)
RunService.Heartbeat:Connect(function(delta)
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    
    -- // STEALTH GOD MODE (Fluctuating Health)
    if Hum then
        if Settings.God9999 then Hum.MaxHealth = 9e9; Hum.Health = 9e9 end
        if Settings.GodNoDamage and Hum.Health < 20 and Hum.Health > 0 then 
            Hum.Health = math.random(85, 95) -- 100 yapmaz ki loglara takılmasın
        end
    end

    -- // STEALTH SPEED (CFrame Push instead of WalkSpeed)
    if Settings.SpeedEnabled and Root and Hum and Hum.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * (Settings.WalkSpeed / 50))
    end

    -- // THIRD PERSON OVERRIDE
    if Settings.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = Settings.TP_Distance
        LocalPlayer.CameraMinZoomDistance = Settings.TP_Distance
        if Char then
            for _, v in pairs(Char:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end
        end
    end

    -- // SHIFT LOCK & SPIN
    if Settings.ShiftLock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        if Root and not Settings.SpinBot then
            Root.CFrame = CFrame.new(Root.Position, Root.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
        end
    end

    if Settings.SpinBot and Root then
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
    end
end)

-- // AIMBOT & FOV ENGINE
RunService.RenderStepped:Connect(function()
    FovCircle.Visible = Settings.FovEnabled and Settings.FovVisible
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Position = UserInputService:GetMouseLocation()

    if Settings.Aimbot then
        local visT, closeT, minV, minC = nil, nil, math.huge, Settings.AimDistance
        for obj, _ in pairs(ESP_Cache) do
            local oHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if oHrp and obj:FindFirstChildOfClass("Humanoid").Health > 0 then
                local d = (oHrp.Position - Camera.CFrame.Position).Magnitude
                if d <= Settings.AimDistance then
                    local p = obj:FindFirstChild(Settings.AimPart) or oHrp
                    local pos, sc = Camera:WorldToViewportPoint(p.Position)
                    if sc then
                        local sm = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if not Settings.FovEnabled or sm <= Settings.FovRadius then
                            if IsVisible(p) then if d < minV then minV = d; visT = p end end
                            if d < minC then minC = d; closeT = p end
                        end
                    end
                end
            end
        end
        local target = visT or closeT
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1/(Settings.Smooth*4))
            if Settings.AutoShot and tick() - lastShot > (Settings.ShotDelay / 10) then
                if IsVisible(target) then mouse1click(); lastShot = tick() end
            end
        end
    end
end)

-- // UI (ANTI-DETECTION SETUP)
local SG = Instance.new("ScreenGui", game:GetService("CoreGui")); SG.Name = GetRandomName()
local Main = Instance.new("Frame", SG); Main.Name = GetRandomName(); Main.Size = UDim2.new(0, 520, 0, 530); Main.Position = UDim2.new(0.5, -260, 0.5, -265); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Visible = false; Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(80,80,80)
local Header = Instance.new("TextLabel", Main); Header.Text = "BABALAR V2.19 [STEALTH]"; Header.Size = UDim2.new(1,0,0,50); Header.BackgroundTransparency = 1; Header.TextColor3 = Color3.new(1,1,1); Header.Font = "GothamBold"; Header.TextSize = 20

function AddTog(txt, page, var)
    local btn = Instance.new("TextButton", page); btn.Size = UDim2.new(1, -10, 0, 32); btn.BackgroundTransparency = 1; btn.Text = ""
    local box = Instance.new("Frame", btn); box.Size = UDim2.new(0, 34, 0, 18); box.Position = UDim2.new(1, -40, 0.5, -9); box.BackgroundColor3 = Settings[var] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40,40,40); Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
    local c = Instance.new("Frame", box); c.Size = UDim2.new(0, 14, 0, 14); c.Position = Settings[var] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); c.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", c)
    local l = Instance.new("TextLabel", btn); l.Text = txt; l.Size = UDim2.new(1, -50, 1, 0); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = 0; l.Font = "GothamBold"; l.TextSize = 13
    btn.MouseButton1Click:Connect(function() Settings[var] = not Settings[var]; box.BackgroundColor3 = Settings[var] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40,40,40); c:TweenPosition(Settings[var] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15, true) end)
end

function AddSli(txt, page, min, max, var)
    local f = Instance.new("Frame", page); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt .. ": " .. Settings[var]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = 0; l.Font = "GothamBold"; l.TextSize = 12
    local bg = Instance.new("TextButton", f); bg.Size = UDim2.new(1, 0, 0, 6); bg.Position = UDim2.new(0, 0, 0, 25); bg.BackgroundColor3 = Color3.fromRGB(40,40,40); bg.Text = ""; Instance.new("UICorner", bg)
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((Settings[var]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); Instance.new("UICorner", fill)
    bg.MouseButton1Down:Connect(function() local m; m = RunService.RenderStepped:Connect(function() local p = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); local v = math.floor(min + (max - min) * p); Settings[var], l.Text, fill.Size = v, txt..": "..v, UDim2.new(p, 0, 1, 0) end) UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then m:Disconnect() end end) end)
end

function AddBind(txt, page, var)
    local btn = Instance.new("TextButton", page); btn.Size = UDim2.new(1, -10, 0, 32); btn.BackgroundTransparency = 1; btn.Text = ""
    local l = Instance.new("TextLabel", btn); l.Text = txt; l.Size = UDim2.new(1, -100, 1, 0); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = 0; l.Font = "GothamBold"; l.TextSize = 13
    local b = Instance.new("TextLabel", btn); b.Text = Settings[var].Name; b.Size = UDim2.new(0, 80, 0, 24); b.Position = UDim2.new(1, -85, 0.5, -12); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    btn.MouseButton1Click:Connect(function() b.Text = "..."; local c; c = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then Settings[var] = i.KeyCode; b.Text = i.KeyCode.Name; c:Disconnect() end end) end)
end

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 130, 1, -60); Sidebar.Position = UDim2.new(0, 10, 0, 55); Sidebar.BackgroundTransparency = 1; Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 8)
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -160, 1, -65); Container.Position = UDim2.new(0, 150, 0, 55); Container.BackgroundTransparency = 1
local Pages = { Aimbot = Instance.new("ScrollingFrame", Container), ESP = Instance.new("ScrollingFrame", Container), Rage = Instance.new("ScrollingFrame", Container), Misc = Instance.new("ScrollingFrame", Container) }
for _, p in pairs(Pages) do p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0; p.CanvasSize = UDim2.new(0,0,1.5,0); Instance.new("UIListLayout", p).Padding = UDim.new(0, 10) end

AddTog("Enable Aimbot", Pages.Aimbot, "Aimbot"); AddBind("Quick Toggle Key", Pages.Aimbot, "AimKey"); AddTog("Auto Shot", Pages.Aimbot, "AutoShot"); AddSli("Shot Delay", Pages.Aimbot, 1, 20, "ShotDelay"); AddTog("Visible Check", Pages.Aimbot, "VisibleCheck"); AddTog("Use FOV Circle", Pages.Aimbot, "FovEnabled"); AddTog("Draw FOV Circle", Pages.Aimbot, "FovVisible"); AddSli("FOV Radius", Pages.Aimbot, 30, 800, "FovRadius"); AddSli("Max Distance", Pages.Aimbot, 50, 3000, "AimDistance"); AddSli("Smoothness", Pages.Aimbot, 1, 25, "Smooth")
AddTog("Box ESP", Pages.ESP, "Box"); AddTog("Skeleton", Pages.ESP, "Bone"); AddTog("Name Tag", Pages.ESP, "Name"); AddTog("Health Info", Pages.ESP, "Health"); AddTog("Distance Info", Pages.ESP, "Distance"); AddTog("Vis Check ESP", Pages.ESP, "ESPVisibleCheck")
AddTog("SpinBot", Pages.Rage, "SpinBot"); AddSli("Spin Speed", Pages.Rage, 10, 500, "SpinSpeed"); AddTog("God Mode (999k HP)", Pages.Rage, "God9999"); AddTog("God Mode (Auto Heal)", Pages.Rage, "GodNoDamage"); AddTog("Third Person", Pages.Rage, "ThirdPerson"); AddSli("TP Distance", Pages.Rage, 5, 120, "TP_Distance"); AddTog("Force Shift Lock", Pages.Rage, "ShiftLock")
AddTog("Speed Hack", Pages.Misc, "SpeedEnabled"); AddSli("Walk Speed", Pages.Misc, 16, 300, "WalkSpeed"); AddTog("Noclip", Pages.Misc, "Noclip"); AddTog("Admin Fly", Pages.Misc, "Fly"); AddSli("Fly Speed", Pages.Misc, 20, 500, "FlySpeed")

for _, n in pairs({"Aimbot", "ESP", "Rage", "Misc"}) do
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 35); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 13; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() for _, v in pairs(Pages) do v.Visible = false end Pages[n].Visible = true end)
end

UserInputService.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Settings.AimKey then Settings.Aimbot = not Settings.Aimbot end
        if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
    end
end)

local d, ds, sp; Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and d then local dl = i.Position - ds Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

Pages.Aimbot.Visible = true
task.spawn(function() while task.wait(2) do for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v ~= LocalPlayer.Character and not ESP_Cache[v] then StartESP(v) end end end end)