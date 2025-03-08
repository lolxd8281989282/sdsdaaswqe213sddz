-- Combined ESP System (3D, Corner, and Regular ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Main ESP Settings
local ESP = {
    Enabled = true,
    BoxType = "2D", -- "2D", "3D", or "corner"
    
    -- Box Settings
    ShowBoxes = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    
    -- Name Settings
    ShowNames = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    
    -- Health Settings
    ShowHealthBars = true,
    
    -- Armor Settings
    ShowArmorBars = true,
    ArmorBarColor = Color3.fromRGB(0, 170, 255),
    ArmoredOnly = false,
    
    -- Distance Settings
    ShowDistance = true,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    
    -- Weapon Settings
    ShowWeapon = true,
    WeaponColor = Color3.fromRGB(255, 255, 255),
    
    -- Tracer Settings
    ShowTracers = true,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1,
    TracerOrigin = "Bottom", -- "Top", "Center", "Bottom", "Mouse"
    
    -- Chams Settings
    ShowChams = true,
    ChamsColor = Color3.fromRGB(255, 255, 255),
    ChamsTransparency = 0.5,
    
    -- Other Settings
    TeamCheck = false,
    Distance = 1000,
    
    -- Storage
    Objects = {},
    Chams = {}
}

-- Function to get armor value from a player (works with different games)
local function GetArmorValue(player)
    -- Default armor value (0-100 scale)
    local armorValue = 0
    local maxArmorValue = 100
    
    -- Try to find armor in different places/formats
    if player.Character then
        -- Method 1: Check for Armor value in character
        local armorObj = player.Character:FindFirstChild("Armor") or player.Character:FindFirstChild("Shield")
        if armorObj and armorObj:IsA("NumberValue") then
            armorValue = armorObj.Value
            maxArmorValue = 100 -- Assume max is 100 if not specified
        end
        
        -- Method 2: Check for armor in humanoid (some games store it there)
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            -- Some games use MaxShield property
            if humanoid:FindFirstChild("MaxShield") and humanoid:FindFirstChild("Shield") then
                armorValue = humanoid.Shield.Value
                maxArmorValue = humanoid.MaxShield.Value
            end
        end
        
        -- Method 3: Check for Da Hood specific implementation
        -- Da Hood often stores armor in a specific format
        local daHoodArmor = player.Character:FindFirstChild("BodyEffects")
        if daHoodArmor and daHoodArmor:FindFirstChild("Armor") then
            armorValue = daHoodArmor.Armor.Value
            maxArmorValue = 100 -- Da Hood typically uses 0-100
        end
        
        -- Method 4: Check player stats
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local armor = leaderstats:FindFirstChild("Armor") or leaderstats:FindFirstChild("Shield")
            if armor and armor:IsA("NumberValue") then
                armorValue = armor.Value
                maxArmorValue = 100
            end
        end
    end
    
    -- Ensure armor value is between 0 and max
    armorValue = math.clamp(armorValue, 0, maxArmorValue)
    
    -- Return armor percentage (0-1)
    return armorValue / maxArmorValue
end

-- Function to get equipped weapon (works with different games)
local function GetEquippedWeapon(player)
    if not player or not player.Character then return "None" end
    
    -- Store the equipped item name
    local equippedItem = "None"
    
    -- Method 1: Check for tools in character (most common)
    for _, child in pairs(player.Character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Handle") then
            equippedItem = child.Name
            break
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 2: Check for Da Hood specific implementation
    local bodyEffects = player.Character:FindFirstChild("BodyEffects")
    if bodyEffects then
        -- Check for equipped tool in Da Hood
        local toolFolder = bodyEffects:FindFirstChild("ToolStorage")
        if toolFolder then
            for _, tool in pairs(toolFolder:GetChildren()) do
                if tool:IsA("Tool") then
                    equippedItem = tool.Name
                    break
                end
            end
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 3: Check for currently equipped tool in Backpack
    if player:FindFirstChild("Backpack") then
        -- Some games use a different method to determine equipped items
        -- They move the tool out of the Backpack when equipped
        local backpack = player:FindFirstChild("Backpack")
        local allTools = {}
        
        -- Collect all tools in backpack
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(allTools, tool.Name)
            end
        end
        
        -- Check character for tools not in backpack
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("Tool") then
                local isInBackpack = false
                for _, toolName in pairs(allTools) do
                    if child.Name == toolName then
                        isInBackpack = true
                        break
                    end
                end
                
                if not isInBackpack then
                    equippedItem = child.Name
                    break
                end
            end
        end
    end
    
    return equippedItem
end

-- Function to create chams for a player
local function CreateChams(player)
    if player == LocalPlayer then return end
    
    -- Remove existing chams if any
    if ESP.Chams[player] then
        ESP.Chams[player]:Destroy()
        ESP.Chams[player] = nil
    end
    
    -- Create new chams if character exists
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = ESP.ChamsColor
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.FillTransparency = ESP.ChamsTransparency
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
        
        ESP.Chams[player] = highlight
    end
end

-- Function to create ESP elements for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Create a table to store all drawing objects for this player
    local drawings = {}
    
    -- 2D Box ESP
    drawings.box = Drawing.new("Square")
    drawings.box.Visible = false
    drawings.box.Filled = false
    drawings.box.Thickness = ESP.BoxThickness
    drawings.box.Color = ESP.BoxColor
    drawings.box.Transparency = 1
    
    -- Box outline
    drawings.boxOutline = Drawing.new("Square")
    drawings.boxOutline.Visible = false
    drawings.boxOutline.Filled = false
    drawings.boxOutline.Thickness = ESP.BoxThickness + 2
    drawings.boxOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.boxOutline.Transparency = 1
    
    -- Name text
    drawings.name = Drawing.new("Text")
    drawings.name.Visible = false
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.Size = ESP.TextSize
    drawings.name.Color = ESP.NameColor
    drawings.name.Font = 3
    
    -- Weapon text
    drawings.weapon = Drawing.new("Text")
    drawings.weapon.Visible = false
    drawings.weapon.Center = true
    drawings.weapon.Outline = true
    drawings.weapon.Size = ESP.TextSize
    drawings.weapon.Color = ESP.WeaponColor
    drawings.weapon.Font = 3
    
    -- Distance text
    drawings.distance = Drawing.new("Text")
    drawings.distance.Visible = false
    drawings.distance.Center = true
    drawings.distance.Outline = true
    drawings.distance.Size = ESP.TextSize
    drawings.distance.Color = ESP.DistanceColor
    drawings.distance.Font = 3
    
    -- Health bar
    drawings.healthBar = Drawing.new("Line")
    drawings.healthBar.Visible = false
    drawings.healthBar.Thickness = 2
    drawings.healthBar.Color = Color3.fromRGB(0, 255, 0)
    
    -- Health bar background
    drawings.healthBarBG = Drawing.new("Line")
    drawings.healthBarBG.Visible = false
    drawings.healthBarBG.Thickness = 4
    drawings.healthBarBG.Color = Color3.fromRGB(0, 0, 0)
    
    -- Armor bar
    drawings.armorBar = Drawing.new("Line")
    drawings.armorBar.Visible = false
    drawings.armorBar.Thickness = 2
    drawings.armorBar.Color = ESP.ArmorBarColor
    
    -- Armor bar background
    drawings.armorBarBG = Drawing.new("Line")
    drawings.armorBarBG.Visible = false
    drawings.armorBarBG.Thickness = 4
    drawings.armorBarBG.Color = Color3.fromRGB(0, 0, 0)
    
    -- Tracer
    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Visible = false
    drawings.tracer.Thickness = ESP.TracerThickness
    drawings.tracer.Color = ESP.TracerColor
    
    -- 3D Box ESP (12 lines)
    drawings.lines3D = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = ESP.BoxThickness
        line.Color = ESP.BoxColor
        line.Transparency = 1
        drawings.lines3D[i] = line
    end
    
    -- Corner ESP (8 lines)
    drawings.corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = ESP.BoxThickness
        line.Color = ESP.BoxColor
        line.Transparency = 1
        drawings.corners[i] = line
    end
    
    -- Store the ESP objects for this player
    ESP.Objects[player] = drawings
    
    -- Create chams for this player
    CreateChams(player)
    
    -- Clean up ESP when player leaves
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if ESP.Objects[player] then
                for _, drawing in pairs(ESP.Objects[player]) do
                    if typeof(drawing) == "table" then
                        for _, line in pairs(drawing) do
                            line:Remove()
                        end
                    else
                        drawing:Remove()
                    end
                end
                ESP.Objects[player] = nil
            end
            
            if ESP.Chams[player] then
                ESP.Chams[player]:Destroy()
                ESP.Chams[player] = nil
            end
        end
    end)
    
    -- Update chams when character changes
    player.CharacterAdded:Connect(function(character)
        if ESP.Chams[player] then
            ESP.Chams[player]:Destroy()
            ESP.Chams[player] = nil
        end
        
        task.wait(0.5) -- Wait for character to fully load
        CreateChams(player)
    end)
end

-- Function to update ESP for a player
local function UpdateESP(player, drawings)
    -- Skip if player is not valid
    if not player or not player.Parent then
        for _, drawing in pairs(drawings) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Skip if character doesn't exist or is missing parts
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Head") then
        for _, drawing in pairs(drawings) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local head = player.Character:FindFirstChild("Head")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    -- Calculate distance between local player and target
    local distance = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    end
    
    -- Check if player is within distance
    if distance > ESP.Distance then
        for _, drawing in pairs(drawings) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Check team if team check is enabled
    if ESP.TeamCheck and LocalPlayer.Team == player.Team then
        for _, drawing in pairs(drawings) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Get screen positions
    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    
    -- Check if player is on screen
    if not rootVisible then
        for _, drawing in pairs(drawings) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line.Visible = false
                end
            else
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Calculate box dimensions
    local boxHeight = math.abs(headPos.Y - legPos.Y)
    local boxWidth = boxHeight * 0.6
    
    local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
    
    -- Update ESP based on box type
    if ESP.BoxType == "2D" and ESP.ShowBoxes then
        -- 2D Box
        drawings.box.Size = Vector2.new(boxWidth, boxHeight)
        drawings.box.Position = boxPos
        drawings.box.Color = ESP.BoxColor
        drawings.box.Thickness = ESP.BoxThickness
        drawings.box.Visible = true
        
        drawings.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
        drawings.boxOutline.Position = boxPos
        drawings.boxOutline.Visible = true
        
        -- Hide 3D and corner boxes
        for _, line in pairs(drawings.lines3D) do
            line.Visible = false
        end
        
        for _, line in pairs(drawings.corners) do
            line.Visible = false
        end
    elseif ESP.BoxType == "3D" and ESP.ShowBoxes then
        -- 3D Box
        drawings.box.Visible = false
        drawings.boxOutline.Visible = false
        
        -- Hide corner boxes
        for _, line in pairs(drawings.corners) do
            line.Visible = false
        end
        
        -- Calculate 3D box corners
        local size = Vector3.new(3, 5, 3)
        local cf = rootPart.CFrame
        
        local corners = {
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)
        }
        
        -- Convert to screen points
        local points = {}
        for i, corner in ipairs(corners) do
            local point = Camera:WorldToViewportPoint(corner.Position)
            points[i] = Vector2.new(point.X, point.Y)
        end
        
        -- Draw 3D box lines
        local lineConnections = {
            {1,2}, {2,3}, {3,4}, {4,1}, -- Top square
            {5,6}, {6,7}, {7,8}, {8,5}, -- Bottom square
            {1,5}, {2,6}, {3,7}, {4,8}  -- Connecting lines
        }
        
        for i, connection in ipairs(lineConnections) do
            local line = drawings.lines3D[i]
            line.From = points[connection[1]]
            line.To = points[connection[2]]
            line.Color = ESP.BoxColor
            line.Thickness = ESP.BoxThickness
            line.Visible = true
        end
    elseif ESP.BoxType == "corner" and ESP.ShowBoxes then
        -- Corner Box
        drawings.box.Visible = false
        drawings.boxOutline.Visible = false
        
        -- Hide 3D boxes
        for _, line in pairs(drawings.lines3D) do
            line.Visible = false
        end
        
        local cornerSize = boxHeight * 0.2
        
        -- Top Left
        drawings.corners[1].From = boxPos
        drawings.corners[1].To = Vector2.new(boxPos.X + cornerSize, boxPos.Y)
        drawings.corners[1].Color = ESP.BoxColor
        drawings.corners[1].Thickness = ESP.BoxThickness
        drawings.corners[1].Visible = true
        
        drawings.corners[2].From = boxPos
        drawings.corners[2].To = Vector2.new(boxPos.X, boxPos.Y + cornerSize)
        drawings.corners[2].Color = ESP.BoxColor
        drawings.corners[2].Thickness = ESP.BoxThickness
        drawings.corners[2].Visible = true
        
        -- Top Right
        drawings.corners[3].From = Vector2.new(boxPos.X + boxWidth, boxPos.Y)
        drawings.corners[3].To = Vector2.new(boxPos.X + boxWidth - cornerSize, boxPos.Y)
        drawings.corners[3].Color = ESP.BoxColor
        drawings.corners[3].Thickness = ESP.BoxThickness
        drawings.corners[3].Visible = true
        
        drawings.corners[4].From = Vector2.new(boxPos.X + boxWidth, boxPos.Y)
        drawings.corners[4].To = Vector2.new(boxPos.X + boxWidth, boxPos.Y + cornerSize)
        drawings.corners[4].Color = ESP.BoxColor
        drawings.corners[4].Thickness = ESP.BoxThickness
        drawings.corners[4].Visible = true
        
        -- Bottom Left
        drawings.corners[5].From = Vector2.new(boxPos.X, boxPos.Y + boxHeight)
        drawings.corners[5].To = Vector2.new(boxPos.X + cornerSize, boxPos.Y + boxHeight)
        drawings.corners[5].Color = ESP.BoxColor
        drawings.corners[5].Thickness = ESP.BoxThickness
        drawings.corners[5].Visible = true
        
        drawings.corners[6].From = Vector2.new(boxPos.X, boxPos.Y + boxHeight)
        drawings.corners[6].To = Vector2.new(boxPos.X, boxPos.Y + boxHeight - cornerSize)
        drawings.corners[6].Color = ESP.BoxColor
        drawings.corners[6].Thickness = ESP.BoxThickness
        drawings.corners[6].Visible = true
        
        -- Bottom Right
        drawings.corners[7].From = Vector2.new(boxPos.X + boxWidth, boxPos.Y + boxHeight)
        drawings.corners[7].To = Vector2.new(boxPos.X + boxWidth - cornerSize, boxPos.Y + boxHeight)
        drawings.corners[7].Color = ESP.BoxColor
        drawings.corners[7].Thickness = ESP.BoxThickness
        drawings.corners[7].Visible = true
        
        drawings.corners[8].From = Vector2.new(boxPos.X + boxWidth, boxPos.Y + boxHeight)
        drawings.corners[8].To = Vector2.new(boxPos.X + boxWidth, boxPos.Y + boxHeight - cornerSize)
        drawings.corners[8].Color = ESP.BoxColor
        drawings.corners[8].Thickness = ESP.BoxThickness
        drawings.corners[8].Visible = true
    else
        -- Hide all boxes
        drawings.box.Visible = false
        drawings.boxOutline.Visible = false
        
        for _, line in pairs(drawings.lines3D) do
            line.Visible = false
        end
        
        for _, line in pairs(drawings.corners) do
            line.Visible = false
        end
    end
    
    -- Name ESP
    if ESP.ShowNames then
        drawings.name.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y - 15)
        drawings.name.Text = player.Name
        drawings.name.Color = ESP.NameColor
        drawings.name.Size = ESP.TextSize
        drawings.name.Visible = true
    else
        drawings.name.Visible = false
    end
    
    -- Weapon ESP
    if ESP.ShowWeapon then
        drawings.weapon.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y + boxHeight + 5)
        drawings.weapon.Text = GetEquippedWeapon(player)
        drawings.weapon.Color = ESP.WeaponColor
        drawings.weapon.Size = ESP.TextSize
        drawings.weapon.Visible = true
    else
        drawings.weapon.Visible = false
    end
    
    -- Distance ESP
    if ESP.ShowDistance then
        drawings.distance.Position = Vector2.new(boxPos.X + boxWidth / 2, boxPos.Y + boxHeight + (ESP.ShowWeapon and 20 or 5))
        drawings.distance.Text = math.floor(distance) .. "m"
        drawings.distance.Color = ESP.DistanceColor
        drawings.distance.Size = ESP.TextSize
        drawings.distance.Visible = true
    else
        drawings.distance.Visible = false
    end
    
    -- Health Bar
    if ESP.ShowHealthBars and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        
        drawings.healthBarBG.From = Vector2.new(boxPos.X - 5, boxPos.Y)
        drawings.healthBarBG.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight)
        drawings.healthBarBG.Visible = true
        
        drawings.healthBar.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight - (boxHeight * healthPercent))
        drawings.healthBar.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight)
        drawings.healthBar.Color = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
        drawings.healthBar.Visible = true
    else
        drawings.healthBar.Visible = false
        drawings.healthBarBG.Visible = false
    end
    
    -- Armor Bar
    local armor = GetArmorValue(player)
    if ESP.ShowArmorBars and (not ESP.ArmoredOnly or armor > 0) then
        drawings.armorBarBG.From = Vector2.new(boxPos.X - 10, boxPos.Y)
        drawings.armorBarBG.To = Vector2.new(boxPos.X - 10, boxPos.Y + boxHeight)
        drawings.armorBarBG.Visible = true
        
        drawings.armorBar.From = Vector2.new(boxPos.X - 10, boxPos.Y + boxHeight - (boxHeight * armor))
        drawings.armorBar.To = Vector2.new(boxPos.X - 10, boxPos.Y + boxHeight)
        drawings.armorBar.Color = ESP.ArmorBarColor
        drawings.armorBar.Visible = armor > 0
    else
        drawings.armorBar.Visible = false
        drawings.armorBarBG.Visible = false
    end
    
    -- Tracer
    if ESP.ShowTracers then
        local tracerOrigin
        
        if ESP.TracerOrigin == "Top" then
            tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
        elseif ESP.TracerOrigin == "Center" then
            tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        elseif ESP.TracerOrigin == "Bottom" then
            tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif ESP.TracerOrigin == "Mouse" then
            local mousePos = UserInputService:GetMouseLocation()
            tracerOrigin = Vector2.new(mousePos.X, mousePos.Y)
        end
        
        drawings.tracer.From = tracerOrigin
        drawings.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        drawings.tracer.Color = ESP.TracerColor
        drawings.tracer.Thickness = ESP.TracerThickness
        drawings.tracer.Visible = true
    else
        drawings.tracer.Visible = false
    end
    
    -- Update chams
    if ESP.Chams[player] then
        ESP.Chams[player].Enabled = ESP.ShowChams
        ESP.Chams[player].FillColor = ESP.ChamsColor
        ESP.Chams[player].FillTransparency = ESP.ChamsTransparency
    end
end

-- Function to update all ESP
local function UpdateAllESP()
    for player, drawings in pairs(ESP.Objects) do
        UpdateESP(player, drawings)
    end
end

-- Create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

-- Remove ESP when players leave
Players.PlayerRemoving:Connect(function(player)
    if ESP.Objects[player] then
        for _, drawing in pairs(ESP.Objects[player]) do
            if typeof(drawing) == "table" then
                for _, line in pairs(drawing) do
                    line:Remove()
                end
            else
                drawing:Remove()
            end
        end
        ESP.Objects[player] = nil
    end
    
    if ESP.Chams[player] then
        ESP.Chams[player]:Destroy()
        ESP.Chams[player] = nil
    end
end)

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        UpdateAllESP()
    else
        -- Hide all ESP objects if disabled
        for _, playerESP in pairs(ESP.Objects) do
            for _, drawing in pairs(playerESP) do
                if typeof(drawing) == "table" then
                    for _, line in pairs(drawing) do
                        line.Visible = false
                    end
                else
                    drawing.Visible = false
                end
            end
        end
        
        -- Hide all chams if disabled
        for _, highlight in pairs(ESP.Chams) do
            highlight.Enabled = false
        end
    end
end)

-- Connect to UI flags
local function ConnectToUI()
    -- Box settings
    if flags then
        ESP.Enabled = true
        ESP.BoxType = flags.name_type or "2D"
        ESP.ShowBoxes = flags.esp_box or false
        ESP.BoxColor = flags.esp_box_color and flags.esp_box_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Name settings
        ESP.ShowNames = flags.esp_name or false
        ESP.NameColor = flags.esp_name_color and flags.esp_name_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Weapon settings
        ESP.ShowWeapon = flags.esp_weapon or false
        ESP.WeaponColor = flags.esp_weapon_color and flags.esp_weapon_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Distance settings
        ESP.ShowDistance = flags.esp_distance or false
        ESP.DistanceColor = flags.esp_distance_color and flags.esp_distance_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Health settings
        ESP.ShowHealthBars = flags.esp_healthbar or false
        
        -- Armor settings
        ESP.ShowArmorBars = flags.esp_armor or false
        ESP.ArmorBarColor = flags.esp_armor_color and flags.esp_armor_color.Color or Color3.fromRGB(0, 170, 255)
        ESP.ArmoredOnly = flags.esp_armored_only or false
        
        -- Chams settings
        ESP.ShowChams = flags.esp_chams or false
        ESP.ChamsColor = flags.esp_chams_color and flags.esp_chams_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Tracer settings
        ESP.ShowTracers = flags.esp_tracer_lines or false
        ESP.TracerColor = flags.esp_tracer_lines_color and flags.esp_tracer_lines_color.Color or Color3.fromRGB(255, 255, 255)
        
        -- Disable tracers if flag is set
        if flags.disable_tracers then
            ESP.ShowTracers = false
        end
    end
end

-- Initial connection to UI
ConnectToUI()

-- Update settings when flags change
if flags then
    -- Create a metatable to detect changes in flags
    local mt = getmetatable(flags) or {}
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    
    mt.__index = function(t, k)
        return oldIndex and oldIndex(t, k) or rawget(t, k)
    end
    
    mt.__newindex = function(t, k, v)
        rawset(t, k, v)
        
        -- Update ESP settings when flags change
        ConnectToUI()
        
        if oldNewIndex then
            oldNewIndex(t, k, v)
        end
    end
    
    setmetatable(flags, mt)
end

-- Return the ESP object for external use
return ESP
