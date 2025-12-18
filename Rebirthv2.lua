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

local function split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        result[#result + 1] = match
    end
    return result
end

local function AddConnection(conn)
    if conn then Connections[#Connections + 1] = conn end
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

local function resetCharacterPhysics()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if hrp then hrp.Anchored = false end
    end
end

-- GUI SETUP
if game.CoreGui:FindFirstChild("MinerGUI") then
    game.CoreGui:FindFirstChild("MinerGUI"):Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MinerGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 220, 0, 170)
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
StatusInfo.Text = "Mode: Max Mining Power"
StatusInfo.TextColor3 = Color3.fromRGB(255, 180, 80)
StatusInfo.Font = Enum.Font.GothamBold
StatusInfo.TextXAlignment = Enum.TextXAlignment.Left
StatusInfo.Parent = Main

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
    resetCharacterPhysics()
    Gui:Destroy()
end)

-- MAIN LOGIC
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
        for _, conn in pairs(getconnections(screenGui.LoadingFrame.Quality.LowQuality.MouseButton1Down)) do
            conn:Fire()
        end
        task.wait()
    end

    while true do
        if pcall(function() return LocalPlayer.leaderstats:WaitForChild("Blocks Mined") end) and
           pcall(function() return screenGui.StatsFrame.Coins:FindFirstChild("Amount") end) and
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
    
    while HRP.Position.Z > 26220 and getgenv().Running do
        HRP.CFrame = CFrame.new(Vector3.new(HRP.Position.X, 13.05, HRP.Position.Z - 0.5))
        task.wait()
    end
    HRP.CFrame = CFrame.new(18, 10, 26220)
    if part then part:Destroy() end
end

local function mineUntilDepth(targetDepth)
    if not ScreenGui or not HRP then return end
    local depthText = split(ScreenGui.TopInfoFrame.Depth.Text, " ")
    while tonumber(depthText[1]) < targetDepth and getgenv().Running do
        if not HRP or not HRP.Parent then break end
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

local function runBotLogic()
    setupAntiAfk()
    Recovering = false
    
    ScreenGui = waitForGameReady()
    if not ScreenGui then 
        getgenv().Running = false
        StartBtn.Text = "▶ START"
        StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
        return 
    end

    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            LocalPlayer.Character.Head.CustomPlayerTag.PlayerName.Text = getgenv().Name
            LocalPlayer.Character.Head.CustomPlayerTag.MinerRank.Text = getgenv().Name
        end
    end)

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = char:WaitForChild("HumanoidRootPart")

    Remote = getRemote()
    if not Remote then 
        getgenv().Running = false 
        StartBtn.Text = "▶ START"
        StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
        return 
    end

    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ProdHallow/Miningsimrebirthtracker/main/miningsimrebirthtracker", true))() end)
    task.wait(0.5)
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/DeleteAssetMinSim1/main/deleteassetsminingsim'))() end)
    task.wait(0.5)
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/rebirthtracker/main/rebirthtracker'))() end)
    task.wait(0.5)

    moveToLavaSpawn()
    mineUntilDepth(getgenv().Depth)

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

    local depthAmountLbl = ScreenGui.TopInfoFrame.Depth
    AddConnection(depthAmountLbl.Changed:Connect(function()
        local depthText = split(depthAmountLbl.Text, " ")
        local depth = tonumber(depthText[1])
        if depth and depth >= 1500 and not Recovering and getgenv().Running then
            Recovering = true
            moveToLavaSpawn()
            task.wait(2)
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

    while getgenv().Running do
        if HRP and HRP.Parent then
            local miningRange = 10
            local minp = HRP.CFrame.Position + Vector3.new(-miningRange, -miningRange, -miningRange)
            local maxp = HRP.CFrame.Position + Vector3.new(miningRange, miningRange, miningRange)
            local region = Region3.new(minp, maxp)
            local parts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Blocks}, 100)

            for _, block in pairs(parts) do
                if not getgenv().Running then break end
                if not HRP or not HRP.Parent then break end
                
                if block:IsA("BasePart") then
                    Remote:FireServer("MineBlock", {{block.Parent}})
                    repeat RunService.Heartbeat:Wait() until not Recovering
                end

                if getInventoryAmount() >= getgenv().SellThreshold then
                    if HRP then
                        local savedPosition = HRP.Position
                        
                        while getInventoryAmount() >= getgenv().SellThreshold and getgenv().Running do
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

                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.PlatformStand = true
                        end
                        
                        local startTime = os.time()
                        while (HRP.Position - savedPosition).Magnitude > 1 and getgenv().Running do
                            HRP.CFrame = CFrame.new(18, savedPosition.Y + 2, 26220)
                            RunService.Heartbeat:Wait()
                            if os.time() - startTime > 5 then break end
                        end
                        
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.PlatformStand = false
                        end
                    end
                end
            end
        else
            break
        end
        RunService.Heartbeat:Wait()
    end
end

local function monitorEvents()
    ClearConnections()
    
    AddConnection(LocalPlayer.CharacterAdded:Connect(function()
        if getgenv().Running then
            task.wait(2)
            task.spawn(runBotLogic)
        end
    end))
    
    AddConnection(workspace.Collapsed.Changed:Connect(function()
        if workspace.Collapsed.Value and getgenv().Running then
            task.wait(1)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    end))
end

local function toggleScript()
    if getgenv().Running then
        getgenv().Running = false
        ClearConnections()
        resetCharacterPhysics()
        Recovering = false
        StartBtn.Text = "▶ START"
        StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
    else
        getgenv().Running = true
        Recovering = false
        StartBtn.Text = "⏹ STOP"
        StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        monitorEvents()
        task.spawn(runBotLogic)
    end
end

StartBtn.MouseButton1Click:Connect(toggleScript)
SelectMode("MINING")
