if game:GetService("CoreGui"):FindFirstChild("DraculaUI") then
    game:GetService("CoreGui"):FindFirstChild("DraculaUI"):Destroy()
end

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera
local GUARDING_DISTANCE = 12 -- Adjust this value for guarding range

-- Modern UI Colors
local COLORS = {
    background = Color3.fromRGB(20, 20, 20),
    backgroundTransparency = 0.1,
    accent = Color3.fromRGB(255, 255, 255), -- title
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    toggle = Color3.fromRGB(30, 30, 30),
    toggleEnabled = Color3.fromRGB(128, 128, 128) -- toggle
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraculaUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Create the main UI frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 190) -- Increased height for new toggle
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -95) -- Adjusted position
mainFrame.BackgroundColor3 = COLORS.background
mainFrame.BackgroundTransparency = COLORS.backgroundTransparency
mainFrame.Parent = screenGui

-- Add rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.Text = "dracula.lol"
titleLabel.TextColor3 = COLORS.accent
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -20, 0, 20)
subtitleLabel.Position = UDim2.new(0, 10, 0, 35)
subtitleLabel.Text = "Hoop Nation 2 [Beta]"
subtitleLabel.TextColor3 = COLORS.textDim
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = mainFrame

-- Create Infinite Stamina toggle
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(1, -20, 0, 30)
toggleContainer.Position = UDim2.new(0, 10, 0, 70)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = mainFrame

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(1, -60, 1, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Infinite Stamina"
toggleLabel.TextColor3 = COLORS.text
toggleLabel.TextSize = 14
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = toggleContainer

local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 40, 0, 20)
toggleFrame.Position = UDim2.new(1, -40, 0.5, -10)
toggleFrame.BackgroundColor3 = COLORS.toggle
toggleFrame.Parent = toggleContainer

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleFrame

local toggleButton = Instance.new("Frame")
toggleButton.Size = UDim2.new(0, 16, 0, 16)
toggleButton.Position = UDim2.new(0, 2, 0.5, -8)
toggleButton.BackgroundColor3 = COLORS.text
toggleButton.Parent = toggleFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = toggleButton

local hitbox = Instance.new("TextButton")
hitbox.Size = UDim2.new(1, 0, 1, 0)
hitbox.BackgroundTransparency = 1
hitbox.Text = ""
hitbox.Parent = toggleFrame

-- Create Player Details toggle
local playerDetailsContainer = Instance.new("Frame")
playerDetailsContainer.Size = UDim2.new(1, -20, 0, 30)
playerDetailsContainer.Position = UDim2.new(0, 10, 0, 110) -- Position below Infinite Stamina
playerDetailsContainer.BackgroundTransparency = 1
playerDetailsContainer.Parent = mainFrame

local playerDetailsLabel = Instance.new("TextLabel")
playerDetailsLabel.Size = UDim2.new(1, -60, 1, 0)
playerDetailsLabel.BackgroundTransparency = 1
playerDetailsLabel.Text = "Player Details"
playerDetailsLabel.TextColor3 = COLORS.text
playerDetailsLabel.TextSize = 14
playerDetailsLabel.Font = Enum.Font.Gotham
playerDetailsLabel.TextXAlignment = Enum.TextXAlignment.Left
playerDetailsLabel.Parent = playerDetailsContainer

local playerDetailsFrame = Instance.new("Frame")
playerDetailsFrame.Size = UDim2.new(0, 40, 0, 20)
playerDetailsFrame.Position = UDim2.new(1, -40, 0.5, -10)
playerDetailsFrame.BackgroundColor3 = COLORS.toggle
playerDetailsFrame.Parent = playerDetailsContainer

local playerDetailsCorner = Instance.new("UICorner")
playerDetailsCorner.CornerRadius = UDim.new(1, 0)
playerDetailsCorner.Parent = playerDetailsFrame

local playerDetailsButton = Instance.new("Frame")
playerDetailsButton.Size = UDim2.new(0, 16, 0, 16)
playerDetailsButton.Position = UDim2.new(0, 2, 0.5, -8)
playerDetailsButton.BackgroundColor3 = COLORS.text
playerDetailsButton.Parent = playerDetailsFrame

local playerDetailsButtonCorner = Instance.new("UICorner")
playerDetailsButtonCorner.CornerRadius = UDim.new(1, 0)
playerDetailsButtonCorner.Parent = playerDetailsButton

local playerDetailsHitbox = Instance.new("TextButton")
playerDetailsHitbox.Size = UDim2.new(1, 0, 1, 0)
playerDetailsHitbox.BackgroundTransparency = 1
playerDetailsHitbox.Text = ""
playerDetailsHitbox.Parent = playerDetailsFrame

-- Variables to track the Infinite Stamina status
local infiniteStaminaEnabled = false
local staminaLockConnection
local transparencyLockConnection

-- ESP UI Container
local espScreenGui = Instance.new("ScreenGui")
espScreenGui.Name = "ESP_GUI"
espScreenGui.ResetOnSpawn = false
espScreenGui.Parent = game.CoreGui

-- Create multiple ESP labels for up to 3 players
local espLabels = {}
for i = 1, 3 do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 50)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextSize = 11
    label.Font = Enum.Font.Code
    label.Text = "Tracking..."
    label.Visible = false
    label.Parent = espScreenGui
    espLabels[i] = label
end

-- Variables for ESP
local playerDetailsEnabled = false
local espConnection

-- Function to update ESP
local function updateESP()
    local char = player.Character
    if not char then 
        for _, label in ipairs(espLabels) do
            label.Visible = false
        end
        return 
    end

    -- Create a table to store the 3 closest players
    local closestPlayers = {}
    
    -- Find closest players
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = char:FindFirstChild("HumanoidRootPart")

            if otherHRP and myHRP then
                local distance = (myHRP.Position - otherHRP.Position).Magnitude
                
                -- Add to closest players table
                table.insert(closestPlayers, {
                    player = otherPlayer,
                    distance = distance
                })
            end
        end
    end
    
    -- Sort players by distance
    table.sort(closestPlayers, function(a, b)
        return a.distance < b.distance
    end)
    
    -- Hide all ESP labels first
    for _, label in ipairs(espLabels) do
        label.Visible = false
    end
    
    -- Update ESP for up to 3 closest players
    for i = 1, math.min(3, #closestPlayers) do
        local playerData = closestPlayers[i]
        local otherPlayer = playerData.player
        local distance = playerData.distance
        
        local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
        local staminaValue = otherPlayer:FindFirstChild("Values") and otherPlayer.Values:FindFirstChild("Stamina")
        local guardingValue = otherPlayer:FindFirstChild("Values") and otherPlayer.Values:FindFirstChild("Guarding")
        
        if otherHRP and staminaValue then
            local headPosition = otherHRP.Position + Vector3.new(0, 2.5, 0)
            local screenPosition, onScreen = camera:WorldToViewportPoint(headPosition)
            
            if onScreen then
                local label = espLabels[i]
                label.Visible = true
                label.Position = UDim2.new(0, screenPosition.X - 100, 0, screenPosition.Y - 25)
                
                -- Determine if guarding is TRUE or FALSE based on distance
                local isGuarding = guardingValue and guardingValue.Value and (distance <= GUARDING_DISTANCE)
                
                label.Text = string.format("Player: %s\nStamina: %.2f\nGuarding: %s", 
                    otherPlayer.Name, 
                    staminaValue.Value, 
                    isGuarding and "true" or "false"
                )
                
                -- Change color based on guarding status
                label.TextColor3 = isGuarding and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

-- Function to toggle Player Details ESP
local function togglePlayerDetails()
    playerDetailsEnabled = not playerDetailsEnabled
    
    -- Animate toggle
    local togglePos = playerDetailsEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    local toggleColor = playerDetailsEnabled and COLORS.toggleEnabled or COLORS.toggle
    
    TweenService:Create(playerDetailsButton, TweenInfo.new(0.2), {Position = togglePos}):Play()
    TweenService:Create(playerDetailsFrame, TweenInfo.new(0.2), {BackgroundColor3 = toggleColor}):Play()
    
    if playerDetailsEnabled then
        -- Connect ESP update function
        espConnection = runService.RenderStepped:Connect(updateESP)
    else
        -- Disconnect ESP update function and hide ESP
        if espConnection then
            espConnection:Disconnect()
        end
        for _, label in ipairs(espLabels) do
            label.Visible = false
        end
    end
end

-- Function to toggle Infinite Stamina and Stamina Bar prevention
local function toggleInfiniteStamina()
    infiniteStaminaEnabled = not infiniteStaminaEnabled
    
    -- Animate toggle
    local togglePos = infiniteStaminaEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    local toggleColor = infiniteStaminaEnabled and COLORS.toggleEnabled or COLORS.toggle
    
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {Position = togglePos}):Play()
    TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = toggleColor}):Play()
    
    if infiniteStaminaEnabled then
        -- Lock stamina to 100 and prevent transparency changes
        local staminaValue = player:FindFirstChild("Values") and player.Values:FindFirstChild("Stamina")
        if staminaValue then
            staminaLockConnection = staminaValue:GetPropertyChangedSignal("Value"):Connect(function()
                print("Game is trying to change stamina! New Value:", staminaValue.Value)
                staminaValue.Value = 100 -- Force it back to full stamina
            end)
            print("Stamina value is now locked!")
        end
        
        -- Prevent transparency change on stamina bar
        local char = player.Character
        if char then
            local staminaGui = char:FindFirstChild("LowerTorso") and char.LowerTorso:FindFirstChild("Stamina")
            if staminaGui then
                local staminaBar = staminaGui:FindFirstChild("StaminaBar")
                if staminaBar then
                    transparencyLockConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        staminaBar.ImageTransparency = 0 -- Forces the bar to be visible
                    end)
                    print("Transparency prevention active!")
                end
            end
        end
    else
        -- Disconnect stamina lock and transparency prevention if toggle is off
        if staminaLockConnection then
            staminaLockConnection:Disconnect()
            print("Stamina lock disabled!")
        end
        if transparencyLockConnection then
            transparencyLockConnection:Disconnect()
            print("Transparency prevention disabled!")
        end
    end
end

-- Connect functions to toggle button clicks
hitbox.MouseButton1Click:Connect(toggleInfiniteStamina)
playerDetailsHitbox.MouseButton1Click:Connect(togglePlayerDetails)

-- Make UI draggable
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Add a listener for the End key to hide/show the menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.End then
        mainFrame.Visible = not mainFrame.Visible
        print("UI visibility toggled:", mainFrame.Visible)
    end
end)

print("[dracula.lol] Hoop Nation 2 Beta")
