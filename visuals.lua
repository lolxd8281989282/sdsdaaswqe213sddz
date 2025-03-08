-- Combined ESP System (3D ESP, Corner ESP, and 2D ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Storage for ESP objects
local ESPObjects = {
    Box2D = {},
    Name = {},
    Distance = {},
    Weapon = {},
    Health = {},
    Armor = {},
    Tracer = {},
    Corner = {},
    Box3D = {},
    Chams = {}
}

-- Utility functions
local function GetPlayerWeapon(player)
    -- Replace with your actual weapon detection logic
    if player and player.Character then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            return tool.Name
        end
    end
    return "None"
end

local function GetPlayerHealth(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid.Health, humanoid.MaxHealth
        end
    end
    return 0, 100
end

local function GetPlayerArmor(player)
    -- Replace with your actual armor detection logic
    if player and player.Character then
        -- Example: Check for armor value in some attribute or value
        local armor = player.Character:FindFirstChild("Armor")
        if armor and armor:IsA("NumberValue") then
            return armor.Value
        end
    end
    return 0
end

local function IsPlayerArmored(player)
    return GetPlayerArmor(player) > 0
end

local function GetDistanceFromPlayer(player)
    if LocalPlayer.Character and player.Character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local localRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and localRootPart then
            return (rootPart.Position - localRootPart.Position).Magnitude
        end
    end
    return 0
end

local function GetTeam(player)
    return player.Team
end

local function IsTeammate(player)
    -- Simple team check - can be customized based on your game
    return GetTeam(player) == GetTeam(LocalPlayer)
end

local function GetBoxCorners(player)
    local character = player.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return nil end
    
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then return nil end
    
    local rootPos = Camera:WorldToViewportPoint(hrp.Position)
    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    
    local boxSize = Vector2.new(math.abs(legPos.Y - headPos.Y) * 0.6, math.abs(legPos.Y - headPos.Y))
    local boxPosition = Vector2.new(headPos.X - boxSize.X / 2, headPos.Y)
    
    return {
        TopLeft = boxPosition,
        TopRight = boxPosition + Vector2.new(boxSize.X, 0),
        BottomLeft = boxPosition + Vector2.new(0, boxSize.Y),
        BottomRight = boxPosition + Vector2.new(boxSize.X, boxSize.Y),
        Size = boxSize
    }
end

-- Function to create ESP objects for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- 2D Box ESP
    local box2d = {
        box = Drawing.new("Square"),
        outline = Drawing.new("Square")
    }
    box2d.box.Thickness = 1
    box2d.box.Filled = false
    box2d.box.Visible = false
    box2d.outline.Thickness = 3
    box2d.outline.Filled = false
    box2d.outline.Visible = false
    ESPObjects.Box2D[player] = box2d
    
    -- Name ESP
    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false
    name.Font = 2
    ESPObjects.Name[player] = name
    
    -- Distance ESP
    local distance = Drawing.new("Text")
    distance.Size = 13
    distance.Center = true
    distance.Outline = true
    distance.Visible = false
    distance.Font = 2
    ESPObjects.Distance[player] = distance
    
    -- Weapon ESP
    local weapon = Drawing.new("Text")
    weapon.Size = 13
    weapon.Center = true
    weapon.Outline = true
    weapon.Visible = false
    weapon.Font = 2
    ESPObjects.Weapon[player] = weapon
    
    -- Health Bar ESP
    local health = {
        bar = Drawing.new("Square"),
        outline = Drawing.new("Square"),
        text = Drawing.new("Text")
    }
    health.bar.Thickness = 1
    health.bar.Filled = true
    health.bar.Visible = false
    health.outline.Thickness = 1
    health.outline.Filled = false
    health.outline.Visible = false
    health.text.Size = 13
    health.text.Center = false
    health.text.Outline = true
    health.text.Visible = false
    health.text.Font = 2
    ESPObjects.Health[player] = health
    
    -- Armor Bar ESP
    local armor = {
        bar = Drawing.new("Square"),
        outline = Drawing.new("Square"),
        text = Drawing.new("Text")
    }
    armor.bar.Thickness = 1
    armor.bar.Filled = true
    armor.bar.Visible = false
    armor.outline.Thickness = 1
    armor.outline.Filled = false
    armor.outline.Visible = false
    armor.text.Size = 13
    armor.text.Center = false
    armor.text.Outline = true
    armor.text.Visible = false
    armor.text.Font = 2
    ESPObjects.Armor[player] = armor
    
    -- Tracer ESP
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    ESPObjects.Tracer[player] = tracer
    
    -- Corner ESP
    local corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        corners[i] = line
    end
    ESPObjects.Corner[player] = corners
    
    -- 3D Box ESP
    local box3d = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        box3d[i] = line
    end
    ESPObjects.Box3D[player] = box3d
    
    -- Chams (if your original ESP had it)
    local chams = {
        highlight = Instance.new("Highlight")
    }
    chams.highlight.Enabled = false
    chams.highlight.FillTransparency = 0.5
    chams.highlight.OutlineTransparency = 0
    ESPObjects.Chams[player] = chams
    
    -- Cleanup on character removal
    player.CharacterRemoving:Connect(function()
        if ESPObjects.Box2D[player] then
            ESPObjects.Box2D[player].box.Visible = false
            ESPObjects.Box2D[player].outline.Visible = false
        end
        
        if ESPObjects.Name[player] then
            ESPObjects.Name[player].Visible = false
        end
        
        if ESPObjects.Distance[player] then
            ESPObjects.Distance[player].Visible = false
        end
        
        if ESPObjects.Weapon[player] then
            ESPObjects.Weapon[player].Visible = false
        end
        
        if ESPObjects.Health[player] then
            ESPObjects.Health[player].bar.Visible = false
            ESPObjects.Health[player].outline.Visible = false
            ESPObjects.Health[player].text.Visible = false
        end
        
        if ESPObjects.Armor[player] then
            ESPObjects.Armor[player].bar.Visible = false
            ESPObjects.Armor[player].outline.Visible = false
            ESPObjects.Armor[player].text.Visible = false
        end
        
        if ESPObjects.Tracer[player] then
            ESPObjects.Tracer[player].Visible = false
        end
        
        if ESPObjects.Corner[player] then
            for _, line in pairs(ESPObjects.Corner[player]) do
                line.Visible = false
            end
        end
        
        if ESPObjects.Box3D[player] then
            for _, line in pairs(ESPObjects.Box3D[player]) do
                line.Visible = false
            end
        end
        
        if ESPObjects.Chams[player] and ESPObjects.Chams[player].highlight then
            ESPObjects.Chams[player].highlight.Enabled = false
        end
    end)
    
    -- Set up chams when character is added
    player.CharacterAdded:Connect(function(character)
        if ESPObjects.Chams[player] and ESPObjects.Chams[player].highlight then
            ESPObjects.Chams[player].highlight.Parent = character
        end
    end)
    
    -- Set up chams for existing character
    if player.Character and ESPObjects.Chams[player] and ESPObjects.Chams[player].highlight then
        ESPObjects.Chams[player].highlight.Parent = player.Character
    end
end

-- Update ESP
RunService.RenderStepped:Connect(function()
    -- Update 2D Box ESP
    for player, objects in pairs(ESPObjects.Box2D) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            objects.box.Visible = false
            objects.outline.Visible = false
            continue
        end
        
        -- Only show if box is enabled and box type is "2D"
        if flags.box and flags.box_type == "2D" then
            local corners = GetBoxCorners(player)
            if corners then
                objects.box.Size = corners.Size
                objects.box.Position = corners.TopLeft
                objects.box.Color = flags.box_color or Color3.new(1, 1, 1)
                objects.box.Visible = true
                
                objects.outline.Size = corners.Size
                objects.outline.Position = corners.TopLeft
                objects.outline.Color = Color3.new(0, 0, 0)
                objects.outline.Visible = true
            else
                objects.box.Visible = false
                objects.outline.Visible = false
            end
        else
            objects.box.Visible = false
            objects.outline.Visible = false
        end
    end
    
    -- Update Name ESP
    for player, name in pairs(ESPObjects.Name) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            name.Visible = false
            continue
        end
        
        if flags.name then
            local corners = GetBoxCorners(player)
            if corners then
                name.Position = Vector2.new(corners.TopLeft.X + corners.Size.X / 2, corners.TopLeft.Y - 15)
                name.Text = player.Name
                name.Color = flags.name_color or Color3.new(1, 1, 1)
                name.Visible = true
            else
                name.Visible = false
            end
        else
            name.Visible = false
        end
    end
    
    -- Update Distance ESP
    for player, distance in pairs(ESPObjects.Distance) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            distance.Visible = false
            continue
        end
        
        if flags.distance then
            local corners = GetBoxCorners(player)
            if corners then
                local dist = math.floor(GetDistanceFromPlayer(player))
                distance.Position = Vector2.new(corners.BottomRight.X + 5, corners.BottomRight.Y)
                distance.Text = tostring(dist) .. "m"
                distance.Color = flags.distance_color or Color3.new(1, 1, 1)
                distance.Visible = true
            else
                distance.Visible = false
            end
        else
            distance.Visible = false
        end
    end
    
    -- Update Weapon ESP
    for player, weapon in pairs(ESPObjects.Weapon) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            weapon.Visible = false
            continue
        end
        
        if flags.weapon then
            local corners = GetBoxCorners(player)
            if corners then
                weapon.Position = Vector2.new(corners.BottomLeft.X + corners.Size.X / 2, corners.BottomLeft.Y + 15)
                weapon.Text = GetPlayerWeapon(player)
                weapon.Color = flags.weapon_color or Color3.new(1, 1, 1)
                weapon.Visible = true
            else
                weapon.Visible = false
            end
        else
            weapon.Visible = false
        end
    end
    
    -- Update Health Bar ESP
    for player, health in pairs(ESPObjects.Health) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            health.bar.Visible = false
            health.outline.Visible = false
            health.text.Visible = false
            continue
        end
        
        if flags.healthbar then
            local corners = GetBoxCorners(player)
            if corners then
                local currentHealth, maxHealth = GetPlayerHealth(player)
                local healthPercentage = currentHealth / maxHealth
                
                local barWidth = 3
                local barHeight = corners.Size.Y
                
                health.outline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                health.outline.Position = Vector2.new(corners.TopLeft.X - barWidth - 4, corners.TopLeft.Y - 1)
                health.outline.Color = Color3.new(0, 0, 0)
                health.outline.Visible = true
                
                health.bar.Size = Vector2.new(barWidth, barHeight * healthPercentage)
                health.bar.Position = Vector2.new(corners.TopLeft.X - barWidth - 3, corners.TopLeft.Y + barHeight * (1 - healthPercentage))
                
                -- Health color gradient (red to green)
                health.bar.Color = Color3.new(1 - healthPercentage, healthPercentage, 0)
                health.bar.Visible = true
                
                -- Only show health text if enabled
                if flags.healthtext then
                    health.text.Text = tostring(math.floor(currentHealth))
                    health.text.Position = Vector2.new(corners.TopLeft.X - barWidth - 16, corners.TopLeft.Y + barHeight * (1 - healthPercentage))
                    health.text.Color = Color3.new(1, 1, 1)
                    health.text.Visible = true
                else
                    health.text.Visible = false
                end
            else
                health.bar.Visible = false
                health.outline.Visible = false
                health.text.Visible = false
            end
        else
            health.bar.Visible = false
            health.outline.Visible = false
            health.text.Visible = false
        end
    end
    
    -- Update Armor Bar ESP
    for player, armor in pairs(ESPObjects.Armor) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            armor.bar.Visible = false
            armor.outline.Visible = false
            armor.text.Visible = false
            continue
        end
        
        if flags.armor and (not flags.armored_only or IsPlayerArmored(player)) then
            local corners = GetBoxCorners(player)
            if corners then
                local armorValue = GetPlayerArmor(player)
                local armorPercentage = armorValue / 100 -- Assuming max armor is 100
                
                local barWidth = 3
                local barHeight = corners.Size.Y
                
                armor.outline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                armor.outline.Position = Vector2.new(corners.TopRight.X + 2, corners.TopRight.Y - 1)
                armor.outline.Color = Color3.new(0, 0, 0)
                armor.outline.Visible = true
                
                armor.bar.Size = Vector2.new(barWidth, barHeight * armorPercentage)
                armor.bar.Position = Vector2.new(corners.TopRight.X + 3, corners.TopRight.Y + barHeight * (1 - armorPercentage))
                armor.bar.Color = Color3.new(0, 0.5, 1) -- Blue for armor
                armor.bar.Visible = true
                
                -- Only show armor text if enabled
                if flags.armortext then
                    armor.text.Text = tostring(math.floor(armorValue))
                    armor.text.Position = Vector2.new(corners.TopRight.X + barWidth + 5, corners.TopRight.Y + barHeight * (1 - armorPercentage))
                    armor.text.Color = Color3.new(1, 1, 1)
                    armor.text.Visible = true
                else
                    armor.text.Visible = false
                end
            else
                armor.bar.Visible = false
                armor.outline.Visible = false
                armor.text.Visible = false
            end
        else
            armor.bar.Visible = false
            armor.outline.Visible = false
            armor.text.Visible = false
        end
    end
    
    -- Update Tracer ESP
    for player, tracer in pairs(ESPObjects.Tracer) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            tracer.Visible = false
            continue
        end
        
        if flags.tracer then
            local rootPart = player.Character.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local tracerStart
                -- Use the selected tracer origin from your UI
                if flags.tracer_origin == "bottom" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                elseif flags.tracer_origin == "top" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
                elseif flags.tracer_origin == "center" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                else
                    -- Default to bottom if not specified
                    tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                end
                
                tracer.From = tracerStart
                tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                tracer.Color = flags.tracer_color or Color3.new(1, 1, 1)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
    
    -- Update Corner ESP
    for player, corners in pairs(ESPObjects.Corner) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            for _, line in pairs(corners) do
                line.Visible = false
            end
            continue
        end
        
        -- Only show if box is enabled and box type is "corner"
        if flags.box and flags.box_type == "corner" then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                local cornerSize = boxCorners.Size.Y * 0.2
                
                -- Update corner lines
                for i, line in ipairs(corners) do
                    line.Color = flags.box_color or Color3.new(1, 1, 1)
                    line.Visible = true
                    
                    -- Set corner positions based on index
                    if i == 1 then -- Top Left Horizontal
                        line.From = boxCorners.TopLeft
                        line.To = boxCorners.TopLeft + Vector2.new(cornerSize, 0)
                    elseif i == 2 then -- Top Left Vertical
                        line.From = boxCorners.TopLeft
                        line.To = boxCorners.TopLeft + Vector2.new(0, cornerSize)
                    elseif i == 3 then -- Top Right Horizontal
                        line.From = boxCorners.TopRight
                        line.To = boxCorners.TopRight + Vector2.new(-cornerSize, 0)
                    elseif i == 4 then -- Top Right Vertical
                        line.From = boxCorners.TopRight
                        line.To = boxCorners.TopRight + Vector2.new(0, cornerSize)
                    elseif i == 5 then -- Bottom Left Horizontal
                        line.From = boxCorners.BottomLeft
                        line.To = boxCorners.BottomLeft + Vector2.new(cornerSize, 0)
                    elseif i == 6 then -- Bottom Left Vertical
                        line.From = boxCorners.BottomLeft
                        line.To = boxCorners.BottomLeft + Vector2.new(0, -cornerSize)
                    elseif i == 7 then -- Bottom Right Horizontal
                        line.From = boxCorners.BottomRight
                        line.To = boxCorners.BottomRight + Vector2.new(-cornerSize, 0)
                    elseif i == 8 then -- Bottom Right Vertical
                        line.From = boxCorners.BottomRight
                        line.To = boxCorners.BottomRight + Vector2.new(0, -cornerSize)
                    end
                end
            else
                for _, line in pairs(corners) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(corners) do
                line.Visible = false
            end
        end
    end
    
    -- Update 3D Box ESP
    for player, lines in pairs(ESPObjects.Box3D) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            for _, line in pairs(lines) do
                line.Visible = false
            end
            continue
        end
        
        -- Only show if box is enabled and box type is "3D"
        if flags.box and flags.box_type == "3D" then
            local rootPart = player.Character.HumanoidRootPart
            local size = Vector3.new(4, 5, 4)
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
            
            local points = {}
            local onScreen = true
            
            for i, corner in ipairs(corners) do
                local point, visible = Camera:WorldToViewportPoint(corner.Position)
                if not visible then
                    onScreen = false
                    break
                end
                points[i] = Vector2.new(point.X, point.Y)
            end
            
            if onScreen then
                local connections = {
                    {1,2}, {2,3}, {3,4}, {4,1},  -- Top square
                    {5,6}, {6,7}, {7,8}, {8,5},  -- Bottom square
                    {1,5}, {2,6}, {3,7}, {4,8}   -- Connecting lines
                }
                
                for i, connection in ipairs(connections) do
                    local line = lines[i]
                    line.From = points[connection[1]]
                    line.To = points[connection[2]]
                    line.Color = flags.box_color or Color3.new(1, 1, 1)
                    line.Visible = true
                end
            else
                for _, line in pairs(lines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
    end
    
    -- Update Chams
    for player, chams in pairs(ESPObjects.Chams) do
        if not player.Character or IsTeammate(player) then
            chams.highlight.Enabled = false
            continue
        end
        
        if flags.chams then
            chams.highlight.Enabled = true
            chams.highlight.FillColor = flags.chams_color or Color3.new(1, 0, 0)
            chams.highlight.OutlineColor = flags.chams_outline_color or Color3.new(1, 1, 1)
            chams.highlight.FillTransparency = flags.chams_transparency or 0.5
            chams.highlight.OutlineTransparency = flags.chams_outline_transparency or 0
        else
            chams.highlight.Enabled = false
        end
    end
end)

-- Create ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(CreateESP)

-- Remove ESP when players leave
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects.Box2D[player] then
        ESPObjects.Box2D[player].box:Remove()
        ESPObjects.Box2D[player].outline:Remove()
        ESPObjects.Box2D[player] = nil
    end
    
    if ESPObjects.Name[player] then
        ESPObjects.Name[player]:Remove()
        ESPObjects.Name[player] = nil
    end
    
    if ESPObjects.Distance[player] then
        ESPObjects.Distance[player]:Remove()
        ESPObjects.Distance[player] = nil
    end
    
    if ESPObjects.Weapon[player] then
        ESPObjects.Weapon[player]:Remove()
        ESPObjects.Weapon[player] = nil
    end
    
    if ESPObjects.Health[player] then
        ESPObjects.Health[player].bar:Remove()
        ESPObjects.Health[player].outline:Remove()
        ESPObjects.Health[player].text:Remove()
        ESPObjects.Health[player] = nil
    end
    
    if ESPObjects.Armor[player] then
        ESPObjects.Armor[player].bar:Remove()
        ESPObjects.Armor[player].outline:Remove()
        ESPObjects.Armor[player].text:Remove()
        ESPObjects.Armor[player] = nil
    end
    
    if ESPObjects.Tracer[player] then
        ESPObjects.Tracer[player]:Remove()
        ESPObjects.Tracer[player] = nil
    end
    
    if ESPObjects.Corner[player] then
        for _, line in pairs(ESPObjects.Corner[player]) do
            line:Remove()
        end
        ESPObjects.Corner[player] = nil
    end
    
    if ESPObjects.Box3D[player] then
        for _, line in pairs(ESPObjects.Box3D[player]) do
            line:Remove()
        end
        ESPObjects.Box3D[player] = nil
    end
    
    if ESPObjects.Chams[player] and ESPObjects.Chams[player].highlight then
        ESPObjects.Chams[player].highlight:Destroy()
        ESPObjects.Chams[player] = nil
    end
end)
