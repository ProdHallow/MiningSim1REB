getgenv().Name = getgenv().Name or "BhopGod & AirJordan Made This!"
getgenv().Depth = getgenv().Depth or 410
getgenv().SellThreshold = getgenv().SellThreshold or 30000
getgenv().Mode = getgenv().Mode or "MINING"
getgenv().Running = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Remote, ScreenGui, HRP
local Recovering = false
local Connections = {}
local RebirthBound = false

-- // HELPER FUNCTIONS // --
local function split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        result[#result + 1] = match
    end
    return result
end

local function AddConnection(conn)
    if conn then Connections[#Connections + 1] = conn end
    return conn
end

local function ClearConnections()
    for i = #Connections, 1, -1 do
        if Connections[i] then pcall(function() Connections[i]:Disconnect() end) end
        Connections[i] = nil
    end
    if RebirthBound then
        pcall(function() RunService:UnbindFromRenderStep("Rebirth") end)
        RebirthBound = false
    end
end

-- // GUI SETUP // --
if game.CoreGui:FindFirstChild("MinerGUI") then
    game.CoreGui:FindFirstChild("MinerGUI"):Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MinerGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 220, 0, 170)
-- POSITION: BOTTOM RIGHT
Main.Position = UDim2.new(1, -240, 1, -190)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TitleBar.Parent = Main
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -35, 1, 0)
TitleText.Position = UDim2.new(0, 8, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⛏ HYPER MINER"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 5)
CloseBtnCorner.Parent = CloseBtn

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, -16, 0, 18)
ModeLabel.Position = UDim2.new(0, 8, 0, 38)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "SELECT MODE:"
ModeLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = Main

local MiningBtn = Instance.new("TextButton")
MiningBtn.Size = UDim2.new(0.46, 0, 0, 34)
MiningBtn.Position = UDim2.new(0.02, 0, 0, 60)
MiningBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
MiningBtn.Text = "⛏ MINING"
MiningBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiningBtn.Font = Enum.Font.GothamBold
MiningBtn.Parent = Main
local MiningBtnCorner = Instance.new("UICorner")
MiningBtnCorner.CornerRadius = UDim.new(0, 6)
MiningBtnCorner.Parent = MiningBtn

local RebirthBtn = Instance.new("TextButton")
RebirthBtn.Size = UDim2.new(0.46, 0, 0, 34)
RebirthBtn.Position = UDim2.new(0.52, 0, 0, 60)
RebirthBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
RebirthBtn.Text = "🔄 REBIRTH"
RebirthBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
RebirthBtn.Font = Enum.Font.GothamBold
RebirthBtn.Parent = Main
local RebirthBtnCorner = Instance.new("UICorner")
RebirthBtnCorner.CornerRadius = UDim.new(0, 6)
RebirthBtnCorner.Parent = RebirthBtn

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.96, 0, 0, 42)
StartBtn.Position = UDim2.new(0.02, 0, 0, 100)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
StartBtn.Text = "▶ START"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.Parent = Main
local StartBtnCorner = Instance.new("UICorner")
StartBtnCorner.CornerRadius = UDim.new(0, 6)
StartBtnCorner.Parent = StartBtn

local StatusInfo = Instance.new("TextLabel")
StatusInfo.Size = UDim2.new(1, -16, 0, 18)
StatusInfo.Position = UDim2.new(0, 8, 0, 148)
StatusInfo.BackgroundTransparency = 1
StatusInfo.Text = "Mode: Efficient Mining"
StatusInfo.TextColor3 = Color3.fromRGB(255, 180, 80)
StatusInfo.Font = Enum.Font.GothamBold
StatusInfo.TextXAlignment = Enum.TextXAlignment.Left
StatusInfo.Parent = Main

Gui.Parent = game.CoreGui

-- // GUI INTERACTION // --
local function SelectMode(mode)
    getgenv().Mode = mode
    if mode == "MINING" then
        MiningBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        MiningBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        RebirthBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        RebirthBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        StatusInfo.Text = "Mode: Max Mining Power"
    else
        RebirthBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 200)
        RebirthBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        MiningBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        MiningBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        StatusInfo.Text = "Mode: Rebirth Focus"
    end
end

MiningBtn.MouseButton1Click:Connect(function() SelectMode("MINING") end)
RebirthBtn.MouseButton1Click:Connect(function() SelectMode("REBIRTH") end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().Running = false
    ClearConnections()
    if Gui then Gui:Destroy() end
    -- Reset physics on close
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

-- // MAIN LOGIC (FROM SOURCE) // --

local function setupAntiAfk()
    VirtualUser:CaptureController()
    AddConnection(LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end))
end

local function waitForGameReady()
    repeat task.wait() until game:IsLoaded()
    local screenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

    while screenGui.LoadingFrame.BackgroundTransparency == 0 do
        for _, connection in pairs(getconnections(screenGui.LoadingFrame.Quality.LowQuality.MouseButton1Down)) do
            connection:Fire()
        end
        task.wait()
    end

    while true do
        if pcall(function() LocalPlayer.leaderstats:WaitForChild("Blocks Mined") end) and
           pcall(function() screenGui.StatsFrame.Coins:FindFirstChild("Amount") end) and
           screenGui.StatsFrame.Tokens.Amount.Text ~= "Loading..." then
            break
        end
        task.wait(1)
    end

    pcall(function()
        screenGui.TeleporterFrame:Destroy()
        screenGui.StatsFrame.Sell:Destroy()
        screenGui.MainButtons.Surface:Destroy()
    end)

    return screenGui
end

local function getRemote()
    local ok, rem = pcall(function()
        local data = getsenv(LocalPlayer.PlayerGui.ScreenGui.ClientScript).displayCurrent
        local values = getupvalue(data, 8)
        return values["RemoteEvent"]
    end)
    return ok and rem or nil
end

-- Source Code Logic: Anchoring for spawn TP
local function moveToLavaSpawn()
    if not Remote or not HRP then return end
    
    HRP.Anchored = true
    LocalPlayer.Character.Humanoid.WalkSpeed = 0
    LocalPlayer.Character.Humanoid.JumpPower = 0
    
    Remote:FireServer("MoveTo", {{"LavaSpawn"}})
    
    local part = Instance.new("Part", workspace)
    part.Anchored = true
    part.Size = Vector3.new(10, 0.5, 100)
    part.Material = Enum.Material.ForceField
    part.Position = Vector3.new(21, 9.5, 26285)
    
    task.wait(1)
    HRP.Anchored = false
    
    while HRP.Position.Z > 26220 do
        HRP.CFrame = CFrame.new(Vector3.new(HRP.Position.X, 13.05, HRP.Position.Z - 0.5))
        task.wait()
    end
    HRP.CFrame = CFrame.new(18, 10, 26220)
end

local function mineUntilDepth(targetDepth)
    local depthText = split(ScreenGui.TopInfoFrame.Depth.Text, " ")
    while tonumber(depthText[1]) < targetDepth do
        local min = HRP.CFrame + Vector3.new(-1, -10, -1)
        local max = HRP.CFrame + Vector3.new(1, 0, 1)
        local region = Region3.new(min.Position, max.Position)
        local parts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Blocks}, 5)
        for _, block in pairs(parts) do
            Remote:FireServer("MineBlock", {{block.Parent}})
            RunService.Heartbeat:Wait()
        end
        depthText = split(ScreenGui.TopInfoFrame.Depth.Text, " ")
        task.wait()
    end
end

local function startMainLoop()
    -- Rebirth Handler (Source Logic)
    local coinsAmountLbl = LocalPlayer.leaderstats.Coins
    local rebirthsAmount = LocalPlayer.leaderstats.Rebirths
    
    local function getCoinsAmount()
        local amount = tostring(coinsAmountLbl.Value):gsub(',', '')
        return tonumber(amount) or 0
    end

    RebirthBound = true
    RunService:BindToRenderStep("Rebirth", Enum.RenderPriority.First.Value, function()
        if not getgenv().Running then return end
        if getCoinsAmount() >= (10000000 * (rebirthsAmount.Value + 1)) then
            Remote:FireServer("Rebirth", {{}})
            Remote:FireServer("Rebirth", {{}})
            Remote:FireServer("Rebirth", {{}})
            task.defer(function()
                Remote:FireServer("Rebirth", {{}})
                Remote:FireServer("Rebirth", {{}})
            end)
        end
    end)

    -- Recovery Handler (Source Logic)
    local depthAmountLbl = ScreenGui.TopInfoFrame.Depth
    AddConnection(depthAmountLbl.Changed:Connect(function()
        local depthText = split(depthAmountLbl.Text, " ")
        if tonumber(depthText[1]) >= 1500 and not Recovering then
            Recovering = true
            moveToLavaSpawn()
            task.wait(5)
            Recovering = false
        end
    end))

    local inventoryLbl = ScreenGui.StatsFrame2.Inventory.Amount
    local function getInventoryAmount()
        local amount = tostring(inventoryLbl.Text):gsub('%s+', ''):gsub(',', '')
        local inv = amount:split("/")
        return tonumber(inv[1]) or 0
    end

    local sellArea = CFrame.new(41.96064, 14, -1239.64648, 1, 0, 0, 0, 1, 0, 0, 0, 1)

    -- Source Code Logic: PlatformStand for return trip
    local function setPlatformStand(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = state
            if state and HRP then HRP.Velocity = Vector3.new(0,0,0) end
        end
    end

    -- Main Mining Loop
    while getgenv().Running do
        if HRP then
            local miningRange = 10
            local minp = HRP.CFrame.Position + Vector3.new(-miningRange, -miningRange, -miningRange)
            local maxp = HRP.CFrame.Position + Vector3.new(miningRange, miningRange, miningRange)
            local region = Region3.new(minp, maxp)
            local parts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Blocks}, 100)

            for _, block in pairs(parts) do
                if block:IsA("BasePart") then
                    Remote:FireServer("MineBlock", {{block.Parent}})
                    repeat RunService.Heartbeat:Wait() until not Recovering
                end

                if getInventoryAmount() >= getgenv().SellThreshold then
                    if HRP then
                        local savedPosition = HRP.Position
                        
                        -- Sell Loop (Source Logic)
                        while getInventoryAmount() >= getgenv().SellThreshold do
                            HRP.CFrame = sellArea
                            Remote:FireServer("SellItems", {{}})
                            Remote:FireServer("SellItems", {{}})
                            Remote:FireServer("SellItems", {{}})
                            task.defer(function()
                                Remote:FireServer("SellItems", {{}})
                                Remote:FireServer("SellItems", {{}})
                            end)
                            RunService.RenderStepped:Wait()
                        end

                        -- Return Loop (Source Logic uses PlatformStand here)
                        setPlatformStand(true)
                        local startTime = os.time()
                        while (HRP.Position - savedPosition).Magnitude > 1 do
                            HRP.CFrame = CFrame.new(18, savedPosition.Y + 2, 26220)
                            RunService.Heartbeat:Wait()
                            if os.time() - startTime > 5 then break end
                        end
                        setPlatformStand(false)
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

local function stopScript()
    getgenv().Running = false
    Recovering = false
    ClearConnections()
    
    StatusInfo.Text = getgenv().Mode == "MINING" and "Mode: Max Mining Power" or "Mode: Rebirth Focus"
    StartBtn.Text = "▶ START"
    StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)

    -- Safety Reset
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        if HRP then HRP.Anchored = false end
    end
end

local function startScript()
    if getgenv().Running then return end
    getgenv().Running = true
    Recovering = false
    
    StartBtn.Text = "⏹ STOP"
    StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    
    setupAntiAfk()
    
    ScreenGui = waitForGameReady()
    if not ScreenGui then stopScript() return end

    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            LocalPlayer.Character.Head.CustomPlayerTag.PlayerName.Text = getgenv().Name
            LocalPlayer.Character.Head.CustomPlayerTag.MinerRank.Text = getgenv().Name
        end
    end)

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = char:WaitForChild("HumanoidRootPart")

    AddConnection(workspace.Collapsed.Changed:Connect(function()
        if workspace.Collapsed.Value and getgenv().Running then
            spawn(function() startScript() end)
        end
    end))

    Remote = getRemote()
    if not Remote then stopScript() return end

    -- Load Trackers
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ProdHallow/Miningsimrebirthtracker/main/miningsimrebirthtracker", true))() end)
    task.wait(0.5)
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/DeleteAssetMinSim1/main/deleteassetsminingsim'))() end)
    task.wait(0.5)
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/rebirthtracker/main/rebirthtracker'))() end)
    task.wait(0.5)

    moveToLavaSpawn()
    mineUntilDepth(getgenv().Depth)
    startMainLoop()
end

StartBtn.MouseButton1Click:Connect(function()
    if getgenv().Running then stopScript() else task.spawn(startScript) end
end)

SelectMode("MINING")
print("HYPER MINER LOADED - GUI READY")
