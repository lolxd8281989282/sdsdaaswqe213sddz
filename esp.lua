-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Object
local ESP = {
    -- Initialize storage tables first
    Objects = {},
    ChamsInstances = {},
    Boxes3D = {},
    Corners = {},
    Initialized = false,
    
    -- Then initialize all settings
    Enabled = false,
    DistanceValue = 1000,
    TeamCheck = false,
    SelfESP = false,
    
    -- UI Properties
    Boxes = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    Names = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    Distance = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    Weapons = false,
    WeaponColor = Color3.fromRGB(255, 255, 255),
    Tracers = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    HealthBars = false,
    ArmorBars = false,
    ArmorColor = Color3.fromRGB(0, 150, 255),
    ArmoredOnly = false,
    ShowChams = false,
    ChamsColor = Color3.fromRGB(255, 255, 255),
    BoxType = "2D",
    DisableTracers = false,
    TracerType = "random",
    
    -- Drawing settings
    BoxThickness = 1,
    TextSize = 12,
    
    -- Chams settings
    ChamsVisible = Color3.fromRGB(0, 255, 0),
    ChamsOccluded = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5,
    ChamsOutlineTransparency = 0.3,
    ChamsOutlineColor = Color3.fromRGB(0, 0, 0),
    ChamsTeamColor = false,
    
    -- 3D Box settings
    Show3DBoxes = false,
    Box3DColor = Color3.fromRGB(255, 255, 255),
    Box3DThickness = 1,
    Box3DOutlineColor = Color3.fromRGB(0, 0, 0),
    Box3DOutlineThickness = 3,
    
    -- Corner ESP settings
    ShowCornerBoxes = false,
    CornerColor = Color3.fromRGB(255, 255, 255),
    CornerThickness = 1,
    CornerOutlineColor = Color3.fromRGB(0, 0, 0),
    CornerOutlineThickness = 3,
    CornerSize = 5,
    
    -- Tracer settings
    TracerThickness = 1,
    TracerOrigin = "Top",
    TracerTransparency = 0
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
        
        -- Method 5: Check for Phantom Forces style armor
        local pfStats = player:FindFirstChild("PlayerStats")
        if pfStats then
            local pfArmor = pfStats:FindFirstChild("Armor")
            if pfArmor and pfArmor:IsA("NumberValue") then
                armorValue = pfArmor.Value
                maxArmorValue = 100
            end
        end
        
        -- Method 6: Check for Arsenal style armor
        local arsenalStats = player:FindFirstChild("NRPBS")
        if arsenalStats then
            local arsenalArmor = arsenalStats:FindFirstChild("Armor")
            if arsenalArmor and arsenalArmor:IsA("NumberValue") then
                armorValue = arsenalArmor.Value
                maxArmorValue = 100
            end
        end
        
        -- Method 7: Check for Strucid style armor
        local strucidStats = player:FindFirstChild("Data")
        if strucidStats then
            local strucidArmor = strucidStats:FindFirstChild("Shield")
            if strucidArmor and strucidArmor:IsA("NumberValue") then
                armorValue = strucidArmor.Value
                maxArmorValue = 100
            end
        end
    end
    
    -- Ensure armor value is between 0 and max
    armorValue = math.clamp(armorValue, 0, maxArmorValue)
    
    -- Return armor percentage (0-1)
    return armorValue / maxArmorValue
end

-- Enhanced function to get equipped item name from a player (supports more games)
local function GetEquippedItem(player)
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
        
        -- Check for gun in Da Hood
        if player:FindFirstChild("Backpack") then
            local gunFolder = player.Backpack:FindFirstChild("Guns")
            if gunFolder then
                for _, gun in pairs(gunFolder:GetChildren()) do
                    if gun:IsA("Tool") and gun.Parent.Name ~= "Backpack" then
                        equippedItem = gun.Name
                        break
                    end
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
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 4: Check for RightHand attachment (some games use this)
    local rightHand = player.Character:FindFirstChild("RightHand")
    if rightHand then
        for _, child in pairs(rightHand:GetChildren()) do
            if child:IsA("Attachment") and child:FindFirstChild("ToolName") then
                equippedItem = child.ToolName.Value
                break
            end
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 5: Check for Phantom Forces style equipped weapon
    local pfStats = player:FindFirstChild("PlayerStats")
    if pfStats then
        local pfEquipped = pfStats:FindFirstChild("EquippedWeapon")
        if pfEquipped and pfEquipped:IsA("StringValue") then
            equippedItem = pfEquipped.Value
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 6: Check for Arsenal style equipped weapon
    local arsenalStats = player:FindFirstChild("NRPBS")
    if arsenalStats then
        local arsenalEquipped = arsenalStats:FindFirstChild("EquippedWeapon")
        if arsenalEquipped and arsenalEquipped:IsA("StringValue") then
            equippedItem = arsenalEquipped.Value
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 7: Check for Strucid style equipped weapon
    local strucidStats = player:FindFirstChild("Data")
    if strucidStats then
        local strucidEquipped = strucidStats:FindFirstChild("EquippedWeapon")
        if strucidEquipped and strucidEquipped:IsA("StringValue") then
            equippedItem = strucidEquipped.Value
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 8: Check for Jailbreak style equipped weapon
    local jailbreakStats = player:FindFirstChild("JailbreakData")
    if jailbreakStats then
        local jailbreakEquipped = jailbreakStats:FindFirstChild("EquippedItem")
        if jailbreakEquipped and jailbreakEquipped:IsA("StringValue") then
            equippedItem = jailbreakEquipped.Value
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 9: Check for animations that might indicate equipped weapons
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local animName = track.Animation.Name:lower()
                if animName:find("gun") or animName:find("rifle") or animName:find("pistol") or 
                   animName:find("sword") or animName:find("knife") or animName:find("melee") then
                    equippedItem = animName:gsub("_", " "):gsub("anim", ""):gsub("animation", "")
                    equippedItem = equippedItem:sub(1, 1):upper() .. equippedItem:sub(2)
                    break
                end
            end
        end
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 10: Check for custom attributes (some newer games use this)
    if player.Character:GetAttribute("EquippedItem") then
        equippedItem = player.Character:GetAttribute("EquippedItem")
    end
    
    -- If we found an item, return it
    if equippedItem ~= "None" then
        return equippedItem
    end
    
    -- Method 11: Check for tool grip (some games use this to determine if a tool is equipped)
    for _, child in pairs(player.Character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Grip") then
            equippedItem = child.Name
            break
        end
    end
    
    return equippedItem
end

-- Function to create chams for a player
local function CreateChams(player)
    if player == LocalPlayer and not ESP.SelfESP then return end
    
    -- Remove existing chams if any
    if ESP.ChamsInstances[player] then
        ESP.ChamsInstances[player]:Destroy()
        ESP.ChamsInstances[player] = nil
    end
    
    -- Create new chams if character exists
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = ESP.ChamsVisible
        highlight.OutlineColor = ESP.ChamsOutlineColor
        highlight.FillTransparency = ESP.ChamsTransparency
        highlight.OutlineTransparency = ESP.ChamsOutlineTransparency
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
        
        -- Apply team color if enabled
        if ESP.ChamsTeamColor and player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        end
        
        ESP.ChamsInstances[player] = highlight
    end
end

-- Function to update chams for a player
local function UpdateChams(player)
    if not ESP.ShowChams or not ESP.Enabled then
        if ESP.ChamsInstances[player] then
            ESP.ChamsInstances[player].Enabled = false
        end
        return
    end
    
    -- Check if player is valid
    if not player or not player.Parent then
        if ESP.ChamsInstances[player] then
            ESP.ChamsInstances[player]:Destroy()
            ESP.ChamsInstances[player] = nil
        end
        return
    end
    
    -- Check if character exists
    if not player.Character then
        if ESP.ChamsInstances[player] then
            ESP.ChamsInstances[player]:Destroy()
            ESP.ChamsInstances[player] = nil
        end
        return
    end
    
    -- Create chams if they don't exist
    if not ESP.ChamsInstances[player] then
        CreateChams(player)
    end
    
    -- Update chams if they exist
    if ESP.ChamsInstances[player] then
        local highlight = ESP.ChamsInstances[player]
        
        -- Calculate distance
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
        end
        
        -- Check if player should be shown
        local shouldShow = true
        if ESP.TeamCheck and LocalPlayer.Team == player.Team then
            shouldShow = false
        end
        if not ESP.SelfESP and player == LocalPlayer then
            shouldShow = false
        end
        if distance > ESP.DistanceValue then
            shouldShow = false
        end
        
        -- Update highlight properties
        highlight.Enabled = shouldShow
        highlight.FillColor = ESP.ChamsVisible
        highlight.OutlineColor = ESP.ChamsOutlineColor
        highlight.FillTransparency = ESP.ChamsTransparency
        highlight.OutlineTransparency = ESP.ChamsOutlineTransparency
        
        -- Apply team color if enabled
        if ESP.ChamsTeamColor and player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        end
    end
end

-- Function to create 3D box for a player
local function Create3DBox(player)
    if player == LocalPlayer and not ESP.SelfESP then return end
    
    -- Create 12 outline lines for the 3D box
    local outlines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = ESP.Box3DOutlineThickness
        line.Color = ESP.Box3DOutlineColor
        line.Transparency = 1
        table.insert(outlines, line)
    end
    
    -- Create 12 lines for the 3D box
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = ESP.Box3DThickness
        line.Color = ESP.Box3DColor
        line.Transparency = 1
        table.insert(lines, line)
    end
    
    -- Store the box
    ESP.Boxes3D[player] = {
        Lines = lines,
        Outlines = outlines,
        Player = player
    }
    
    -- Clean up when player leaves
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if ESP.Boxes3D[player] then
                for _, line in pairs(ESP.Boxes3D[player].Lines) do
                    line:Remove()
                end
                for _, line in pairs(ESP.Boxes3D[player].Outlines) do
                    line:Remove()
                end
                ESP.Boxes3D[player] = nil
            end
        end
    end)
end

-- Function to create corner ESP for a player
local function CreateCornerESP(player)
    if player == LocalPlayer and not ESP.SelfESP then return end
    
    -- Create 8 lines for corners (2 lines per corner × 4 corners)
    local cornerLines = {}
    local cornerOutlines = {}
    
    -- Create lines for each corner
    for i = 1, 8 do
        -- Create outline
        local outline = Drawing.new("Line")
        outline.Visible = false
        outline.Thickness = ESP.CornerOutlineThickness
        outline.Color = ESP.CornerOutlineColor
        outline.Transparency = 1
        table.insert(cornerOutlines, outline)
        
        -- Create line
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = ESP.CornerThickness
        line.Color = ESP.CornerColor
        line.Transparency = 1
        table.insert(cornerLines, line)
    end
    
    -- Store the corner ESP
    ESP.Corners[player] = {
        Lines = cornerLines,
        Outlines = cornerOutlines,
        Player = player
    }
    
    -- Clean up when player leaves
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if ESP.Corners[player] then
                for _, line in pairs(ESP.Corners[player].Lines) do
                    line:Remove()
                end
                for _, line in pairs(ESP.Corners[player].Outlines) do
                    line:Remove()
                end
                ESP.Corners[player] = nil
            end
        end
    end)
end

-- Function to update 3D box for a player
local function Update3DBox(player)
    local boxData = ESP.Boxes3D[player]
    if not boxData then return end
    
    local lines = boxData.Lines
    local outlines = boxData.Outlines
    
    -- Check if player is valid
    if not player or not player.Parent then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Check if character exists
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Get character parts
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    -- Check team
    if ESP.TeamCheck and player.Team == LocalPlayer.Team then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Check if 3D boxes are enabled
    if not ESP.Show3DBoxes or not ESP.Enabled then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Calculate distance
    local distance = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    end
    
    -- Check if player is within distance
    if distance > ESP.DistanceValue then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Calculate box size based on character size
    local size = Vector3.new(4, 5, 4) -- Default size
    
    -- Calculate box vertices in world space
    local position = rootPart.Position
    local vertices = {
        Vector3.new(position.X + size.X/2, position.Y + size.Y/2, position.Z + size.Z/2), -- Top Front Right
        Vector3.new(position.X - size.X/2, position.Y + size.Y/2, position.Z + size.Z/2), -- Top Front Left
        Vector3.new(position.X - size.X/2, position.Y + size.Y/2, position.Z - size.Z/2), -- Top Back Left
        Vector3.new(position.X + size.X/2, position.Y + size.Y/2, position.Z - size.Z/2), -- Top Back Right
        Vector3.new(position.X + size.X/2, position.Y - size.Y/2, position.Z + size.Z/2), -- Bottom Front Right
        Vector3.new(position.X - size.X/2, position.Y - size.Y/2, position.Z + size.Z/2), -- Bottom Front Left
        Vector3.new(position.X - size.X/2, position.Y - size.Y/2, position.Z - size.Z/2), -- Bottom Back Left
        Vector3.new(position.X + size.X/2, position.Y - size.Y/2, position.Z - size.Z/2)  -- Bottom Back Right
    }
    
    -- Convert vertices to screen space
    local screenVertices = {}
    local allVisible = true
    
    for i, vertex in ipairs(vertices) do
        local screenPosition, onScreen = Camera:WorldToViewportPoint(vertex)
        screenVertices[i] = Vector2.new(screenPosition.X, screenPosition.Y)
        if not onScreen then
            allVisible = false
        end
    end
    
    -- If any vertex is not on screen, hide the box
    if not allVisible then
        for i = 1, 12 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Update lines for the 3D box
    -- Top square
    local lineConnections = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Top square
        {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Bottom square
        {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Connecting lines
    }
    
    for i, connection in ipairs(lineConnections) do
        -- Update outline
        outlines[i].From = screenVertices[connection[1]]
        outlines[i].To = screenVertices[connection[2]]
        outlines[i].Visible = true
        
        -- Update line
        lines[i].From = screenVertices[connection[1]]
        lines[i].To = screenVertices[connection[2]]
        lines[i].Visible = true
    end
end

-- Function to update corner ESP for a player
local function UpdateCornerESP(player)
    local cornerData = ESP.Corners[player]
    if not cornerData then return end
    
    local lines = cornerData.Lines
    local outlines = cornerData.Outlines
    
    -- Check if player is valid
    if not player or not player.Parent then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Check if character exists
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Head") then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Get character parts
    local head = player.Character:FindFirstChild("Head")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    -- Check team
    if ESP.TeamCheck and player.Team == LocalPlayer.Team then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Check if corner boxes are enabled
    if not ESP.ShowCornerBoxes or not ESP.Enabled then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Calculate distance
    local distance = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    end
    
    -- Check if player is within distance
    if distance > ESP.DistanceValue then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Get screen positions
    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    
    -- Check if player is visible
    if not headVisible then
        for i = 1, 8 do
            lines[i].Visible = false
            outlines[i].Visible = false
        end
        return
    end
    
    -- Calculate box dimensions
    local boxHeight = math.abs(headPos.Y - legPos.Y)
    local boxWidth = boxHeight * 0.6 -- Adjust width based on height
    
    -- Calculate box corners
    local topLeft = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
    local topRight = Vector2.new(rootPos.X + boxWidth / 2, headPos.Y)
    local bottomLeft = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y + boxHeight)
    local bottomRight = Vector2.new(rootPos.X + boxWidth / 2, headPos.Y + boxHeight)
    
    -- Set corner color
    local cornerColor = ESP.CornerColor
    if ESP.TeamCheck and player.Team then
        cornerColor = player.Team.TeamColor.Color
    end
    
    -- Update corner lines
    -- Top Left Corner
    lines[1].From = topLeft
    lines[1].To = topLeft + Vector2.new(ESP.CornerSize, 0)
    lines[1].Color = cornerColor
    lines[1].Visible = true
    
    lines[2].From = topLeft
    lines[2].To = topLeft + Vector2.new(0, ESP.CornerSize)
    lines[2].Color = cornerColor
    lines[2].Visible = true
    
    -- Top Right Corner
    lines[3].From = topRight
    lines[3].To = topRight + Vector2.new(-ESP.CornerSize, 0)
    lines[3].Color = cornerColor
    lines[3].Visible = true
    
    lines[4].From = topRight
    lines[4].To = topRight + Vector2.new(0, ESP.CornerSize)
    lines[4].Color = cornerColor
    lines[4].Visible = true
    
    -- Bottom Left Corner
    lines[5].From = bottomLeft
    lines[5].To = bottomLeft + Vector2.new(ESP.CornerSize, 0)
    lines[5].Color = cornerColor
    lines[5].Visible = true
    
    lines[6].From = bottomLeft
    lines[6].To = bottomLeft + Vector2.new(0, -ESP.CornerSize)
    lines[6].Color = cornerColor
    lines[6].Visible = true
    
    -- Bottom Right Corner
    lines[7].From = bottomRight
    lines[7].To = bottomRight + Vector2.new(-ESP.CornerSize, 0)
    lines[7].Color = cornerColor
    lines[7].Visible = true
    
    lines[8].From = bottomRight
    lines[8].To = bottomRight + Vector2.new(0, -ESP.CornerSize)
    lines[8].Color = cornerColor
    lines[8].Visible = true
    
    --  -ESP.CornerSize)
    lines[8].Color = cornerColor
    lines[8].Visible = true
    
    -- Update outlines
    for i = 1, 8 do
        outlines[i].From = lines[i].From
        outlines[i].To = lines[i].To
        outlines[i].Color = ESP.CornerOutlineColor
        outlines[i].Visible = true
    end
end

-- Function to create ESP elements for a player
local function CreateESP(player)
    if player == LocalPlayer and not ESP.SelfESP then return end
    
    -- Create a table to store all drawing objects for this player
    local drawings = {}
    
    -- Name text
    drawings.name = Drawing.new("Text")
    drawings.name.Visible = false
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.Size = ESP.TextSize
    drawings.name.Color = ESP.NameColor
    drawings.name.Font = 3
    
    -- Box outline (black)
    drawings.boxOutline = Drawing.new("Square")
    drawings.boxOutline.Visible = false
    drawings.boxOutline.Filled = false
    drawings.boxOutline.Thickness = ESP.BoxThickness + 2
    drawings.boxOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.boxOutline.Transparency = 1
    
    -- Box (white)
    drawings.box = Drawing.new("Square")
    drawings.box.Visible = false
    drawings.box.Filled = false
    drawings.box.Thickness = ESP.BoxThickness
    drawings.box.Color = ESP.BoxColor
    drawings.box.Transparency = 1
    
    -- Armor bar background
    drawings.armorBarBG = Drawing.new("Line")
    drawings.armorBarBG.Visible = false
    drawings.armorBarBG.Color = Color3.fromRGB(0, 0, 0)
    drawings.armorBarBG.Thickness = 3
    
    -- Armor bar
    drawings.armorBar = Drawing.new("Line")
    drawings.armorBar.Visible = false
    drawings.armorBar.Color = ESP.ArmorColor
    drawings.armorBar.Thickness = 1
    
    -- Health bar background
    drawings.healthBarBG = Drawing.new("Line")
    drawings.healthBarBG.Visible = false
    drawings.healthBarBG.Color = Color3.fromRGB(0, 0, 0)
    drawings.healthBarBG.Thickness = 3
    
    -- Health bar
    drawings.healthBar = Drawing.new("Line")
    drawings.healthBar.Visible = false
    drawings.healthBar.Color = Color3.fromRGB(0, 255, 0)
    drawings.healthBar.Thickness = 1
    
    -- Armor value text
    drawings.armorValue = Drawing.new("Text")
    drawings.armorValue.Visible = false
    drawings.armorValue.Center = true
    drawings.armorValue.Outline = true
    drawings.armorValue.Size = ESP.TextSize
    drawings.armorValue.Color = Color3.fromRGB(255, 255, 255) -- White color
    drawings.armorValue.Font = 3

    -- Health value text
    drawings.healthValue = Drawing.new("Text")
    drawings.healthValue.Visible = false
    drawings.healthValue.Center = true
    drawings.healthValue.Outline = true
    drawings.healthValue.Size = ESP.TextSize
    drawings.healthValue.Color = Color3.fromRGB(255, 255, 255) -- White color
    drawings.healthValue.Font = 3
    
    -- Distance text
    drawings.distance = Drawing.new("Text")
    drawings.distance.Visible = false
    drawings.distance.Center = true
    drawings.distance.Outline = true
    drawings.distance.Size = ESP.TextSize
    drawings.distance.Color = ESP.DistanceColor
    drawings.distance.Font = 3
    
    -- Equipped item text
    drawings.equippedItem = Drawing.new("Text")
    drawings.equippedItem.Visible = false
    drawings.equippedItem.Center = true
    drawings.equippedItem.Outline = true
    drawings.equippedItem.Size = ESP.TextSize
    drawings.equippedItem.Color = ESP.WeaponColor
    drawings.equippedItem.Font = 3
    
    -- Tracer line
    drawings.tracer = Drawing.new("Line")
    drawings.tracer.Visible = false
    drawings.tracer.Color = ESP.TracerColor
    drawings.tracer.Thickness = ESP.TracerThickness
    drawings.tracer.Transparency = 1 - ESP.TracerTransparency
    
    -- Store the ESP objects for this player
    ESP.Objects[player] = drawings
    
    -- Create chams for this player
    CreateChams(player)
    
    -- Create 3D box for this player
    Create3DBox(player)
    
    -- Create corner ESP for this player
    CreateCornerESP(player)
    
    -- Clean up ESP when player leaves or character is removed
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if ESP.Objects[player] then
                for _, drawing in pairs(ESP.Objects[player]) do
                    drawing:Remove()
                end
                ESP.Objects[player] = nil
            end
            
            if ESP.ChamsInstances[player] then
                ESP.ChamsInstances[player]:Destroy()
                ESP.ChamsInstances[player] = nil
            end
            
            if ESP.Boxes3D[player] then
                for _, line in pairs(ESP.Boxes3D[player].Lines) do
                    line:Remove()
                end
                for _, line in pairs(ESP.Boxes3D[player].Outlines) do
                    line:Remove()
                end
                ESP.Boxes3D[player] = nil
            end
            
            if ESP.Corners[player] then
                for _, line in pairs(ESP.Corners[player].Lines) do
                    line:Remove()
                end
                for _, line in pairs(ESP.Corners[player].Outlines) do
                    line:Remove()
                end
                ESP.Corners[player] = nil
            end
        end
    end)
    
    -- Update chams when character changes
    player.CharacterAdded:Connect(function(character)
        if ESP.ChamsInstances[player] then
            ESP.ChamsInstances[player]:Destroy()
            ESP.ChamsInstances[player] = nil
        end
        
        task.wait(0.5) -- Wait for character to fully load
        CreateChams(player)
        Create3DBox(player)
        CreateCornerESP(player)
    end)
end

-- Function to update ESP for all players
local function UpdateESP()
    for player, drawings in pairs(ESP.Objects) do
        -- Skip if player is not valid
        if not player or not player.Parent then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Skip if character doesn't exist or is missing parts
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Head") then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        -- Calculate distance between local player and target
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
        end
        
        -- Get screen positions
        -- First, let's adjust how we calculate the head position
        local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
        local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        -- Check if player is on screen and within distance
        if rootVisible and distance <= ESP.DistanceValue then
            -- Calculate box dimensions
            local boxHeight = math.abs(headPos.Y - bottomPos.Y)
            local boxWidth = boxHeight / 2
            
            -- Check team if team check is enabled
            local shouldShow = true
            if ESP.TeamCheck and LocalPlayer.Team == player.Team then
                shouldShow = false
            end
            if not ESP.SelfESP and player == LocalPlayer then
                shouldShow = false
            end
            
            -- Draw box
            if shouldShow and ESP.Boxes then
                local boxPosition = Vector2.new(
                    rootPos.X - boxWidth / 2,
                    headPos.Y
                )
                
                -- Update box outline
                drawings.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
                drawings.boxOutline.Position = boxPosition
                drawings.boxOutline.Visible = true
                
                -- Update box
                drawings.box.Size = Vector2.new(boxWidth, boxHeight)
                drawings.box.Position = boxPosition
                drawings.box.Visible = true
            else
                drawings.boxOutline.Visible = false
                drawings.box.Visible = false
            end
            
            -- Position calculations for bars and text
            local boxX = rootPos.X - boxWidth/2
            local boxY = headPos.Y

            -- Draw name (above box)
            if shouldShow and ESP.Names then
                drawings.name.Position = Vector2.new(rootPos.X, boxY - 20) -- Moved up slightly
                drawings.name.Text = player.Name
                drawings.name.Color = ESP.NameColor
                drawings.name.Size = ESP.TextSize
                drawings.name.Visible = true
            else
                drawings.name.Visible = false
            end
            
            -- Position calculations for bars
            local healthBarX = boxX - 4 -- Moved closer to box
            local armorBarX = healthBarX - 4 -- Moved closer to health bar
            
            -- Draw armor bar (to the left of health bar)
            if shouldShow and ESP.ArmorBars then
                local armorPercent = GetArmorValue(player)
                local barHeight = boxHeight * armorPercent
                
                -- Always show the background
                drawings.armorBarBG.From = Vector2.new(armorBarX, boxY)
                drawings.armorBarBG.To = Vector2.new(armorBarX, boxY + boxHeight)
                drawings.armorBarBG.Visible = true
                
                -- Show armor value text
                drawings.armorValue.Position = Vector2.new(armorBarX - 15, boxY - 5)
                drawings.armorValue.Text = tostring(math.floor(armorPercent * 100))
                drawings.armorValue.Visible = true
                
                -- Only show the colored bar if there's armor
                if armorPercent > 0 then
                    drawings.armorBar.From = Vector2.new(armorBarX, boxY + boxHeight - barHeight)
                    drawings.armorBar.To = Vector2.new(armorBarX, boxY + boxHeight)
                    drawings.armorBar.Color = ESP.ArmorColor
                    drawings.armorBar.Visible = true
                else
                    drawings.armorBar.Visible = false
                end
            else
                drawings.armorBar.Visible = false
                drawings.armorBarBG.Visible = false
                drawings.armorValue.Visible = false
            end
            
            -- Draw health bar
            if shouldShow and ESP.HealthBars and humanoid then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barHeight = boxHeight * healthPercent
                
                drawings.healthBarBG.From = Vector2.new(healthBarX, boxY)
                drawings.healthBarBG.To = Vector2.new(healthBarX, boxY + boxHeight)
                drawings.healthBarBG.Visible = true
                
                -- Show health value text
                drawings.healthValue.Position = Vector2.new(healthBarX - 15, boxY - 5)
                drawings.healthValue.Text = tostring(math.floor(healthPercent * 100))
                drawings.healthValue.Visible = true
                
                drawings.healthBar.From = Vector2.new(healthBarX, boxY + boxHeight - barHeight)
                drawings.healthBar.To = Vector2.new(healthBarX, boxY + boxHeight)
                drawings.healthBar.Color = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
                drawings.healthBar.Visible = true
            else
                drawings.healthBar.Visible = false
                drawings.healthBarBG.Visible = false
                drawings.healthValue.Visible = false
            end
            
            -- Draw distance
            if shouldShow and ESP.Distance then
                drawings.distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 5)
                drawings.distance.Text = math.floor(distance) .. "m"
                drawings.distance.Color = ESP.DistanceColor
                drawings.distance.Size = ESP.TextSize
                drawings.distance.Visible = true
            else
                drawings.distance.Visible = false
            end
            
            -- Draw equipped item
            if shouldShow and ESP.Weapons then
                local itemName = GetEquippedItem(player)
                -- Position under distance text with minimal spacing
                drawings.equippedItem.Position = Vector2.new(rootPos.X, boxY + boxHeight + 20)
                
                -- Always show the equipped item text, with [None] if nothing is equipped
                if itemName == "None" then
                    drawings.equippedItem.Text = "[None]"
                else
                    drawings.equippedItem.Text = itemName
                end
                
                drawings.equippedItem.Color = ESP.WeaponColor
                drawings.equippedItem.Size = ESP.TextSize
                drawings.equippedItem.Visible = true
            else
                drawings.equippedItem.Visible = false
            end
            
            -- Draw tracer
            if shouldShow and ESP.Tracers then
                local tracerOrigin
                
                -- Set tracer origin based on setting
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
                drawings.tracer.Transparency = 1 - ESP.TracerTransparency
                drawings.tracer.Visible = true
            else
                drawings.tracer.Visible = false
            end
        else
            -- Hide all drawings if player is not visible
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
        
        -- Update chams
        UpdateChams(player)
        
        -- Update 3D box
        Update3DBox(player)
        
        -- Update corner ESP
        UpdateCornerESP(player)
    end
end

-- Function to initialize ESP
function ESP:Init()
    -- Check if already initialized
    if self.Initialized then
        return self
    end
    
    -- Initialize properties for UI compatibility
    self.Enabled = false
    self.Boxes = false
    self.Names = false
    self.Distance = false
    self.Weapons = false
    self.HealthBars = false
    self.ArmorBars = false
    self.ArmoredOnly = false
    self.ShowChams = false
    self.Tracers = false
    self.BoxType = "2D"
    
    -- Create ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer or self.SelfESP then
            CreateESP(player)
        end
    end
    
    -- Create ESP for new players
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    -- Remove ESP when players leave
    Players.PlayerRemoving:Connect(function(player)
        if self.Objects[player] then
            for _, drawing in pairs(self.Objects[player]) do
                drawing:Remove()
            end
            self.Objects[player] = nil
        end
        
        if self.ChamsInstances[player] then
            self.ChamsInstances[player]:Destroy()
            self.ChamsInstances[player] = nil
        end
        
        if self.Boxes3D[player] then
            for _, line in pairs(self.Boxes3D[player].Lines) do
                line:Remove()
            end
            for _, line in pairs(self.Boxes3D[player].Outlines) do
                line:Remove()
            end
            self.Boxes3D[player] = nil
        end
        
        if self.Corners[player] then
            for _, line in pairs(self.Corners[player].Lines) do
                line:Remove()
            end
            for _, line in pairs(self.Corners[player].Outlines) do
                line:Remove()
            end
            self.Corners[player] = nil
        end
    end)
    
    -- Update ESP every frame
    RunService.RenderStepped:Connect(function()
        if self.Enabled then
            UpdateESP()
        else
            -- Hide all ESP objects if disabled
            for _, playerESP in pairs(self.Objects) do
                for _, drawing in pairs(playerESP) do
                    drawing.Visible = false
                end
            end
            
            -- Hide all chams if disabled
            for player, highlight in pairs(self.ChamsInstances) do
                highlight.Enabled = false
            end
            
            -- Hide all 3D boxes if disabled
            for player, boxData in pairs(self.Boxes3D) do
                for _, line in pairs(boxData.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(boxData.Outlines) do
                    line.Visible = false
                end
            end
            
            -- Hide all corner ESP if disabled
            for player, cornerData in pairs(self.Corners) do
                for _, line in pairs(cornerData.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(cornerData.Outlines) do
                    line.Visible = false
                end
            end
        end
    end)
    
    -- Mark as initialized
    self.Initialized = true
    
    return self
end

-- Function to update ESP settings
function ESP:UpdateSettings(settings)
    for key, value in pairs(settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    -- Update drawing properties based on new settings
    for _, playerESP in pairs(self.Objects) do
        if playerESP.name then
            playerESP.name.Size = self.TextSize
            playerESP.name.Color = self.NameColor
        end
        
        if playerESP.distance then
            playerESP.distance.Size = self.TextSize
            playerESP.distance.Color = self.DistanceColor
        end
        
        if playerESP.equippedItem then
            playerESP.equippedItem.Size = self.TextSize
            playerESP.equippedItem.Color = self.WeaponColor
        end
        
        if playerESP.box then
            playerESP.box.Color = self.BoxColor
            playerESP.box.Thickness = self.BoxThickness
        end
        
        if playerESP.boxOutline then
            playerESP.boxOutline.Thickness = self.BoxThickness + 2
        end
        
        if playerESP.armorBar then
            playerESP.armorBar.Color = self.ArmorColor
        end
        
        if playerESP.tracer then
            playerESP.tracer.Color = self.TracerColor
            playerESP.tracer.Thickness = self.TracerThickness
            playerESP.tracer.Transparency = 1 - self.TracerTransparency
        end
    end
    
    -- Update chams properties
    for player, highlight in pairs(self.ChamsInstances) do
        highlight.FillColor = self.ChamsVisible
        highlight.OutlineColor = self.ChamsOutlineColor
        highlight.FillTransparency = self.ChamsTransparency
        highlight.OutlineTransparency = self.ChamsOutlineTransparency
        
        -- Apply team color if enabled
        if self.ChamsTeamColor and player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        end
    end
    
    -- Update 3D box properties
    for player, boxData in pairs(self.Boxes3D) do
        for _, line in pairs(boxData.Lines) do
            line.Color = self.Box3DColor
            line.Thickness = self.Box3DThickness
        end
        for _, line in pairs(boxData.Outlines) do
            line.Color = self.Box3DOutlineColor
            line.Thickness = self.Box3DOutlineThickness
        end
    end
    
    -- Update corner ESP properties
    for player, cornerData in pairs(self.Corners) do
        for _, line in pairs(cornerData.Lines) do
            line.Color = self.CornerColor
            line.Thickness = self.CornerThickness
        end
        for _, line in pairs(cornerData.Outlines) do
            line.Color = self.CornerOutlineColor
            line.Thickness = self.CornerOutlineThickness
        end
    end
end

-- Function to add a player to ESP
function ESP:AddPlayer(player)
    if not self.Objects[player] then
        CreateESP(player)
    end
end

-- Function to remove a player from ESP
function ESP:RemovePlayer(player)
    if self.Objects[player] then
        for _, drawing in pairs(self.Objects[player]) do
            drawing:Remove()
        end
        self.Objects[player] = nil
    end
    
    if self.ChamsInstances[player] then
        self.ChamsInstances[player]:Destroy()
        self.ChamsInstances[player] = nil
    end
    
    if self.Boxes3D[player] then
        for _, line in pairs(self.Boxes3D[player].Lines) do
            line:Remove()
        end
        for _, line in pairs(self.Boxes3D[player].Outlines) do
            line:Remove()
        end
        self.Boxes3D[player] = nil
    end
    
    if self.Corners[player] then
        for _, line in pairs(self.Corners[player].Lines) do
            line:Remove()
        end
        for _, line in pairs(self.Corners[player].Outlines) do
            line:Remove()
        end
        self.Corners[player] = nil
    end
end

-- Function to toggle ESP
function ESP:Toggle(enabled)
    self.Enabled = enabled
    
    -- Hide all ESP objects if disabled
    if not enabled then
        for _, playerESP in pairs(self.Objects) do
            for _, drawing in pairs(playerESP) do
                drawing.Visible = false
            end
        end
        
        -- Hide all chams if disabled
        for _, highlight in pairs(self.ChamsInstances) do
            highlight.Enabled = false
        end
        
        -- Hide all 3D boxes if disabled
        for _, boxData in pairs(self.Boxes3D) do
            for _, line in pairs(boxData.Lines) do
                line.Visible = false
            end
            for _, line in pairs(boxData.Outlines) do
                line.Visible = false
            end
        end
        
        -- Hide all corner ESP if disabled
        for _, cornerData in pairs(self.Corners) do
            for _, line in pairs(cornerData.Lines) do
                line.Visible = false
            end
            for _, line in pairs(cornerData.Outlines) do
                line.Visible = false
            end
        end
    end
end

-- Function to toggle chams
function ESP:ToggleChams(enabled)
    self.ShowChams = enabled
    
    -- Update all chams
    for player, highlight in pairs(self.ChamsInstances) do
        highlight.Enabled = enabled and self.Enabled
    end
end

-- Function to toggle 3D boxes
function ESP:Toggle3DBoxes(enabled)
    self.Show3DBoxes = enabled
    
    -- Update box type based on selection
    if enabled then
        self.BoxType = "3D"
        self.ShowCornerBoxes = false
    end
end

-- Function to toggle corner ESP
function ESP:ToggleCornerBoxes(enabled)
    self.ShowCornerBoxes = enabled
    
    -- Update box type based on selection
    if enabled then
        self.BoxType = "corner"
        self.Show3DBoxes = false
    end
end

-- Function to update chams colors
function ESP:UpdateChamsColors(visible, occluded, outline)
    self.ChamsVisible = visible or self.ChamsVisible
    self.ChamsOccluded = occluded or self.ChamsOccluded
    self.ChamsOutlineColor = outline or self.ChamsOutlineColor
    
    -- Update all chams
    for player, highlight in pairs(self.ChamsInstances) do
        highlight.FillColor = self.ChamsVisible
        highlight.OutlineColor = self.ChamsOutlineColor
        
        -- Apply team color if enabled
        if self.ChamsTeamColor and player.Team then
            highlight.FillColor = player.Team.TeamColor.Color
        end
    end
end

-- Initialize ESP automatically
ESP:Init()

return ESP
