-- visuals.lua (Combined ESP System)
return function(library)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    -- Main ESP module
    local ESP = {
        Enabled = false,
        Boxes = {},
        Names = {},
        Distances = {},
        Healths = {},
        Armors = {},
        Tracers = {},
        Corners = {},
        Chams = {}
    }
    
    -- Helper function to get flag values
    local function GetFlag(name)
        if library and library.flags and library.flags[name] ~= nil then
            return library.flags[name]
        end
        return false
    end
    
    -- Helper function to get color values
    local function GetColor(name)
        if library and library.flags and library.flags[name] ~= nil then
            return library.flags[name]
        end
        return Color3.new(1, 1, 1)
    end
    
    -- Utility functions
    local function GetPlayerWeapon(player)
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
        if player and player.Character then
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
    
    local function IsTeammate(player)
        if player and LocalPlayer then
            return player.Team == LocalPlayer.Team and GetFlag("esp_teammates") == false
        end
        return false
    end
    
    -- Function to create 3D box for a player
    local function Create3DBox(player)
        if player == LocalPlayer then return end
        
        -- Create 12 lines for the 3D box
        local lines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = GetFlag("esp_box_thickness") or 1
            line.Color = GetColor("esp_box_color")
            line.Transparency = 1
            table.insert(lines, line)
        end
        
        -- Create 8 outline lines for the 3D box
        local outlines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = (GetFlag("esp_box_thickness") or 1) + 2
            line.Color = GetColor("esp_box_outline_color") or Color3.new(0, 0, 0)
            line.Transparency = 1
            table.insert(outlines, line)
        end
        
        -- Store the box
        ESP.Boxes[player] = {
            Lines = lines,
            Outlines = outlines,
            Player = player
        }
    end
    
    -- Function to create corner ESP for a player
    local function CreateCornerESP(player)
        if player == LocalPlayer then return end
        
        -- Create 8 lines for the corners
        local lines = {}
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = GetFlag("esp_corner_thickness") or 1
            line.Color = GetColor("esp_corner_color") or GetColor("esp_box_color")
            line.Transparency = 1
            table.insert(lines, line)
        end
        
        -- Create 8 outline lines for the corners
        local outlines = {}
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = (GetFlag("esp_corner_thickness") or 1) + 2
            line.Color = GetColor("esp_corner_outline_color") or Color3.new(0, 0, 0)
            line.Transparency = 1
            table.insert(outlines, line)
        end
        
        -- Store the corners
        ESP.Corners[player] = {
            Lines = lines,
            Outlines = outlines,
            Player = player
        }
    end
    
    -- Function to create chams for a player
    local function CreateChams(player)
        if player == LocalPlayer then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Enabled = false
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = GetColor("esp_chams_color")
        highlight.OutlineColor = GetColor("esp_chams_outline_color")
        
        -- Store the chams
        ESP.Chams[player] = {
            Highlight = highlight,
            Player = player
        }
        
        -- Set up chams when character is added
        player.CharacterAdded:Connect(function(character)
            if ESP.Chams[player] and ESP.Chams[player].Highlight then
                ESP.Chams[player].Highlight.Parent = character
            end
        end)
        
        -- Set up chams for existing character
        if player.Character and ESP.Chams[player] and ESP.Chams[player].Highlight then
            ESP.Chams[player].Highlight.Parent = player.Character
        end
    end
    
    -- Function to create name ESP for a player
    local function CreateNameESP(player)
        if player == LocalPlayer then return end
        
        local name = Drawing.new("Text")
        name.Visible = false
        name.Center = true
        name.Outline = true
        name.Font = 2
        name.Size = GetFlag("esp_text_size") or 13
        name.Color = GetColor("esp_name_color")
        
        -- Store the name
        ESP.Names[player] = {
            Text = name,
            Player = player
        }
    end
    
    -- Function to create distance ESP for a player
    local function CreateDistanceESP(player)
        if player == LocalPlayer then return end
        
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Center = true
        distance.Outline = true
        distance.Font = 2
        distance.Size = GetFlag("esp_text_size") or 13
        distance.Color = GetColor("esp_distance_color")
        
        -- Store the distance
        ESP.Distances[player] = {
            Text = distance,
            Player = player
        }
    end
    
    -- Function to create health bar ESP for a player
    local function CreateHealthESP(player)
        if player == LocalPlayer then return end
        
        local health = {
            Bar = Drawing.new("Square"),
            Outline = Drawing.new("Square"),
            Text = Drawing.new("Text")
        }
        
        health.Bar.Visible = false
        health.Bar.Filled = true
        health.Bar.Thickness = 1
        health.Bar.Color = Color3.new(0, 1, 0)
        
        health.Outline.Visible = false
        health.Outline.Filled = false
        health.Outline.Thickness = 1
        health.Outline.Color = Color3.new(0, 0, 0)
        
        health.Text.Visible = false
        health.Text.Center = false
        health.Text.Outline = true
        health.Text.Font = 2
        health.Text.Size = GetFlag("esp_text_size") or 13
        health.Text.Color = Color3.new(1, 1, 1)
        
        -- Store the health
        ESP.Healths[player] = {
            Bar = health.Bar,
            Outline = health.Outline,
            Text = health.Text,
            Player = player
        }
    end
    
    -- Function to create armor bar ESP for a player
    local function CreateArmorESP(player)
        if player == LocalPlayer then return end
        
        local armor = {
            Bar = Drawing.new("Square"),
            Outline = Drawing.new("Square"),
            Text = Drawing.new("Text")
        }
        
        armor.Bar.Visible = false
        armor.Bar.Filled = true
        armor.Bar.Thickness = 1
        armor.Bar.Color = GetColor("esp_armor_color") or Color3.new(0, 0.5, 1)
        
        armor.Outline.Visible = false
        armor.Outline.Filled = false
        armor.Outline.Thickness = 1
        armor.Outline.Color = Color3.new(0, 0, 0)
        
        armor.Text.Visible = false
        armor.Text.Center = false
        armor.Text.Outline = true
        armor.Text.Font = 2
        armor.Text.Size = GetFlag("esp_text_size") or 13
        armor.Text.Color = Color3.new(1, 1, 1)
        
        -- Store the armor
        ESP.Armors[player] = {
            Bar = armor.Bar,
            Outline = armor.Outline,
            Text = armor.Text,
            Player = player
        }
    end
    
    -- Function to create tracer ESP for a player
    local function CreateTracerESP(player)
        if player == LocalPlayer then return end
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = GetFlag("esp_tracer_thickness") or 1
        tracer.Color = GetColor("esp_tracer_color")
        
        -- Store the tracer
        ESP.Tracers[player] = {
            Line = tracer,
            Player = player
        }
    end
    
    -- Function to create all ESP elements for a player
    local function CreateESP(player)
        if player == LocalPlayer then return end
        
        Create3DBox(player)
        CreateCornerESP(player)
        CreateChams(player)
        CreateNameESP(player)
        CreateDistanceESP(player)
        CreateHealthESP(player)
        CreateArmorESP(player)
        CreateTracerESP(player)
    end
    
    -- Function to update 3D box ESP
    local function Update3DBox(player, box)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            for _, line in pairs(box.Lines) do
                line.Visible = false
            end
            for _, line in pairs(box.Outlines) do
                line.Visible = false
            end
            return
        end
        
        if GetFlag("esp_box") and GetFlag("name_type") == "3D" then
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
                    -- Update outline
                    box.Outlines[i].From = points[connection[1]]
                    box.Outlines[i].To = points[connection[2]]
                    box.Outlines[i].Color = GetColor("esp_box_outline_color") or Color3.new(0, 0, 0)
                    box.Outlines[i].Visible = true
                    
                    -- Update line
                    box.Lines[i].From = points[connection[1]]
                    box.Lines[i].To = points[connection[2]]
                    box.Lines[i].Color = GetColor("esp_box_color")
                    box.Lines[i].Visible = true
                end
            else
                for _, line in pairs(box.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(box.Outlines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(box.Lines) do
                line.Visible = false
            end
            for _, line in pairs(box.Outlines) do
                line.Visible = false
            end
        end
    end
    
    -- Function to get box corners
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
    
    -- Function to update corner ESP
    local function UpdateCornerESP(player, corner)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            for _, line in pairs(corner.Lines) do
                line.Visible = false
            end
            for _, line in pairs(corner.Outlines) do
                line.Visible = false
            end
            return
        end
        
        if GetFlag("esp_box") and GetFlag("name_type") == "corner" then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                local cornerSize = boxCorners.Size.Y * 0.2
                
                for i, line in ipairs(corner.Lines) do
                    line.Color = GetColor("esp_corner_color") or GetColor("esp_box_color")
                    
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
                    
                    line.Visible = true
                    
                    -- Update outline
                    corner.Outlines[i].From = line.From
                    corner.Outlines[i].To = line.To
                    corner.Outlines[i].Color = GetColor("esp_corner_outline_color") or Color3.new(0, 0, 0)
                    corner.Outlines[i].Visible = true
                end
            else
                for _, line in pairs(corner.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(corner.Outlines) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(corner.Lines) do
                line.Visible = false
            end
            for _, line in pairs(corner.Outlines) do
                line.Visible = false
            end
        end
    end
    
    -- Function to update chams
    local function UpdateChams(player, chams)
        if not player.Character or IsTeammate(player) then
            chams.Highlight.Enabled = false
            return
        end
        
        if GetFlag("esp_chams") then
            chams.Highlight.Enabled = true
            chams.Highlight.FillColor = GetColor("esp_chams_color")
            chams.Highlight.OutlineColor = GetColor("esp_chams_outline_color")
            chams.Highlight.FillTransparency = GetFlag("esp_chams_transparency") or 0.5
            chams.Highlight.OutlineTransparency = GetFlag("esp_chams_outline_transparency") or 0
            
            -- Apply team color if enabled
            if GetFlag("esp_team_color") and player.Team then
                chams.Highlight.FillColor = player.Team.TeamColor.Color
            end
        else
            chams.Highlight.Enabled = false
        end
    end
    
    -- Function to update name ESP
    local function UpdateNameESP(player, name)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            name.Text.Visible = false
            return
        end
        
        if GetFlag("esp_name") then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                name.Text.Position = Vector2.new(boxCorners.TopLeft.X + boxCorners.Size.X / 2, boxCorners.TopLeft.Y - 15)
                name.Text.Text = player.Name
                name.Text.Color = GetColor("esp_name_color")
                name.Text.Size = GetFlag("esp_text_size") or 13
                name.Text.Visible = true
                
                -- Apply team color if enabled
                if GetFlag("esp_team_color") and player.Team then
                    name.Text.Color = player.Team.TeamColor.Color
                end
            else
                name.Text.Visible = false
            end
        else
            name.Text.Visible = false
        end
    end
    
    -- Function to update distance ESP
    local function UpdateDistanceESP(player, distance)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            distance.Text.Visible = false
            return
        end
        
        if GetFlag("esp_distance") then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                local dist = math.floor(GetDistanceFromPlayer(player))
                distance.Text.Position = Vector2.new(boxCorners.BottomRight.X + 5, boxCorners.BottomRight.Y)
                distance.Text.Text = tostring(dist) .. "m"
                distance.Text.Color = GetColor("esp_distance_color")
                distance.Text.Size = GetFlag("esp_text_size") or 13
                distance.Text.Visible = true
                
                -- Apply team color if enabled
                if GetFlag("esp_team_color") and player.Team then
                    distance.Text.Color = player.Team.TeamColor.Color
                end
            else
                distance.Text.Visible = false
            end
        else
            distance.Text.Visible = false
        end
    end
    
    -- Function to update health ESP
    local function UpdateHealthESP(player, health)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            health.Bar.Visible = false
            health.Outline.Visible = false
            health.Text.Visible = false
            return
        end
        
        if GetFlag("esp_healthbar") then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                local currentHealth, maxHealth = GetPlayerHealth(player)
                local healthPercentage = currentHealth / maxHealth
                
                local barWidth = 3
                local barHeight = boxCorners.Size.Y
                
                health.Outline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                health.Outline.Position = Vector2.new(boxCorners.TopLeft.X - barWidth - 4, boxCorners.TopLeft.Y - 1)
                health.Outline.Visible = true
                
                health.Bar.Size = Vector2.new(barWidth, barHeight * healthPercentage)
                health.Bar.Position = Vector2.new(boxCorners.TopLeft.X - barWidth - 3, boxCorners.TopLeft.Y + barHeight * (1 - healthPercentage))
                health.Bar.Color = Color3.new(1 - healthPercentage, healthPercentage, 0)
                health.Bar.Visible = true
                
                health.Text.Text = tostring(math.floor(currentHealth))
                health.Text.Position = Vector2.new(boxCorners.TopLeft.X - barWidth - 16, boxCorners.TopLeft.Y + barHeight * (1 - healthPercentage))
                health.Text.Visible = GetFlag("esp_health_text") or false
            else
                health.Bar.Visible = false
                health.Outline.Visible = false
                health.Text.Visible = false
            end
        else
            health.Bar.Visible = false
            health.Outline.Visible = false
            health.Text.Visible = false
        end
    end
    
    -- Function to update armor ESP
    local function UpdateArmorESP(player, armor)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            armor.Bar.Visible = false
            armor.Outline.Visible = false
            armor.Text.Visible = false
            return
        end
        
        if GetFlag("esp_armor") and (not GetFlag("esp_armored_only") or IsPlayerArmored(player)) then
            local boxCorners = GetBoxCorners(player)
            if boxCorners then
                local armorValue = GetPlayerArmor(player)
                local armorPercentage = armorValue / 100
                
                local barWidth = 3
                local barHeight = boxCorners.Size.Y
                
                armor.Outline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                armor.Outline.Position = Vector2.new(boxCorners.TopRight.X + 2, boxCorners.TopRight.Y - 1)
                armor.Outline.Visible = true
                
                armor.Bar.Size = Vector2.new(barWidth, barHeight * armorPercentage)
                armor.Bar.Position = Vector2.new(boxCorners.TopRight.X + 3, boxCorners.TopRight.Y + barHeight * (1 - armorPercentage))
                armor.Bar.Color = GetColor("esp_armor_color")
                armor.Bar.Visible = true
                
                armor.Text.Text = tostring(math.floor(armorValue))
                armor.Text.Position = Vector2.new(boxCorners.TopRight.X + barWidth + 5, boxCorners.TopRight.Y + barHeight * (1 - armorPercentage))
                armor.Text.Visible = GetFlag("esp_armor_text") or false
            else
                armor.Bar.Visible = false
                armor.Outline.Visible = false
                armor.Text.Visible = false
            end
        else
            armor.Bar.Visible = false
            armor.Outline.Visible = false
            armor.Text.Visible = false
        end
    end
    
    -- Function to update tracer ESP
    local function UpdateTracerESP(player, tracer)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or IsTeammate(player) then
            tracer.Line.Visible = false
            return
        end
        
        if GetFlag("esp_tracer_lines") and not GetFlag("disable_tracers") then
            local rootPart = player.Character.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                
                tracer.Line.From = tracerStart
                tracer.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                tracer.Line.Color = GetColor("esp_tracer_lines_color")
                tracer.Line.Thickness = GetFlag("esp_tracer_thickness") or 1
                tracer.Line.Visible = true
                
                -- Apply team color if enabled
                if GetFlag("esp_team_color") and player.Team then
                    tracer.Line.Color = player.Team.TeamColor.Color
                end
            else
                tracer.Line.Visible = false
            end
        else
            tracer.Line.Visible = false
        end
    end
    
    -- Function to update all ESP elements
    local function UpdateESP()
        if not ESP.Enabled then
            for _, box in pairs(ESP.Boxes) do
                for _, line in pairs(box.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(box.Outlines) do
                    line.Visible = false
                end
            end
            
            for _, corner in pairs(ESP.Corners) do
                for _, line in pairs(corner.Lines) do
                    line.Visible = false
                end
                for _, line in pairs(corner.Outlines) do
                    line.Visible = false
                end
            end
            
            for _, chams in pairs(ESP.Chams) do
                if chams.Highlight then
                    chams.Highlight.Enabled = false
                end
            end
            
            for _, name in pairs(ESP.Names) do
                name.Text.Visible = false
            end
            
            for _, distance in pairs(ESP.Distances) do
                distance.Text.Visible = false
            end
            
            for _, health in pairs(ESP.Healths) do
                health.Bar.Visible = false
                health.Outline.Visible = false
                health.Text.Visible = false
            end
            
            for _, armor in pairs(ESP.Armors) do
                armor.Bar.Visible = false
                armor.Outline.Visible = false
                armor.Text.Visible = false
            end
            
            for _, tracer in pairs(ESP.Tracers) do
                tracer.Line.Visible = false
            end
            
            return
        end
        
        for player, box in pairs(ESP.Boxes) do
            Update3DBox(player, box)
        end
        
        for player, corner in pairs(ESP.Corners) do
            UpdateCornerESP(player, corner)
        end
        
        for player, chams in pairs(ESP.Chams) do
            UpdateChams(player, chams)
        end
        
        for player, name in pairs(ESP.Names) do
            UpdateNameESP(player, name)
        end
        
        for player, distance in pairs(ESP.Distances) do
            UpdateDistanceESP(player, distance)
        end
        
        for player, health in pairs(ESP.Healths) do
            UpdateHealthESP(player, health)
        end
        
        for player, armor in pairs(ESP.Armors) do
            UpdateArmorESP(player, armor)
        end
        
        for player, tracer in pairs(ESP.Tracers) do
            UpdateTracerESP(player, tracer)
        end
    end
    
    -- Function to clean up ESP for a player
    local function CleanupESP(player)
        if ESP.Boxes[player] then
            for _, line in pairs(ESP.Boxes[player].Lines) do
                line:Remove()
            end
            for _, line in pairs(ESP.Boxes[player].Outlines) do
                line:Remove()
            end
            ESP.Boxes[player  do
                line:Remove()
            end
            ESP.Boxes[player] = nil
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
        
        if ESP.Chams[player] and ESP.Chams[player].Highlight then
            ESP.Chams[player].Highlight:Destroy()
            ESP.Chams[player] = nil
        end
        
        if ESP.Names[player] then
            ESP.Names[player].Text:Remove()
            ESP.Names[player] = nil
        end
        
        if ESP.Distances[player] then
            ESP.Distances[player].Text:Remove()
            ESP.Distances[player] = nil
        end
        
        if ESP.Healths[player] then
            ESP.Healths[player].Bar:Remove()
            ESP.Healths[player].Outline:Remove()
            ESP.Healths[player].Text:Remove()
            ESP.Healths[player] = nil
        end
        
        if ESP.Armors[player] then
            ESP.Armors[player].Bar:Remove()
            ESP.Armors[player].Outline:Remove()
            ESP.Armors[player].Text:Remove()
            ESP.Armors[player] = nil
        end
        
        if ESP.Tracers[player] then
            ESP.Tracers[player].Line:Remove()
            ESP.Tracers[player] = nil
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
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end)
    
    -- Remove ESP when players leave
    Players.PlayerRemoving:Connect(CleanupESP)
    
    -- Update ESP on RenderStepped
    RunService.RenderStepped:Connect(UpdateESP)
    
    -- Toggle functions
    ESP.Toggle = function(enabled)
        ESP.Enabled = enabled
        if library and library.flags then
            library.flags.esp_enabled = enabled
        end
    end
    
    ESP.ToggleBox = function(enabled)
        if library and library.flags then
            library.flags.esp_box = enabled
        end
    end
    
    ESP.ToggleCorner = function(enabled)
        if library and library.flags then
            library.flags.esp_corner = enabled
        end
    end
    
    ESP.ToggleChams = function(enabled)
        if library and library.flags then
            library.flags.esp_chams = enabled
        end
    end
    
    ESP.ToggleName = function(enabled)
        if library and library.flags then
            library.flags.esp_name = enabled
        end
    end
    
    ESP.ToggleDistance = function(enabled)
        if library and library.flags then
            library.flags.esp_distance = enabled
        end
    end
    
    ESP.ToggleHealth = function(enabled)
        if library and library.flags then
            library.flags.esp_healthbar = enabled
        end
    end
    
    ESP.ToggleArmor = function(enabled)
        if library and library.flags then
            library.flags.esp_armor = enabled
        end
    end
    
    ESP.ToggleTracer = function(enabled)
        if library and library.flags then
            library.flags.esp_tracer_lines = enabled
        end
    end
    
    -- Initialize ESP state from library flags
    ESP.Enabled = GetFlag("esp_enabled") or false
    
    -- Return the ESP module
    return ESP
end
