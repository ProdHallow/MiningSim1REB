-- GUI + Mining Script Combined
-- Original logic from second script with GUI from first script

getgenv().Name = getgenv().Name or "BhopGod & Walus Made This!"
getgenv().Depth = getgenv().Depth or 410
getgenv().SellThreshold = getgenv().SellThreshold or 30000
getgenv().Mode = getgenv().Mode or "MINING"
getgenv().Running = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Remote, ScreenGui, HRP, Recovering, RebirthBound = nil, nil, nil, false, false
local Connections = {}
local character = nil

-- Simple split function
local function split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Connection management
local function AddConnection(c)
    if c then Connections[#Connections + 1] = c end
    return c
end

local function ClearConnections()
    for i = #Connections, 1, -1 do
        pcall(function() Connections[i]:Disconnect() end)
        Connections[i] = nil
    end
    if RebirthBound then
        pcall(function() RunService:UnbindFromRenderStep("Rebirth") end)
        RebirthBound = false
    end
end

-- UI Creation helper
local function createUI(name, class, props, parent)
    local obj = Instance.new(class)
    obj.Name = name or ""
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- Destroy existing GUI if present
if game.CoreGui:FindFirstChild("MinerGUI") then
    game.CoreGui:FindFirstChild("MinerGUI"):Destroy()
end

-- Create GUI (positioned bottom right)
local Gui = createUI("MinerGUI", "ScreenGui", {ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, game.CoreGui)
local Main = createUI("Main", "Frame", {Size = UDim2.new(0,220,0,170), Position = UDim2.new(1,-240,1,-190), BackgroundColor3 = Color3.fromRGB(18,18,25), BorderSizePixel = 0, Active = true, Draggable = true}, Gui)
createUI("", "UICorner", {CornerRadius = UDim.new(0,10)}, Main)
createUI("", "UIStroke", {Color = Color3.fromRGB(70,70,150), Thickness = 2}, Main)

local TitleBar = createUI("", "Frame", {Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(25,25,38), BorderSizePixel = 0}, Main)
createUI("", "UICorner", {CornerRadius = UDim.new(0,10)}, TitleBar)
createUI("", "Frame", {Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,1,-8), BackgroundColor3 = Color3.fromRGB(25,25,38), BorderSizePixel = 0}, TitleBar)
createUI("", "TextLabel", {Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = "⛏ HYPER MINER", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, TitleBar)

local CloseBtn = createUI("", "TextButton", {Size = UDim2.new(0,22,0,22), Position = UDim2.new(1,-26,0,4), BackgroundColor3 = Color3.fromRGB(200,50,50), Text = "×", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14, Font = Enum.Font.GothamBold}, TitleBar)
createUI("", "UICorner", {CornerRadius = UDim.new(0,5)}, CloseBtn)

createUI("", "TextLabel", {Size = UDim2.new(1,-16,0,18), Position = UDim2.new(0,8,0,38), BackgroundTransparency = 1, Text = "SELECT MODE:", TextColor3 = Color3.fromRGB(160,160,160), TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, Main)

local MiningBtn = createUI("", "TextButton", {Size = UDim2.new(0.46,0,0,34), Position = UDim2.new(0.02,0,0,60), BackgroundColor3 = Color3.fromRGB(40,120,200), Text = "⛏ MINING", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11, Font = Enum.Font.GothamBold}, Main)
createUI("", "UICorner", {CornerRadius = UDim.new(0,6)}, MiningBtn)
local MiningStroke = createUI("", "UIStroke", {Color = Color3.fromRGB(80,160,255), Thickness = 2}, MiningBtn)

local RebirthBtn = createUI("", "TextButton", {Size = UDim2.new(0.46,0,0,34), Position = UDim2.new(0.52,0,0,60), BackgroundColor3 = Color3.fromRGB(50,50,65), Text = "🔄 REBIRTH", TextColor3 = Color3.fromRGB(180,180,180), TextSize = 11, Font = Enum.Font.GothamBold}, Main)
createUI("", "UICorner", {CornerRadius = UDim.new(0,6)}, RebirthBtn)
local RebirthStroke = createUI("", "UIStroke", {Color = Color3.fromRGB(70,70,90), Thickness = 2}, RebirthBtn)

local StartBtn = createUI("", "TextButton", {Size = UDim2.new(0.96,0,0,42), Position = UDim2.new(0.02,0,0,100), BackgroundColor3 = Color3.fromRGB(40,170,80), Text = "▶ START", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13, Font = Enum.Font.GothamBold}, Main)
createUI("", "UICorner", {CornerRadius = UDim.new(0,6)}, StartBtn)

local StatusInfo = createUI("", "TextLabel", {Size = UDim2.new(1,-16,0,18), Position = UDim2.new(0,8,0,148), BackgroundTransparency = 1, Text = "Mode: Mining Only (No Sell/Rebirth)", TextColor3 = Color3.fromRGB(255,180,80), TextSize = 9, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, Main)

-- Mode selection function
local function SelectMode(mode)
    getgenv().Mode = mode
    local isMining = mode == "MINING"
    MiningBtn.BackgroundColor3 = isMining and Color3.fromRGB(40,120,200) or Color3.fromRGB(50,50,65)
    MiningBtn.TextColor3 = isMining and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,180)
    MiningStroke.Color = isMining and Color3.fromRGB(80,160,255) or Color3.fromRGB(70,70,90)
    RebirthBtn.BackgroundColor3 = isMining and Color3.fromRGB(50,50,65) or Color3.fromRGB(160,80,200)
    RebirthBtn.TextColor3 = isMining and Color3.fromRGB(180,180,180) or Color3.fromRGB(255,255,255)
    RebirthStroke.Color = isMining and Color3.fromRGB(70,70,90) or Color3.fromRGB(200,120,255)
    StatusInfo.Text = isMining and "Mode: Mining Only (No Sell/Rebirth)" or "Mode: Auto Sell & Rebirth"
end

-- Mode button connections
MiningBtn.MouseButton1Click:Connect(function() SelectMode("MINING") end)
RebirthBtn.MouseButton1Click:Connect(function() SelectMode("REBIRTH") end)
CloseBtn.MouseButton1Click:Connect(function()
    getgenv().Running = false
    ClearConnections()
    if Gui then Gui:Destroy() end
end)

-- Helper functions from original script
local function getCoinsAmount()
    local coinsAmount = LocalPlayer.leaderstats.Coins
    local amount = tostring(coinsAmount.Value)
    amount = amount:gsub(',', '')
    return tonumber(amount)
end

local function getInventoryAmount()
    local inventoryAmount = ScreenGui.StatsFrame2.Inventory.Amount
    local amount = inventoryAmount.Text
    amount = amount:gsub('%s+', '')
    amount = amount:gsub(',', '')
    local inventory = amount:split("/")
    return tonumber(inventory[1])
end

local function setPlatformStand(state)
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = state
        if state and HRP then
            HRP.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Move to lava spawn function
local function moveToLavaSpawn()
    if not Remote or not HRP then return end
    HRP.Anchored = true
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = 0
        character.Humanoid.JumpPower = 0
    end
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
    pcall(function() part:Destroy() end)
end

-- Mine until depth function
local function mineUntilDepth()
    if not Remote or not HRP or not ScreenGui then return end
    local depthText = split(ScreenGui.TopInfoFrame.Depth.Text, " ")
    while tonumber(depthText[1]) < getgenv().Depth and getgenv().Running do
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

-- Stop script function
local function stopScript()
    getgenv().Running = false
    Recovering = false
    ClearConnections()
    StatusInfo.Text = getgenv().Mode == "MINING" and "Mode: Mining Only (No Sell/Rebirth)" or "Mode: Auto Sell & Rebirth"
    StartBtn.Text = "▶ START"
    StartBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
end

-- Main function (original logic)
local function main()
    if not getgenv().Running then return end
    
    task.wait(1)

    -- Anti-AFK
    VirtualUser:CaptureController()
    AddConnection(LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end))
    AddConnection(LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end))

    character = LocalPlayer.Character
    HRP = character:FindFirstChild("HumanoidRootPart")
    
    pcall(function()
        character.Head.CustomPlayerTag.PlayerName.Text = getgenv().Name
        character.Head.CustomPlayerTag.MinerRank.Text = getgenv().Name
    end)

    repeat task.wait() until game:IsLoaded()
    ScreenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
    
    while ScreenGui.LoadingFrame.BackgroundTransparency == 0 do
        for _, connection in pairs(getconnections(ScreenGui.LoadingFrame.Quality.LowQuality.MouseButton1Down)) do
            connection:Fire()
        end
        task.wait()
    end

    while true do
        if pcall(function() LocalPlayer.leaderstats:WaitForChild("Blocks Mined") end) and
           pcall(function() ScreenGui.StatsFrame.Coins:FindFirstChild("Amount") end) and
           ScreenGui.StatsFrame.Tokens.Amount.Text ~= "Loading..." then
            break
        end
        task.wait(1)
    end

    pcall(function() ScreenGui.TeleporterFrame:Destroy() end)
    pcall(function() ScreenGui.StatsFrame.Sell:Destroy() end)
    pcall(function() ScreenGui.MainButtons.Surface:Destroy() end)

    -- Get remote
    do
        local data = getsenv(LocalPlayer.PlayerGui.ScreenGui.ClientScript).displayCurrent
        local values = getupvalue(data, 8)
        Remote = values["RemoteEvent"]
        data, values = nil, nil
    end

    -- Workspace collapse handler
    AddConnection(workspace.Collapsed.Changed:Connect(function()
        if workspace.Collapsed.Value and getgenv().Running then
            moveToLavaSpawn()
            mineUntilDepth()
        end
    end))

    -- Load external scripts
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ProdHallow/Miningsimrebirthtracker/main/miningsimrebirthtracker", true))()
    end)
    task.wait(1)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/DeleteAssetMinSim1/main/deleteassetsminingsim'))()
    end)
    task.wait(1)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ProdHallow/rebirthtracker/main/rebirthtracker'))()
    end)
    task.wait(1)

    -- Initial move and mine
    moveToLavaSpawn()
    mineUntilDepth()

    -- Depth recovery handler
    local depthAmount = ScreenGui.TopInfoFrame.Depth
    AddConnection(depthAmount.Changed:Connect(function()
        local depthText = split(depthAmount.Text, " ")
        if tonumber(depthText[1]) >= 1500 and not Recovering then
            Recovering = true
            moveToLavaSpawn()
            task.wait(5)
            Recovering = false
        end
    end))

    -- Rebirth handler (only in REBIRTH mode)
    local rebirthsAmount = LocalPlayer.leaderstats.Rebirths
    RebirthBound = true
    RunService:BindToRenderStep("Rebirth", Enum.RenderPriority.Camera.Value, function()
        if not getgenv().Running then return end
        if getgenv().Mode == "REBIRTH" then
            if getCoinsAmount() >= (10000000 * (rebirthsAmount.Value + 1)) then
                Remote:FireServer("Rebirth", {{}})
                RunService.Heartbeat:Wait()
            end
        end
    end)

    -- Main mining loop
    local sellArea = CFrame.new(41.96064, 14, -1239.64648, 1, 0, 0, 0, 1, 0, 0, 0, 1)

    while getgenv().Running do
        if HRP then
            local minp = HRP.CFrame.Position + Vector3.new(-10, -10, -10)
            local maxp = HRP.CFrame.Position + Vector3.new(10, 10, 10)
            local region = Region3.new(minp, maxp)
            local parts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Blocks}, 100)

            for _, block in pairs(parts) do
                if not getgenv().Running then break end
                
                if block:IsA("BasePart") then
                    Remote:FireServer("MineBlock", {{block.Parent}})
                    repeat
                        RunService.Heartbeat:Wait()
                    until not Recovering
                end
                
                -- Only sell in REBIRTH mode
                if getgenv().Mode == "REBIRTH" then
                    if getInventoryAmount() >= getgenv().SellThreshold then
                        if character and HRP then
                            local savedPosition = HRP.Position
                            while getInventoryAmount() >= getgenv().SellThreshold and getgenv().Running do
                                HRP.CFrame = sellArea
                                Remote:FireServer("SellItems", {{}})
                                RunService.Heartbeat:Wait()
                            end
                            setPlatformStand(true)
                            local startTime = os.time()
                            while (HRP.Position - savedPosition).Magnitude > 1 do
                                HRP.CFrame = CFrame.new(18, savedPosition.Y + 2, 26220)
                                RunService.Heartbeat:Wait()
                                if os.time() - startTime > 5 then
                                    break
                                end
                            end
                            setPlatformStand(false)
                        end
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- Start script function
local function startScript()
    if getgenv().Running then return end
    getgenv().Running = true
    Recovering = false
    StartBtn.Text = "⏹ STOP"
    StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    
    task.spawn(main)
end

-- Start button connection
StartBtn.MouseButton1Click:Connect(function()
    if getgenv().Running then
        stopScript()
    else
        startScript()
    end
end)

-- Initialize mode selection
SelectMode("MINING")

print("HYPER MINER LOADED - GUI READY")
