--[[

    BBOT V1 / GZ MIX UI
    -> Made by @finobe 
    -> Kind of got bored idk what to do with life
]]

if getgenv().loaded then 
    getgenv().library:unload_menu() 
end 

getgenv().loaded = true 

-- Variables 
    local uis = game:GetService("UserInputService") 
    local players = game:GetService("Players") 
    local ws = game:GetService("Workspace")
    local rs = game:GetService("ReplicatedStorage")
    local http_service = game:GetService("HttpService")
    local gui_service = game:GetService("GuiService")
    local lighting = game:GetService("Lighting")
    local run = game:GetService("RunService")
    local stats = game:GetService("Stats")
    local coregui = game:GetService("CoreGui")
    local debris = game:GetService("Debris")
    local tween_service = game:GetService("TweenService")
    local sound_service = game:GetService("SoundService")

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new 
    local rect = Rect.new
    local cfr = CFrame.new
    local empty_cfr = cfr()
    local point_object_space = empty_cfr.PointToObjectSpace
    local angle = CFrame.Angles
    local dim_offset = UDim2.fromOffset

    local color = Color3.new
    local rgb = Color3.fromRGB
    local hex = Color3.fromHex
    local hsv = Color3.fromHSV
    local rgbseq = ColorSequence.new
    local rgbkey = ColorSequenceKeypoint.new
    local numseq = NumberSequence.new
    local numkey = NumberSequenceKeypoint.new

    local camera = ws.CurrentCamera
    local lp = players.LocalPlayer 
    local mouse = lp:GetMouse() 
    local gui_offset = gui_service:GetGuiInset().Y

    local max = math.max 
    local floor = math.floor 
    local min = math.min 
    local abs = math.abs 
    local noise = math.noise
    local rad = math.rad 
    local random = math.random 
    local pow = math.pow 
    local sin = math.sin 
    local pi = math.pi 
    local tan = math.tan 
    local atan2 = math.atan2 
    local clamp = math.clamp 

    local insert = table.insert 
    local find = table.find 
    local remove = table.remove
    local concat = table.concat
-- 

-- Library init
    getgenv().library = {
        directory = "bbotv1uiii",
        folders = {
            "/fonts",
            "/configs",
        },
        flags = {},
        config_flags = {},

        connections = {},   
        notifications = {},
        playerlist_data = {
            players = {},
            player = {}, 
        },
        colorpicker_open = false; 
        gui; 
    }

    local themes = {
        preset = {
            accent = rgb(195,33,72),
            outline = rgb(10, 10, 10),
            inline = rgb(30, 30, 30),
            text = rgb(180, 180, 180),
            text_outline = rgb(0, 0, 0),
            glow = rgb(195,33,72), -- ignore
            background = rgb(20, 20, 20)
        }, 	

        utility = {
            outline = {
                BackgroundColor3 = {}, 	
                Color = {}
            },
            inline = {
                BackgroundColor3 = {} 	
            },
            background = {
                BackgroundColor3 = {}
            },
            accent = {
                BackgroundColor3 = {}, 	
                TextColor3 = {}, 
                ImageColor3 = {}, 
                ScrollBarImageColor3 = {} 
            },
            text = {
                TextColor3 = {}	
            },
            text_outline = {
                Color = {} 	
            },
            glow = {
                ImageColor3 = {}	
            }
        }
    }

    local keys = {
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.RightParenthesis] = ")",
        [Enum.KeyCode.LeftParenthesis] = "(",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }
        
    library.__index = library

    for _, path in next, library.folders do 
        makefolder(library.directory .. path)
    end

    local flags = library.flags 
    local config_flags = library.config_flags

    -- Font importing system 
        if not isfile(library.directory .. "/fonts/main.ttf") then 
            writefile(library.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/f1nobe7650/other/raw/refs/heads/main/fonts/ProggyClean.ttf"))
        end
        
        local proggy_clean = {
            name = "ProggyClean",
            faces = {
                {
                    name = "Regular",
                    weight = 400,
                    style = "normal",
                    assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
                }
            }
        }
        
        if not isfile(library.directory .. "/fonts/main_encoded.ttf") then 
            writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(proggy_clean))
        end 
        
        library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)
    -- 
-- 

-- Library functions 
    -- Misc functions
        function library:tween(obj, properties) 
            local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
                
            return tween
        end 

        function library:close_current_element(cfg) 
            local path = library.current_element_open

            if path then
                path.set_visible(false)
                path.open = false 
            end
        end 

        function library:resizify(frame) 
            local Frame = Instance.new("TextButton")
            Frame.Position = dim2(1, -10, 1, -10)
            Frame.BorderColor3 = rgb(0, 0, 0)
            Frame.Size = dim2(0, 10, 0, 10)
            Frame.BorderSizePixel = 0
            Frame.BackgroundColor3 = rgb(255, 255, 255)
            Frame.Parent = frame
            Frame.BackgroundTransparency = 1 
            Frame.Text = ""

            local resizing = false 
            local start_size 
            local start 
            local og_size = frame.Size  

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = true
                    start = input.Position
                    start_size = frame.Size
                end
            end)

            Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                end
            end)

            library:connection(uis.InputChanged, function(input, game_event) 
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_size = dim2(
                        start_size.X.Scale,
                        math.clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            og_size.X.Offset,
                            viewport_x
                        ),
                        start_size.Y.Scale,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            og_size.Y.Offset,
                            viewport_y
                        )
                    )
                    frame.Size = current_size
                end
            end)
        end

        function library:mouse_in_frame(uiobject)
            local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
            local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

            return (y_cond and x_cond)
        end

        library.lerp = function(start, finish, t)
            t = t or 1 / 8

            return start * (1 - t) + finish * t
        end

        function library:draggify(frame)
            local dragging = false 
            local start_size = frame.Position
            local start 

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    start = input.Position
                    start_size = frame.Position
                end
            end)

            frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            library:connection(uis.InputChanged, function(input, game_event) 
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_position = dim2(
                        0,
                        clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            0,
                            viewport_x - frame.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            0,
                            viewport_y - frame.Size.Y.Offset
                        )
                    )

                    frame.Position = current_position
                end
            end)
        end 

        function library:convert(str)
            local values = {}

            for value in string.gmatch(str, "[^,]+") do
                insert(values, tonumber(value))
            end
            
            if #values == 4 then              
                return unpack(values)
            else 
                return
            end
        end
        
        function library:convert_enum(enum)
            local enum_parts = {}
        
            for part in string.gmatch(enum, "[%w_]+") do
                insert(enum_parts, part)
            end
        
            local enum_table = Enum
            for i = 2, #enum_parts do
                local enum_item = enum_table[enum_parts[i]]
        
                enum_table = enum_item
            end
        
            return enum_table
        end

        local config_holder;
        function library:update_config_list() 
            if not config_holder then 
                return 
            end
        
            local list = {}
        
            for idx, file in next, listfiles(library.directory .. "/configs") do
                local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
                list[#list + 1] = name
            end
            
            config_holder.refresh_options(list)
        end 

        function library:get_config()
            local Config = {}
        
            for _, v in flags do
                if type(v) == "table" and v.key then
                    Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
                elseif type(v) == "table" and v["Transparency"] and v["Color"] then
                    Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
                else
                    Config[_] = v
                end
            end 
            
            return http_service:JSONEncode(Config)
        end

        function library:load_config(config_json) 
            local config = http_service:JSONDecode(config_json)
            
            for _, v in next, config do 
                local function_set = library.config_flags[_]
                
                if _ == "config_name_list" then 
                    continue 
                end

                if function_set then 
                    if type(v) == "table" and v["Transparency"] and v["Color"] then
                        function_set(hex(v["Color"]), v["Transparency"])
                    elseif type(v) == "table" and v["active"] then 
                        function_set(v)
                    else
                        function_set(v)
                    end
                end 
            end 
        end 
        
        function library:round(number, float) 
            local multiplier = 1 / (float or 1)

            return floor(number * multiplier + 0.5) / multiplier
        end 

        function library:apply_theme(instance, theme, property) 
            insert(themes.utility[theme][property], instance)
        end

        function library:update_theme(theme, color)
            for _, property in themes.utility[theme] do 

                for m, object in property do 
                    if object[_] == themes.preset[theme] then 
                        object[_] = color 
                    end 
                end 
            end 

            themes.preset[theme] = color 
        end 

        function library:connection(signal, callback)
            local connection = signal:Connect(callback)
            
            insert(library.connections, connection)

            return connection 
        end

        function library:apply_stroke(parent) 
            local STROKE = library:create("UIStroke", {
                Parent = parent,
                Color = themes.preset.text_outline, 
                LineJoinMode = Enum.LineJoinMode.Miter
            }) 

            library:apply_theme(STROKE, "text_outline", "Color")
        end

        function library:create(instance, options)
            local ins = Instance.new(instance) 
            
            for prop, value in next, options do 
                ins[prop] = value
            end
            
            if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
                library:apply_theme(ins, "text", "TextColor3")
                library:apply_stroke(ins)
            end
            
            return ins 
        end

        function library:unload_menu() 
            if library.gui then 
                library.gui:Destroy()
            end

            if library.other then 
                library.other:Destroy()
            end 
            
            for index, connection in next, library.connections do 
                connection:Disconnect() 
                connection = nil 
            end     
            
            library = nil 
        end 
    --
        
    -- Library element functions
        function library:window(properties)
            local cfg = {
                name = properties.name or properties.Name or "sigmaware.hackpaste",
                size = properties.size or properties.Size or dim2(0, 582, 0, 502),
                selected_tab 
            }

            library.gui = library:create("ScreenGui", {
                Parent = coregui,
                Name = "\0",
                Enabled = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                IgnoreGuiInset = true,
            })

            library.other = library:create("ScreenGui", {
                Parent = coregui,
                Name = "\0",
                Enabled = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                IgnoreGuiInset = true,
            })

            -- Window
                local window_outline = library:create("Frame", {
                    Parent = library.gui;
                    Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = cfg.size;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(10, 10, 10)
                });	library:apply_theme(window_outline, "outline", "BackgroundColor3")
                window_outline.Position = dim2(0, window_outline.AbsolutePosition.Y, 0, window_outline.AbsolutePosition.Y)

                library:resizify(window_outline)
                library:draggify(window_outline)

                local glow = library:create("ImageLabel", {
                    Parent = window_outline,
                    Name = "",
                    ImageColor3 = themes.preset.glow,
                    ScaleType = Enum.ScaleType.Slice,
                    BorderColor3 = rgb(0, 0, 0),
                    BackgroundColor3 = rgb(255, 255, 255),
                    Visible = true,
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    ImageTransparency = 0.6, 
                    Position = dim2(0, -21, 0, -21),
                    Size = dim2(1, 41, 1, 41),
                    ZIndex = -1,
                    BorderSizePixel = 0,
                    SliceCenter = rect(vec2(21, 21), vec2(79, 79))
                }); library:apply_theme(glow, "glow", "ImageColor3");

                local accent = library:create("Frame", {
                    Parent = window_outline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local accent_darker_tint = library:create("Frame", {
                    Parent = accent;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent_darker_tint, "accent", "BackgroundColor3")
                
                local window_title = library:create("TextLabel", {
                    FontFace = library.font;
                    TextColor3 = themes.preset.text;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = accent_darker_tint;
                    Size = dim2(1, -8, 0, 0);
                    Position = dim2(0, 4, 0, 4);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIGradient", {
                    Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                    Parent = accent_darker_tint
                });
                
                local accent = library:create("Frame", {
                    Parent = accent_darker_tint;
                    Position = dim2(0, 4, 0, 20);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -8, 1, -24);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local inline = library:create("Frame", {
                    Parent = accent;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(10, 10, 10)
                });	library:apply_theme(inline, "outline", "BackgroundColor3")
                
                local background = library:create("Frame", {
                    Parent = inline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	library:apply_theme(background, "inline", "BackgroundColor3"); cfg.background = background
                
                local tab_button_holder = library:create("Frame", {
                    Parent = background;
                    BackgroundTransparency = 1;
                    Position = dim2(0, -1, 0, -1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 2, 0, 21);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); cfg.tab_button_holder = tab_button_holder
                
                library:create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = tab_button_holder;
                    Padding = dim(0, -1);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                });
            --

            -- Keybind list
                local keybind_list = library:create("Frame", {
                    Parent = library.other;
                    Size = dim2(0, 184, 0, 0);
                    Position = dim_offset(10, 500);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(10, 10, 10)
                }); library:draggify(keybind_list); library:apply_theme(keybind_list, "outline", "BackgroundColor3")
                library.keybind_list = keybind_list

                local accent = library:create("Frame", {
                    Parent = keybind_list;
                    Size = dim2(1, -2, 0, -2);
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local accent_darker_tint = library:create("Frame", {
                    Parent = accent;
                    Size = dim2(1, -2, 0, 0);
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(accent_darker_tint, "accent", "BackgroundColor3")
                
                library:create("UIGradient", {
                    Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                    Parent = accent_darker_tint
                });
                
                local accent = library:create("Frame", {
                    Parent = accent_darker_tint;
                    Size = dim2(1, -8, 0, 0);
                    Position = dim2(0, 4, 0, 20);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local inline = library:create("Frame", {
                    Parent = accent;
                    Size = dim2(1, -2, 0, 0);
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.outline
                }); library:apply_theme(inline, "outline", "BackgroundColor3")
                
                local background = library:create("Frame", {
                    Parent = inline;
                    Size = dim2(1, -2, 0, 0);
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.background
                }); library.keybind_parent = background; library:apply_theme(background, "background", "BackgroundColor3")
                
                library:create("UIPadding", {
                    PaddingTop = dim(0, 7);
                    PaddingBottom = dim(0, 5);
                    Parent = background;
                    PaddingRight = dim(0, 7);
                    PaddingLeft = dim(0, 7)
                });
                
                library:create("UIListLayout", {
                    Parent = background;
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 1);
                    Parent = inline
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 1);
                    Parent = accent
                });
                
                local title = library:create("TextLabel", {
                    FontFace = library.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "Keybinds";
                    Parent = accent_darker_tint;
                    Size = dim2(1, -8, 0, 0);
                    Position = dim2(0, 5, 0, 4);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 4);
                    Parent = accent_darker_tint
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 1);
                    Parent = accent
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 1);
                    Parent = keybind_list
                });
            -- 
                
            return setmetatable(cfg, library)
        end 

        function library:target_indicator() 
            local cfg = {ignore = true} 

            -- Instances 
                local window_outline = library:create("Frame", {
                    Parent = library.gui;
                    Position = dim_offset(100, 200);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim_offset(100, 200);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(10, 10, 10)
                });	library:apply_theme(window_outline, "outline", "BackgroundColor3")
                window_outline.Position = dim2(0, window_outline.AbsolutePosition.Y, 0, window_outline.AbsolutePosition.Y)
                library.target_indicator = window_outline

                library:resizify(window_outline)
                library:draggify(window_outline)

                local glow = library:create("ImageLabel", {
                    Parent = window_outline,
                    Name = "",
                    ImageColor3 = themes.preset.glow,
                    ScaleType = Enum.ScaleType.Slice,
                    BorderColor3 = rgb(0, 0, 0),
                    BackgroundColor3 = rgb(255, 255, 255),
                    Visible = true,
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    ImageTransparency = 0.6, 
                    Position = dim2(0, -21, 0, -21),
                    Size = dim2(1, 41, 1, 41),
                    ZIndex = -1,
                    BorderSizePixel = 0,
                    SliceCenter = rect(vec2(21, 21), vec2(79, 79))
                }); library:apply_theme(glow, "glow", "ImageColor3");

                local accent = library:create("Frame", {
                    Parent = window_outline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local accent_darker_tint = library:create("Frame", {
                    Parent = accent;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent_darker_tint, "accent", "BackgroundColor3")
                
                local window_title = library:create("TextLabel", {
                    FontFace = library.font;
                    TextColor3 = themes.preset.text;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "Hibdwa";
                    Parent = accent_darker_tint;
                    Size = dim2(1, -8, 0, 0);
                    Position = dim2(0, 4, 0, 4);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIGradient", {
                    Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                    Parent = accent_darker_tint
                });
                
                local accent = library:create("Frame", {
                    Parent = accent_darker_tint;
                    Position = dim2(0, 4, 0, 20);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -8, 1, -24);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	library:apply_theme(accent, "accent", "BackgroundColor3")
                
                local inline = library:create("Frame", {
                    Parent = accent;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(10, 10, 10)
                });	library:apply_theme(inline, "outline", "BackgroundColor3")
                
                local background = library:create("Frame", {
                    Parent = inline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	library:apply_theme(background, "inline", "BackgroundColor3"); cfg.elements = background
                
                library:create("UIListLayout", {
                    Parent = background;
                    Padding = dim(0, 6);
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    SortOrder = Enum.SortOrder.LayoutOrder
                });

                library:create("UIPadding", {
                    PaddingBottom = dim(0, 6);
                    PaddingRight = dim(0, 6);
                    PaddingLeft = dim(0, 6);
                    PaddingTop = dim(0, 6);
                    Parent = background
                });
            -- 
            
            function cfg.change_name(name) 
                window_title.Text = name
            end 

            cfg.change_name("Nigger") 

            return setmetatable(cfg, library)
        end

        function library:tab(properties)
            local cfg = {
                name = properties.name or "visuals", 
            } 

            -- Instances 
                -- Tab Button
                    local tab_button_outline = library:create("TextButton", {
                        BorderColor3 = rgb(0, 0, 0);
                        AutoButtonColor = false; 
                        Text = "";
                        Parent = self.tab_button_holder;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(10, 10, 10)
                    });
                    
                    local tab_button_inline = library:create("Frame", {
                        Parent = tab_button_outline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.inline -- 76, 9, 31
                    }); library:apply_theme(tab_button_inline, "inline", "BackgroundColor3");
                    library:apply_theme(tab_button_inline, "accent", "BackgroundColor3");
                    
                    local tab_button_background = library:create("Frame", {
                        Parent = tab_button_inline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.background -- 76, 9, 31
                    }); library:apply_theme(tab_button_background, "accent", "BackgroundColor3");
                    library:apply_theme(tab_button_background, "background", "BackgroundColor3");
                    
                    local tab_button_title = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = themes.preset.text;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.name;
                        Parent = tab_button_background;
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });

                    local gradient1 = library:create("UIGradient", {
                        Color = rgbseq{rgbkey(0, rgb(180, 180, 180)), rgbkey(1, rgb(180, 180, 180))};
                        Parent = tab_button_background;
                        Enabled = false
                    });
                    
                    local gradient2 = library:create("UIGradient", {
                        Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                        Parent = tab_button_inline;
                        Enabled = false
                    });
                -- 

                -- Page Elements
                    -- Page Holder
                        local page_holder = library:create("Frame", {
                            Parent = self.background;
                            BackgroundTransparency = 1;
                            Position = dim2(0, 6, 0, 27);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -12, 1, -33);
                            BorderSizePixel = 0;
                            Visible = false;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        library:create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal;
                            HorizontalFlex = Enum.UIFlexAlignment.Fill;
                            Parent = page_holder;
                            Padding = dim(0, 6);
                            SortOrder = Enum.SortOrder.LayoutOrder;
                            VerticalFlex = Enum.UIFlexAlignment.Fill
                        });
                    -- 

                    -- Columns
                        -- Left
                            local outline = library:create("Frame", {
                                BorderColor3 = rgb(0, 0, 0);
                                Parent = page_holder;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(outline, "outline", "BackgroundColor3");
                            
                            local inline = library:create("Frame", {
                                Parent = outline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            }); library:apply_theme(inline, "inline", "BackgroundColor3");
                            
                            local outline = library:create("Frame", {
                                Parent = inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(outline, "outline", "BackgroundColor3");
                            
                            local background = library:create("Frame", {
                                Parent = outline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.background
                            }); library:apply_theme(background, "background", "BackgroundColor3");
                            
                            local left = library:create("ScrollingFrame", {
                                ScrollBarImageColor3 = themes.preset.accent;
                                Active = true;
                                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                                ScrollBarThickness = 3;
                                Parent = background;
                                Size = dim2(1, -12, 1, -12);
                                BackgroundTransparency = 1;
                                Position = dim2(0, 6, 0, 6);
                                BackgroundColor3 = rgb(255, 255, 255);
                                BorderColor3 = rgb(0, 0, 0);
                                BorderSizePixel = 0;
                                CanvasSize = dim2(0, 0, 0, 0)
                            }); cfg.left = left; library:apply_theme(left, "accent", "ScrollBarImageColor3"); 
                            
                            library:create("UIListLayout", {
                                Parent = left;
                                Padding = dim(0, 6);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });
                        -- 

                        -- Right
                            local outline = library:create("Frame", {
                                BorderColor3 = rgb(0, 0, 0);
                                Parent = page_holder;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(outline, "outline", "BackgroundColor3"); 
                            
                            local inline = library:create("Frame", {
                                Parent = outline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            }); library:apply_theme(inline, "inline", "BackgroundColor3");
                            
                            local outline = library:create("Frame", {
                                Parent = inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(outline, "outline", "BackgroundColor3"); 
                            
                            local background = library:create("Frame", {
                                Parent = outline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.background
                            }); library:apply_theme(background, "background", "BackgroundColor3"); 
                            
                            local right = library:create("ScrollingFrame", {
                                ScrollBarImageColor3 = themes.preset.accent;
                                Active = true;
                                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                                ScrollBarThickness = 3;
                                Parent = background;
                                Size = dim2(1, -12, 1, -12);
                                BackgroundTransparency = 1;
                                Position = dim2(0, 6, 0, 6);
                                BackgroundColor3 = rgb(255, 255, 255);

                                BorderSizePixel = 0;
                                CanvasSize = dim2(0, 0, 0, 0)
                            }); cfg.right = right; library:apply_theme(right, "accent", "ScrollBarImageColor3");
                            
                            library:create("UIListLayout", {
                                Parent = right;
                                Padding = dim(0, 6);
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });
                        --  
                    -- 
                -- 
            -- 

            function cfg.open_tab() 
                local selected_tab = self.selected_tab
                
                if selected_tab then 
                    selected_tab[1].BackgroundColor3 = themes.preset.background
                    selected_tab[2].BackgroundColor3 = themes.preset.inline

                    selected_tab[3].Enabled = false
                    selected_tab[4].Enabled = false

                    selected_tab[5].Visible = false

                    selected_tab = nil 
                end

                tab_button_background.BackgroundColor3 = themes.preset.accent
                tab_button_inline.BackgroundColor3 = themes.preset.accent

                gradient1.Enabled = true
                gradient2.Enabled = true 

                page_holder.Visible = true 

                self.selected_tab = {tab_button_background, tab_button_inline, gradient1, gradient2, page_holder}
            end

            tab_button_outline.MouseButton1Down:Connect(function()
                cfg.open_tab()
            end)

            if not self.selected_tab then 
                cfg.open_tab(true) 
            end

            return setmetatable(cfg, library)    
        end 

        function library:section(properties)
            local cfg = {
                name = properties.name or properties.Name or "section", 
                side = properties.side or "left"
            }   

            -- Instances
                local parent = self[cfg.side] 

                local outline = library:create("Frame", {
                    Parent = parent;
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(10, 10, 10)
                });	library:apply_theme(outline, "outline", "BackgroundColor3")
                
                local inline = library:create("Frame", {
                    Parent = outline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	library:apply_theme(inline, "inline", "BackgroundColor3")
                
                local background = library:create("Frame", {
                    Parent = inline;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.background
                });	library:apply_theme(background, "background", "BackgroundColor3")
                
                local section_title = library:create("TextLabel", {
                    FontFace = library.font;
                    TextColor3 = themes.preset.text;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = background;
                    Size = dim2(1, 0, 0, 0);
                    Position = dim2(0, 4, 0, 4);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                local elements = library:create("Frame", {
                    Parent = background;
                    Position = dim2(0, 4, 0, 21);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -8, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); cfg.elements = elements
                
                library:create("UIListLayout", {
                    Parent = elements;
                    Padding = dim(0, 6);
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                local accent_line = library:create("Frame", {
                    Parent = background;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(accent_line, "accent", "BackgroundColor3")
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 6);
                    Parent = background
                });
            -- 

            -- Connections 
                parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
                    local is_scrollbar_visible = parent.AbsoluteCanvasSize.Y > parent.AbsoluteSize.Y

                    outline.Size = dim2(1, is_scrollbar_visible and -9 or 0, 0, 0)
                end)
            -- 

            return setmetatable(cfg, library)
        end 

        -- Elements  
            function library:label(options)
                local cfg = {name = options.name or "This is a textlabel", value = options.value or nil}
                
                -- Element
                    local toggle = library:create("TextLabel", {
                        Parent = self.elements;
                        BackgroundTransparency = 1;
                        Text = "";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 14);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    local title = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = themes.preset.text;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.name;
                        Parent = toggle;
                        Size = dim2(1, 0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    local right_components = library:create("Frame", {
                        Parent = toggle;
                        Position = dim2(1, 0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 0, 0, 14);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); cfg.right_components = right_components
                    
                    library:create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalAlignment = Enum.HorizontalAlignment.Right;
                        Parent = right_components;
                        Padding = dim(0, 4);
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                -- 

                local value_text; 
                if cfg.value then 
                    local a = library:create("TextLabel", {
                        Parent = toggle;
                        BackgroundTransparency = 1;
                        Text = "";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 14);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    value_text = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = themes.preset.text;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.value;
                        Parent = a;
                        Size = dim2(1, 0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Right;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                end 
                
                function cfg.set(name)
                    if cfg.value then 
                        value_text.Text = name
                    else
                        title.Text = name
                    end 
                end

                return setmetatable(cfg, library)
            end 

            function library:toggle(options) 
                local cfg = {
                    enabled = options.enabled or nil,
                    name = options.name or "Toggle",
                    flag = options.flag or tostring(random(1,9999999)),
                    
                    default = options.default or false,
                    folding = options.folding or false, 
                    callback = options.callback or function() end,
                }

                -- Instances
                    -- Element
                        local toggle = library:create(self.ignore and "TextLabel" or "TextButton", {
                            Parent = self.elements;
                            BackgroundTransparency = 1;
                            Text = "";
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, 0, 0, 14);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        local toggle_outline = library:create("Frame", {
                            Parent = toggle;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 14, 0, 14);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(10, 10, 10)
                        });	library:apply_theme(toggle_outline, "outline", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = toggle_outline;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.inline
                        });	library:apply_theme(inline, "inline", "BackgroundColor3"); library:apply_theme(inline, "accent", "BackgroundColor3");

                        local inline_gradient = library:create("UIGradient", {
                            Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                            Parent = inline;
                            Enabled = false
                        });
                        
                        local background = library:create("Frame", {
                            Parent = inline;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.background
                        });	library:apply_theme(background, "background", "BackgroundColor3"); library:apply_theme(background, "accent", "BackgroundColor3");
                        
                        local background_gradient = library:create("UIGradient", {
                            Color = rgbseq{rgbkey(0, rgb(180, 180, 180)), rgbkey(1, rgb(180, 180, 180))};
                            Parent = background;
                            Enabled = false
                        });                 

                        local title = library:create("TextLabel", {
                            FontFace = library.font;
                            TextColor3 = themes.preset.text;
                            BorderColor3 = rgb(0, 0, 0);
                            Text = cfg.name;
                            Parent = toggle;
                            Size = dim2(1, 0, 0, 0);
                            Position = dim2(0, 20, 0, 1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        local right_components = library:create("Frame", {
                            Parent = toggle;
                            Position = dim2(1, 0, 0, 0);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 0, 0, 14);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); cfg.right_components = right_components
                        
                        library:create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal;
                            HorizontalAlignment = Enum.HorizontalAlignment.Right;
                            Parent = right_components;
                            Padding = dim(0, 4);
                            SortOrder = Enum.SortOrder.LayoutOrder
                        });
                    -- 

                    -- Sub sections
                        local elements;

                        if cfg.folding then
                            elements = library:create("Frame", {

                                Parent = self.elements;
                                BackgroundTransparency = 1;
                                Position = dim2(0, 4, 0, 21);
                                Size = dim2(1, 0, 0, 0);
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundColor3 = rgb(255, 255, 255)
                            }); cfg.elements = elements
                            
                            library:create("UIListLayout", {
                                Parent = elements;
                                Padding = dim(0, 6);
                                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                                SortOrder = Enum.SortOrder.LayoutOrder
                            });                            
                        end 
                    --      
                -- 
                
                -- Functions 
                    function cfg.set(bool)                        
                        background.BackgroundColor3 = bool and themes.preset.accent or themes.preset.background
                        inline.BackgroundColor3 = bool and themes.preset.accent or themes.preset.inline

                        inline_gradient.Enabled = bool 
                        background_gradient.Enabled = bool 

                        cfg.callback(bool)

                        if cfg.folding then 
                            elements.Visible = bool
                        end
                    end 

                    cfg.set(cfg.default)

                    config_flags[cfg.flag] = cfg.set
                -- 
                    
                -- Connections
                    if not self.ignore then 
                        toggle.MouseButton1Click:Connect(function()
                            cfg.enabled = not cfg.enabled 
                            cfg.set(cfg.enabled)
                        end)
                    end
                -- 

                return setmetatable(cfg, library)
            end 
            
            function library:slider(options) 
                local cfg = {
                    name = options.name or nil,
                    suffix = options.suffix or "",
                    flag = options.flag or tostring(2^789),
                    callback = options.callback or function() end, 
    
                    min = options.min or options.minimum or 0,
                    max = options.max or options.maximum or 100,
                    intervals = options.interval or options.decimal or 1,
                    default = options.default or 10,
                    value = options.default or 10, 

                    ignore = options.ignore or false, 
                    dragging = false,
                } 

                -- Instances 
                    local slider = library:create("Frame", {
                        Parent = self.elements;
                        BackgroundTransparency = 1;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 28);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    local title = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = themes.preset.text;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.name;
                        Parent = slider;
                        Size = dim2(1, 0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    local holder = library:create(self.ignore and "TextLabel" or "TextButton", {
                        Parent = slider; 
                        Text = "";
                        Position = dim2(0, 0, 0, 16);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(10, 10, 10)
                    });	library:apply_theme(holder, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = holder;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.inline
                    });	library:apply_theme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.background
                    });	library:apply_theme(background, "background", "BackgroundColor3")
                    
                    local sub_text = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = rgb(170, 170, 170);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "500px";
                        Parent = background;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        Size = dim2(1, 0, 1, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(0, 0, 0, -2);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    local fill = library:create("Frame", {
                        Parent = background;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0.5, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.accent
                    });	library:apply_theme(fill, "accent", "BackgroundColor3")
                    
                    library:create("UIGradient", {
                        Color = rgbseq{rgbkey(0, rgb(180, 180, 180)), rgbkey(1, rgb(180, 180, 180))};
                        Parent = fill
                    });                
                -- 

                -- Functions 
                    function cfg.set(value)
                        local valuee = tonumber(value)

                        if valuee == nil then 
                            return 
                        end 

                        cfg.value = clamp(library:round(valuee, cfg.intervals), cfg.min, cfg.max)

                        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                        sub_text.Text = tostring(cfg.value) .. cfg.suffix

                        flags[cfg.flag] = cfg.value

                        cfg.callback(flags[cfg.flag])
                    end 

                    cfg.set(cfg.default)
                -- 

                -- Connections
                    if not self.ignore then 
                        holder.MouseButton1Down:Connect(function()
                            cfg.dragging = true 
                        end)

                        holder.AutoButtonColor = false;

                        library:connection(uis.InputChanged, function(input)
                            if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                                local size_x = (input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X
                                local value = ((cfg.max - cfg.min) * size_x) + cfg.min

                                cfg.set(value)
                            end
                        end)

                        library:connection(uis.InputEnded, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                cfg.dragging = false 
                            end 
                        end)
                    end
                -- 

                cfg.set(cfg.default)

                config_flags[cfg.flag] = cfg.set

                return setmetatable(cfg, library)
            end 

            function library:dropdown(options) 
                local cfg = {
                    name = options.name or nil,
                    flag = options.flag or tostring(random(1,9999999)),

                    items = options.items or {""},
                    callback = options.callback or function() end,
                    multi = options.multi or false, 
                    scrolling = options.scrolling or false, 

                    -- Ignore these 
                    open = false, 
                    option_instances = {}, 
                    multi_items = {}, 
                    ignore = options.ignore or false, 
                }   

                cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"

                flags[cfg.flag] = {} 

                -- Instances
                    -- Element 
                        local dropdown = library:create("Frame", {
                            Parent = self.elements;
                            BackgroundTransparency = 1;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, 0, 0, 36);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        local title = library:create("TextLabel", {
                            FontFace = library.font;
                            TextColor3 = rgb(200, 200, 200);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = cfg.name;
                            Parent = dropdown;
                            Size = dim2(1, 0, 0, 0);
                            Position = dim2(0, 0, 0, 1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        local right_components = library:create("Frame", {
                            Parent = dropdown;
                            Position = dim2(1, 0, 0, -1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 0, 0, 14);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        library:create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal;
                            HorizontalAlignment = Enum.HorizontalAlignment.Right;
                            Parent = right_components;
                            Padding = dim(0, 4);
                            SortOrder = Enum.SortOrder.LayoutOrder
                        });
                        
                        local element = library:create("TextButton", {
                            Parent = dropdown;
                            Text = "";
                            AutoButtonColor = false;
                            Position = dim2(0, 0, 0, 16);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, 0, 0, 20);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(10, 10, 10)
                        });	library:apply_theme(element, "outline", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = element;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.inline
                        });	library:apply_theme(inline, "inline", "BackgroundColor3")
                        
                        local background = library:create("Frame", {
                            Parent = inline;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.background
                        });	library:apply_theme(background, "background", "BackgroundColor3")
                        
                        local title_in = library:create("TextLabel", {
                            FontFace = library.font;
                            TextColor3 = rgb(170, 170, 170);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = cfg.name;
                            Parent = background;
                            Size = dim2(1, -7, 1, 0);
                            Position = dim2(0, 7, 0, -1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        local item = library:create("TextLabel", {
                            FontFace = library.font;
                            TextColor3 = rgb(170, 170, 170);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = "...";
                            Parent = background;
                            Size = dim2(1, -10, 1, 0);
                            Position = dim2(0, 7, 0, -1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Right;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                    -- 

                    -- Holder
                        local items = library:create("Frame", {
                            Parent = library.gui;
                            Visible = false;
                            BorderColor3 = rgb(0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            BackgroundColor3 = rgb(10, 10, 10)
                        }); library:apply_theme(items, "outline", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = items;
                            Size = dim2(1, -2, 1, -2);
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            BackgroundColor3 = themes.preset.inline
                        }); library:apply_theme(inline, "inline", "BackgroundColor3")
                        
                        local item_holder = library:create("Frame", {
                            Parent = inline;
                            Size = dim2(1, -2, 1, -2);
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            BackgroundColor3 = themes.preset.background
                        }); library:apply_theme(item_holder, "background", "BackgroundColor3") 
                        
                        library:create("UIListLayout", {
                            Parent = item_holder;
                            Padding = dim(0, 6);
                            SortOrder = Enum.SortOrder.LayoutOrder
                        });
                        
                        library:create("UIPadding", {
                            PaddingTop = dim(0, 2);
                            PaddingBottom = dim(0, 2);
                            Parent = item_holder;
                            PaddingRight = dim(0, 6);
                            PaddingLeft = dim(0, 6)
                        });
                        
                        library:create("UIPadding", {
                            PaddingBottom = dim(0, 2);
                            Parent = items
                        });
                        
                        library:create("UIPadding", {
                            PaddingBottom = dim(0, 2);
                            Parent = inline
                        });                        
                    --  
                -- 

                -- Functions 
                    function cfg.render_option(text) 
                        local option = library:create("TextButton", {
                            FontFace = library.font;
                            TextColor3 = themes.preset.text;
                            BorderColor3 = rgb(0, 0, 0);
                            Text = text;
                            Parent = item_holder;
                            Size = dim2(1, 0, 0, 0);
                            Position = dim2(0, 0, 0, 1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:apply_theme(option, "accent", "TextColor3")

                        return option
                    end 
                    
                    function cfg.set_visible(bool) 
                        items.Visible = bool
                    end
                    
                    function cfg.set(value)
                        local selected = {}
                        local isTable = type(value) == "table"

                        if value == nil then 
                            return 
                        end

                        for _, option in next, cfg.option_instances do 
                            if option.Text == value or (isTable and find(value, option.Text)) then 
                                insert(selected, option.Text)
                                cfg.multi_items = selected
                                option.TextColor3 = themes.preset.accent
                            else
                                option.TextColor3 = themes.preset.text
                            end
                        end

                        title_in.Text = if isTable then concat(selected, ", ") else selected[1]

                        flags[cfg.flag] = if isTable then selected else selected[1]
                        
                        cfg.callback(flags[cfg.flag]) 
                    end
                    
                    function cfg.refresh_options(list) 
                        for _, option in next, cfg.option_instances do 
                            option:Destroy() 
                        end
                        
                        cfg.option_instances = {} 

                        for _, option in next, list do 
                            local button = cfg.render_option(option)

                            insert(cfg.option_instances, button)
                            
                            button.MouseButton1Down:Connect(function()
                                if cfg.multi then 
                                    local selected_index = find(cfg.multi_items, button.Text)
        
                                    if selected_index then 
                                        remove(cfg.multi_items, selected_index)
                                    else
                                        insert(cfg.multi_items, button.Text)
                                    end
                                    
                                    cfg.set(cfg.multi_items) 				
                                else 
                                    cfg.set_visible(false)
                                    cfg.open = false 
                                    
                                    cfg.set(button.Text)
                                end
                            end)
                        end
                    end

                    cfg.refresh_options(cfg.items)

                    cfg.set(cfg.default)

                    config_flags[cfg.flag] = cfg.set
                -- 

                -- Connections 
                    element.MouseButton1Click:Connect(function()
                        cfg.open = not cfg.open 
                        
                        items.Size = dim2(0, dropdown.AbsoluteSize.X, 0, items.Size.Y.Offset)
                        items.Position = dim2(0, dropdown.AbsolutePosition.X, 0, dropdown.AbsolutePosition.Y + 97)
                        
                        cfg.set_visible(cfg.open)
                    end)

                    uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if not (library:mouse_in_frame(items) or library:mouse_in_frame(dropdown)) then 
                                cfg.open = false
                                cfg.set_visible(false)
                            end
                        end
                    end)
                -- 

                return setmetatable(cfg, library)
            end 
            
            function library:colorpicker(options) 
                local cfg = {
                    name = options.name or "Color", 
                    flag = options.flag or tostring(2^789),

                    color = options.color or color(1, 1, 1), -- Default to white color if not provided
                    alpha = options.alpha and 1 - options.alpha or 0,
                    
                    open = false, 
                    callback = options.callback or function() end,
                }

                -- Instances
                    -- Label reparenting 
                        if not self.right_components then 
                            cfg.label = self:label({name = cfg.name})
                        end
                    --  

                    -- Element
                        local element = library:create("TextButton", {
                            Parent = self.right_components or cfg.label.right_components;
                            Text = "";
                            AutoButtonColor = false;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 24, 0, 14);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(10, 10, 10)
                        });	library:apply_theme(element, "outline", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = element;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.inline
                        });	library:apply_theme(inline, "inline", "BackgroundColor3")
                        
                        local color_visualizer = library:create("TextButton", {
                            Parent = inline;
                            AutoButtonColor = false; 
                            Text = "";
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(56, 243, 27)
                        });
                        
                        local element_alpha = library:create("ImageLabel", {
                            ScaleType = Enum.ScaleType.Tile;
                            ImageTransparency = 0;
                            BorderColor3 = rgb(0, 0, 0);
                            Parent = color_visualizer;
                            Image = "rbxassetid://18274452449";
                            BackgroundTransparency = 1;
                            Size = dim2(1, 0, 1, 0);
                            TileSize = dim2(0, 4, 0, 4);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        library:create("UIGradient", {
                            Rotation = 90;
                            Parent = color_visualizer;
                            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(185, 185, 185))}
                        });
                    -- 

                    -- Elements
                        local colorpicker = library:create("Frame", {
                            Parent = library.gui;
                            Position = dim2(0, 1200, 0.18799997866153717, 0);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 184, 0, 197);
                            BorderSizePixel = 0;
                            Visible = false;
                            BackgroundColor3 = rgb(10, 10, 10)
                        }); library:apply_theme(outline, "outline", "BackgroundColor3"); 
                        
                        local accent = library:create("Frame", {
                            Parent = colorpicker;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.accent
                        });	library:apply_theme(accent, "accent", "BackgroundColor3")
                        
                        local accent_darker_tint = library:create("Frame", {
                            Parent = accent;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.accent
                        }); library:apply_theme(accent_darker_tint, "accent", "BackgroundColor3")
                        
                        library:create("UIGradient", {
                            Color = rgbseq{rgbkey(0, rgb(200, 200, 200)), rgbkey(1, rgb(200, 200, 200))};
                            Parent = accent_darker_tint
                        });
                        
                        local accent = library:create("Frame", {
                            Parent = accent_darker_tint;
                            Position = dim2(0, 4, 0, 20);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -8, 1, -24);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.accent
                        });	library:apply_theme(accent, "accent", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = accent;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(10, 10, 10)
                        });	library:apply_theme(inline, "outline", "BackgroundColor3")
                        
                        local background = library:create("Frame", {
                            Parent = inline;
                            Position = dim2(0, 1, 0, 1);
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -2, 1, -2);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.background
                        }); library:apply_theme(background, "background", "BackgroundColor3")
                        
                        library:create("UIPadding", {
                            PaddingTop = dim(0, 5);
                            PaddingBottom = dim(0, -10);
                            Parent = background;
                            PaddingRight = dim(0, 4);
                            PaddingLeft = dim(0, 5)
                        });
                        
                        -- Alpha
                            local alpha_button = library:create("TextButton", {
                                AnchorPoint = vec2(0, 0.5);
                                AutoButtonColor = false; 
                                Text = "";
                                Parent = background;
                                Position = dim2(0, 0, 1, -48);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -1, 0, 14);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            });	library:apply_theme(alpha_button, "outline", "BackgroundColor3")
                            
                            local inline = library:create("Frame", {
                                Parent = alpha_button;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            });	library:apply_theme(inline, "inline", "BackgroundColor3")
                            
                            local alpha_color = library:create("Frame", {
                                Parent = inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(0, 221, 255)
                            });
                            
                            local alphaind = library:create("ImageLabel", {
                                ScaleType = Enum.ScaleType.Tile;
                                BorderColor3 = rgb(0, 0, 0);
                                Parent = alpha_color;
                                Image = "rbxassetid://18274452449";
                                BackgroundTransparency = 1;
                                Size = dim2(1, 0, 1, 0);
                                TileSize = dim2(0, 4, 0, 4);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            library:create("UIGradient", {
                                Parent = alphaind;
                                Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                            });
                            
                            local alpha_picker = library:create("Frame", {
                                Parent = alpha_color;
                                BorderMode = Enum.BorderMode.Inset;
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(0, 3, 1, 2);
                                Position = dim2(0, -1, 0, -1);
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                        -- 

                        -- Hue
                            local hue_button = library:create("TextButton", {
                                AnchorPoint = vec2(1, 0);
                                Text = "";
                                AutoButtonColor = false;
                                Parent = background;
                                Position = dim2(1, -1, 0, 0);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(0, 14, 1, -60);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            });	library:apply_theme(hue_button, "outline", "BackgroundColor3")
                            
                            local inline = library:create("Frame", {
                                Parent = hue_button;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            });	library:apply_theme(inline, "inline", "BackgroundColor3")
                            
                            local hue_drag = library:create("Frame", {
                                Parent = inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            library:create("UIGradient", {
                                Rotation = 270;
                                Parent = hue_drag;
                                Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
                            });
                            
                            local hue_picker = library:create("Frame", {
                                Parent = hue_drag;
                                BorderMode = Enum.BorderMode.Inset;
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, 2, 0, 3);
                                Position = dim2(0, -1, 0, -1);
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                        -- 

                        -- Saturation / Value
                            local saturation_value_button = library:create("TextButton", {
                                Parent = background;
                                AutoButtonColor = false; 
                                Text = "";
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -20, 1, -60);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(saturation_value_button, "outline", "BackgroundColor3")
                            
                            local inline = library:create("Frame", {
                                Parent = saturation_value_button;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            }); library:apply_theme(inline, "inline", "BackgroundColor3")
                            
                            local colorpicker_color = library:create("Frame", {
                                Parent = inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(0, 221, 255)
                            });
                            
                            local val = library:create("Frame", {
                                Parent = colorpicker_color;
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, 0, 1, 0);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            library:create("UIGradient", {
                                Parent = val;
                                Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                            });
                            
                            local saturation_value_picker = library:create("Frame", {
                                Parent = colorpicker_color;
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 3;
                                Size = dim2(0, 3, 0, 3);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(0, 0, 0)
                            });
                            
                            local inline = library:create("Frame", {
                                Parent = saturation_value_picker;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            local saturation_button = library:create("Frame", {
                                Parent = colorpicker_color;
                                Size = dim2(1, 0, 1, 0);
                                BorderColor3 = rgb(0, 0, 0);
                                ZIndex = 2;
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                            
                            library:create("UIGradient", {
                                Rotation = 270;
                                Transparency = numseq{numkey(0, 0), numkey(1, 1)};
                                Parent = saturation_button;
                                Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                            });
                        -- 

                        -- Textbox
                            local textbox = library:create("Frame", {
                                Parent = background;
                                Position = dim2(0, 0, 1, -36);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -1, 0, 20);
                                BorderSizePixel = 0;
                                BackgroundColor3 = rgb(10, 10, 10)
                            }); library:apply_theme(textbox, "outline", "BackgroundColor3");
                            
                            local textbox_inline = library:create("Frame", {
                                Parent = textbox;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.inline
                            }); library:apply_theme(textbox_inline, "inline", "BackgroundColor3");
                            
                            local textbox_background = library:create("Frame", {
                                Parent = textbox_inline;
                                Position = dim2(0, 1, 0, 1);
                                BorderColor3 = rgb(0, 0, 0);
                                Size = dim2(1, -2, 1, -2);
                                BorderSizePixel = 0;
                                BackgroundColor3 = themes.preset.background
                            }); library:apply_theme(textbox_background, "background", "BackgroundColor3")
                            
                            local input = library:create("TextBox", {
                                FontFace = library.font;
                                TextColor3 = rgb(170, 170, 170);
                                BorderColor3 = rgb(0, 0, 0);
                                Text = "";
                                ClearTextOnFocus = false;
                                Parent = textbox_background;
                                BackgroundTransparency = 1;
                                PlaceholderColor3 = rgb(170, 170, 170);
                                Size = dim2(1, 0, 1, 0);
                                BorderSizePixel = 0;
                                TextSize = 12;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                        --
                        
                        local title = library:create("TextLabel", {
                            FontFace = library.font;
                            TextColor3 = themes.preset.text;
                            BorderColor3 = rgb(0, 0, 0);
                            Text = cfg.name;
                            Parent = accent_darker_tint;
                            Size = dim2(1, -8, 0, 0);
                            Position = dim2(0, 4, 0, 4);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.Y;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                    --
                -- 
                
                -- Functions 
                    local dragging_sat = false 
                    local dragging_hue = false 
                    local dragging_alpha = false 

                    local h, s, v = cfg.color:ToHSV() 
                    local a = cfg.alpha 

                    flags[cfg.flag] = {} 

                    function cfg.set_visible(bool) 
                        colorpicker.Visible = bool
                        
                        colorpicker.Position = dim_offset(element.AbsolutePosition.X, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 65)
                    end

                    function cfg.set(color, alpha)
                        if color then 
                            h, s, v = color:ToHSV()
                        end
                        
                        if alpha then 
                            a = alpha
                        end 
                        
                        local Color = Color3.fromHSV(h, s, v)
                        
                        hue_picker.Position = dim2(0, -1, 1 - h, -1)
                        alpha_picker.Position = dim2(1 - a, -1, 0, -1)
                        saturation_value_picker.Position = dim2(s, -1, 1 - v, -1)

                        element_alpha.ImageTransparency = 1 - a

                        alpha_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        color_visualizer.BackgroundColor3 = Color
                        colorpicker_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        
                        flags[cfg.flag] = {
                            Color = Color;
                            Transparency = a 
                        }
                        
                        local color = color_visualizer.BackgroundColor3
                        input.Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
                        input.Text ..= library:round(1 - a, 0.01)
                        
                        cfg.callback(Color, a)
                    end
        
                    function cfg.update_color() 
                        local mouse = uis:GetMouseLocation() 
                        local offset = vec2(mouse.X, mouse.Y - gui_offset) 

                        if dragging_sat then	
                            s = math.clamp((offset - saturation_value_button.AbsolutePosition).X / saturation_value_button.AbsoluteSize.X, 0, 1)
                            v = 1 - math.clamp((offset - saturation_value_button.AbsolutePosition).Y / saturation_value_button.AbsoluteSize.Y, 0, 1)
                        elseif dragging_hue then
                            h = 1 - math.clamp((offset - hue_button.AbsolutePosition).Y / hue_button.AbsoluteSize.Y, 0, 1)
                        elseif dragging_alpha then
                            a = 1 - math.clamp((offset - alpha_button.AbsolutePosition).X / alpha_button.AbsoluteSize.X, 0, 1)
                        end

                        cfg.set(nil, nil)
                    end

                    cfg.set(cfg.color, cfg.alpha)
                    
                    config_flags[cfg.flag] = cfg.set
                -- 
                
                -- Connections 
                    color_visualizer.MouseButton1Click:Connect(function()
                        cfg.open = not cfg.open 

                        cfg.set_visible(cfg.open)            
                    end)

                    uis.InputChanged:Connect(function(input)
                        if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                            cfg.update_color() 
                        end
                    end)

                    uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging_sat = false
                            dragging_hue = false
                            dragging_alpha = false  

                            if not (library:mouse_in_frame(element) or library:mouse_in_frame(colorpicker)) then 
                                cfg.open = false
                                cfg.set_visible(false)
                            end
                        end
                    end)

                    uis.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if not (library:mouse_in_frame(element) or library:mouse_in_frame(colorpicker)) then 
                                cfg.open = false
                                cfg.set_visible(false)
                            end
                        end
                    end)

                    alpha_button.MouseButton1Down:Connect(function()
                        dragging_alpha = true 
                    end)
                    
                    hue_button.MouseButton1Down:Connect(function()
                        dragging_hue = true 
                    end)
                    
                    saturation_value_button.MouseButton1Down:Connect(function()
                        dragging_sat = true  
                    end)

                    input.FocusLost:Connect(function()
                        local text = input.Text
                        local r, g, b, a = library:convert(text)
                        
                        if r and g and b and a then 
                            cfg.set(rgb(r, g, b), 1 - a)
                        end 
                    end)
                -- 

                return setmetatable(cfg, library)
            end 

            function library:textbox(options) 
                local cfg = {
                    name = options.name or "TextBox",
                    placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
                    default = options.default,
                    flag = options.flag or "SET ME NIGGA",
                    callback = options.callback or function() end,
                    visible = options.visible or true,
                }
                
                -- Instances 
                    local textbox = library:create("Frame", {
                        Parent = self.elements;
                        Position = dim2(0, 0, 0, 16);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 20);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(10, 10, 10)
                    });	library:apply_theme(textbox, "outline", "BackgroundColor3")

                    local inline = library:create("Frame", {
                        Parent = textbox;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.inline
                    });	library:apply_theme(inline, "inline", "BackgroundColor3")

                    local background = library:create("Frame", {
                        Parent = inline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.background
                    });	library:apply_theme(background, "background", "BackgroundColor3")

                    local input = library:create("TextBox", {
                        FontFace = library.font;
                        TextColor3 = rgb(170, 170, 170);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        Parent = background;
                        ClearTextOnFocus = false;
                        BackgroundTransparency = 1;
                        PlaceholderColor3 = rgb(170, 170, 170);
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                -- 
                
                -- Functions
                    function cfg.set(text) 
                        flags[cfg.flag] = text

                        input.Text = text

                        cfg.callback(text)
                    end 
                    
                    config_flags[cfg.flag] = cfg.set

                    if cfg.default then 
                        cfg.set(cfg.default) 
                    end
                --

                -- Connections 
                    input:GetPropertyChangedSignal("Text"):Connect(function()
                        cfg.set(input.Text) 
                    end)
                -- 
                
                return setmetatable(cfg, library)
            end 

            function library:keybind(options) 
                local cfg = {
                    flag = options.flag or "SET ME A FLAG NOWWW!!!!",
                    callback = options.callback or function() end,
                    name = options.name or nil, 
                    ignore_key = options.ignore or false, 
    
                    key = options.key or nil, 
                    mode = options.mode or "Toggle",
                    active = options.default or false, 

                    open = false,
                    binding = nil, 

                    hold_instances = {},
                }

                flags[cfg.flag] = {} 

                -- Instances
                    local element = library:create("TextButton", {
                        Parent = self.right_components;
                        Text = "";
                        AutoButtonColor = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 24, 0, 14);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.outline;
                        AutomaticSize = Enum.AutomaticSize.X;
                    });	library:apply_theme(element, "outline", "BackgroundColor3")
                    
                    library:create("UIPadding", {
                        PaddingRight = dim(0, 2);
                        Parent = element;
                    });                    

                    local inline = library:create("Frame", {
                        Parent = element;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.X;
                        BackgroundColor3 = themes.preset.inline;
                    });	library:apply_theme(inline, "inline", "BackgroundColor3")
                    
                    library:create("UIPadding", {
                        PaddingRight = dim(0, 2);
                        Parent = inline;
                    });

                    local background = library:create("Frame", {
                        Parent = inline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.X;
                        BackgroundColor3 = themes.preset.background;
                    });	library:apply_theme(background, "background", "BackgroundColor3")
                    
                    library:create("UIPadding", {
                        PaddingRight = dim(0, 2);
                        Parent = background;
                    });

                    local keybind_text = library:create("TextLabel", {
                        FontFace = library.font;
                        TextColor3 = rgb(255, 255, 255);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "R";
                        Parent = background;
                        AutomaticSize = Enum.AutomaticSize.X;
                        Size = dim2(1, 0, 1, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(0, -1, 0, -1);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });

                    -- Keybind list element 
                        local tab_button_title;
                        if cfg.name then 
                            tab_button_title = library:create("TextLabel", {
                                FontFace = library.font;
                                TextColor3 = rgb(255, 255, 255);
                                BorderColor3 = rgb(0, 0, 0);
                                Text = "Speed:hold";
                                Parent = library.keybind_parent;
                                Size = dim2(1, 0, 0, 0);
                                BackgroundTransparency = 1;
                                TextXAlignment = Enum.TextXAlignment.Left;
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                TextSize = 12;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });
                                
                            local misc = library:create("TextLabel", {
                                FontFace = library.font;
                                TextColor3 = rgb(255, 255, 255);
                                BorderColor3 = rgb(0, 0, 0);
                                Text = "[X]";
                                Name = "key";
                                Parent = tab_button_title;
                                Size = dim2(1, 0, 0, 0);
                                BackgroundTransparency = 1;
                                TextXAlignment = Enum.TextXAlignment.Right;
                                BorderSizePixel = 0;
                                AutomaticSize = Enum.AutomaticSize.Y;
                                TextSize = 12;
                                BackgroundColor3 = rgb(255, 255, 255)
                            });                
                        end 
                    -- 
                -- 

                -- Hold element 
                    local items = library:create("Frame", {
                        Parent = library.gui;
                        Selectable = true;
                        Visible = false;
                        Position = dim2(0, 500, 0, 100);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        BackgroundColor3 = rgb(12, 12, 12)
                    });	
                    
                    local item_holder = library:create("Frame", {
                        Parent = items;
                        Size = dim2(1, -2, 1, -2);
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(56, 56, 56)
                    });	
                    
                    library:create("UIListLayout", {
                        Parent = item_holder;
                        Padding = dim(0, 6);
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                    
                    library:create("UIPadding", {
                        PaddingTop = dim(0, 5);
                        PaddingBottom = dim(0, 2);
                        Parent = item_holder;
                        PaddingRight = dim(0, 6);
                        PaddingLeft = dim(0, 6)
                    });
                    
                    library:create("UIPadding", {
                        PaddingBottom = dim(0, 2);
                        Parent = items
                    });
                    
                    local options = {"Hold", "Toggle", "Always"}
                    
                    for _, v in options do
                        local option = library:create("TextButton", {
                            FontFace = library.font;
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = v;
                            Parent = item_holder;
                            Position = dim2(0, 0, 0, 1);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 12;
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); cfg.hold_instances[v] = option

                        option.MouseButton1Click:Connect(function()
                            cfg.set(v)
                            
                            cfg.set_visible(false)

                            cfg.open = false
                        end)
                    end
                -- 
                
                -- Functions 
                    function cfg.modify_mode_color(path) -- ts so frikin tuff 💀
                        for _, v in item_holder:GetChildren() do 
                            if v:IsA("TextButton") then 
                                v.TextColor3 = themes.preset.text
                            end 
                        end

                        cfg.hold_instances[path].TextColor3 = themes.preset.accent
                    end 

                    function cfg.set_mode(mode) 
                        cfg.mode = mode 

                        if mode == "Always" then
                            cfg.set(true)
                        elseif mode == "Hold" then
                            cfg.set(false)
                        end

                        flags[cfg.flag]["mode"] = mode
                        cfg.modify_mode_color(mode)
                    end 

                    function cfg.set(input)
                        if type(input) == "boolean" then 
                            cfg.active = input

                            if cfg.mode == "Always" then 
                                cfg.active = true
                            end
                        elseif tostring(input):find("Enum") then 
                            input = input.Name == "Escape" and "NONE" or input
                            
                            cfg.key = input or "NONE"	
                        elseif find({"Toggle", "Hold", "Always"}, input) then 
                            if input == "Always" then 
                                cfg.active = true 
                            end 

                            cfg.set_mode(input) 
                        elseif type(input) == "table" then 
                            input.key = type(input.key) == "string" and input.key ~= "NONE" and library:convert_enum(input.key) or input.key
                            input.key = input.key == Enum.KeyCode.Escape and "NONE" or input.key
                            
                            cfg.key = input.key or "NONE"
                            cfg.mode = input.mode or "Toggle"

                            if input.active then
                                cfg.active = input.active
                            end

                            cfg.set_mode(cfg.mode) 
                        end 

                        cfg.callback(cfg.active)

                        local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                        local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
                        
                        keybind_text.Text = __text

                        -- Keybind 
                            if cfg.name then 
                                tab_button_title.Visible = cfg.active 
                                tab_button_title.Text = cfg.name .. ":" .. cfg.mode
                                tab_button_title.key.Text = "[" .. __text .. "]"
                            end 
                        -- 

                        flags[cfg.flag] = {
                            mode = cfg.mode,
                            key = cfg.key, 
                            active = cfg.active
                        }
                    end

                    function cfg.set_visible(bool)
                        items.Visible = bool
                        
                        items.Position = dim_offset(element.AbsolutePosition.X, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 60)
                    end
                -- 
                
                -- Connections 
                    element.MouseButton1Down:Connect(function()
                        task.wait()
                        element.Text = "..."	

                        cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)  
                            cfg.set(keycode.KeyCode ~= Enum.KeyCode.Unknown and keycode.KeyCode or keycode.UserInputType)
                            
                            cfg.binding:Disconnect() 
                            cfg.binding = nil
                        end)
                    end)

                    element.MouseButton2Down:Connect(function()
                        cfg.open = not cfg.open 

                        cfg.set_visible(cfg.open)
                    end)

                    library:connection(uis.InputBegan, function(input, game_event) 
                        if not game_event then 
                            if input.KeyCode == cfg.key then 
                                if cfg.mode == "Toggle" then 
                                    cfg.active = not cfg.active
                                    cfg.set(cfg.active)
                                elseif cfg.mode == "Hold" then 
                                    cfg.set(true)
                                end
                            end
                        end

                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if not (library:mouse_in_frame(element) or library:mouse_in_frame(item_holder)) then 
                                cfg.open = false
                                cfg.set_visible(false)
                            end
                        end
                    end)

                    library:connection(uis.InputEnded, function(input, game_event) 
                        if game_event then 
                            return 
                        end 

                        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
            
                        if selected_key == cfg.key then
                            if cfg.mode == "Hold" then 
                                cfg.set(false)
                            end
                        end
                    end)
            
                    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
                --
                
                config_flags[cfg.flag] = cfg.set

                return setmetatable(cfg, library)
            end

            function library:button(options) 
                local cfg = {
                    name = options.name or "TextBox",
                    callback = options.callback or function() end,
                }
                
                -- Instances 
                    local button = library:create("TextButton", {
                        Parent = self.elements;
                        Text = "";
                        Position = dim2(0, 0, 0, 16);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 20);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(10, 10, 10)
                    });	library:apply_theme(button, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = button;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.inline
                    });	library:apply_theme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline;
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.background
                    });	library:apply_theme(background, "background", "BackgroundColor3")
                    
                    local text = library:create("TextButton", {
                        FontFace = library.font;
                        TextColor3 = rgb(170, 170, 170);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.name;
                        Parent = background;
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                -- 

                -- Connections 
                    text.MouseButton1Click:Connect(function()
                        cfg.callback()
                    end)
                --
                
                return setmetatable(cfg, library)
            end 
        -- 
    -- 
-- 

-- documentation 
local window = library:window({
    name = "                                 dracula.lol [beta]",
})

local a = library:target_indicator()
a:label({name = "Name: beta (test)"})
a:label({name = "test", value = "500"})
local slider = a:slider({name = "Health"})
local sliderr = a:slider({name = "Armor"})
local toggle = a:toggle({name = "Knocked"})

-- AIMBOT TAB
local aimbot = window:tab({name = "Aimbot"})

-- Aimbot Section
local aimbot_section = aimbot:section({name = "Aimbot"})
local aimbot_toggle = aimbot_section:toggle({name = "Enable Aimbot", flag = "aimbot_enabled", callback = function(bool)
    print("Aimbot enabled:", bool)
end})

aimbot_section:dropdown({name = "Target Type", flag = "aimbot_target_type", items = {"Head", "Torso", "Feet", "Random"}, default = "Head"})
aimbot_section:slider({name = "FOV", min = 1, max = 1000, default = 100, interval = 1, suffix = "px", flag = "aimbot_fov"})
aimbot_section:slider({name = "Lock Time", min = 0, max = 10, default = 2, interval = 0.1, suffix = "s", flag = "aimbot_lock_time"})
aimbot_section:colorpicker({name = "Target Reticle Color", color = Color3.fromRGB(255, 0, 0), flag = "aimbot_reticle_color"})

-- Silent Aim Section
local silent_aim_section = aimbot:section({name = "Silent Aim"})
local silent_aim_toggle = silent_aim_section:toggle({name = "Enable Silent Aim", flag = "silent_aim_enabled"})
silent_aim_section:slider({name = "Accuracy", min = 0, max = 100, default = 80, interval = 1, suffix = "%", flag = "silent_aim_accuracy"})
silent_aim_section:slider({name = "Lock Speed", min = 0, max = 10, default = 2, interval = 0.1, suffix = "s", flag = "silent_aim_lock_speed"})

-- Aimbot Smoothness Section
local smoothness_section = aimbot:section({name = "Aimbot Smoothness", side = "right"})
smoothness_section:slider({name = "Smoothness", min = 1, max = 100, default = 20, interval = 1, suffix = "%", flag = "aimbot_smoothness"})
smoothness_section:colorpicker({name = "Smoothness Reticle Color", color = Color3.fromRGB(0, 255, 0), flag = "smoothness_reticle_color"})

-- Auto Fire Section
local auto_fire_section = aimbot:section({name = "Auto Fire", side = "right"})
auto_fire_section:toggle({name = "Enable Auto Fire", flag = "auto_fire_enabled"})

-- Triggerbot Section
local triggerbot_section = aimbot:section({name = "Triggerbot", side = "right"})
local triggerbot_toggle = triggerbot_section:toggle({name = "Enable Triggerbot", flag = "triggerbot_enabled"})
triggerbot_section:slider({name = "Trigger Delay", min = 0, max = 1000, default = 100, interval = 10, suffix = "ms", flag = "triggerbot_delay"})
triggerbot_section:slider({name = "Trigger Distance", min = 0, max = 1000, default = 100, interval = 10, suffix = "studs", flag = "triggerbot_distance"})

-- Advanced Aim Settings
local advanced_aim_section = aimbot:section({name = "Advanced Settings", side = "right"})
advanced_aim_section:slider({name = "Aim Speed", min = 1, max = 100, default = 50, interval = 1, suffix = "%", flag = "aim_speed"})
advanced_aim_section:slider({name = "Maximum Distance", min = 10, max = 10000, default = 1000, interval = 10, suffix = "studs", flag = "aimbot_max_distance"})

-- VISUALS TAB
local visuals = window:tab({name = "Visuals"})

-- Box ESP Section
local box_esp_section = visuals:section({name = "Box ESP"})
local box_esp_toggle = box_esp_section:toggle({name = "Enable Box ESP", flag = "box_esp_enabled"})
box_esp_section:dropdown({name = "Box Style", flag = "box_style", items = {"2D", "Full 3D", "Skeleton Box"}, default = "2D"})
box_esp_section:slider({name = "Box Thickness", min = 1, max = 10, default = 2, interval = 0.1, suffix = "px", flag = "box_thickness"})
box_esp_section:colorpicker({name = "Box Color", color = Color3.fromRGB(255, 255, 255), flag = "box_color"})

-- Health Bar ESP Section
local health_bar_section = visuals:section({name = "Health Bar ESP"})
local health_bar_toggle = health_bar_section:toggle({name = "Enable Health Bar ESP", flag = "health_bar_enabled"})
health_bar_section:slider({name = "Health Bar Thickness", min = 1, max = 10, default = 2, interval = 0.1, suffix = "px", flag = "health_bar_thickness"})
health_bar_section:slider({name = "Health Bar Width", min = 1, max = 10, default = 3, interval = 0.1, suffix = "px", flag = "health_bar_width"})
health_bar_section:colorpicker({name = "Health Gradient Color", color = Color3.fromRGB(0, 255, 0), flag = "health_bar_color"})

-- Armor Bar ESP Section
local armor_bar_section = visuals:section({name = "Armor Bar ESP"})
local armor_bar_toggle = armor_bar_section:toggle({name = "Enable Armor Bar ESP", flag = "armor_bar_enabled"})
armor_bar_section:slider({name = "Armor Bar Thickness", min = 1, max = 10, default = 2, interval = 0.1, suffix = "px", flag = "armor_bar_thickness"})
armor_bar_section:colorpicker({name = "Armor Bar Color", color = Color3.fromRGB(0, 0, 255), flag = "armor_bar_color"})

-- Skeleton ESP Section
local skeleton_esp_section = visuals:section({name = "Skeleton ESP", side = "right"})
local skeleton_esp_toggle = skeleton_esp_section:toggle({name = "Enable Skeleton ESP", flag = "skeleton_esp_enabled"})
skeleton_esp_section:slider({name = "Line Thickness", min = 0.1, max = 5, default = 1, interval = 0.1, suffix = "px", flag = "skeleton_thickness"})
skeleton_esp_section:colorpicker({name = "Skeleton Line Color", color = Color3.fromRGB(255, 255, 255), flag = "skeleton_color"})
skeleton_esp_section:dropdown({name = "Bones to Display", flag = "bones_display", items = {"All", "Head", "Torso", "Arms", "Legs"}, default = "All"})

-- Name ESP Section
local name_esp_section = visuals:section({name = "Name ESP", side = "right"})
local name_esp_toggle = name_esp_section:toggle({name = "Enable Name ESP", flag = "name_esp_enabled"})
name_esp_section:slider({name = "Font Size", min = 8, max = 24, default = 12, interval = 1, suffix = "px", flag = "name_font_size"})
name_esp_section:dropdown({name = "Font Type", flag = "name_font_type", items = {"Default", "Monospace", "Bold", "Italic"}, default = "Default"})
name_esp_section:colorpicker({name = "Name Color", color = Color3.fromRGB(255, 255, 255), flag = "name_color"})

-- Distance ESP Section
local distance_esp_section = visuals:section({name = "Distance ESP", side = "right"})
local distance_esp_toggle = distance_esp_section:toggle({name = "Enable Distance ESP", flag = "distance_esp_enabled"})
distance_esp_section:slider({name = "Distance Limit", min = 10, max = 10000, default = 1000, interval = 10, suffix = "studs", flag = "distance_limit"})
distance_esp_section:colorpicker({name = "Distance Text Color", color = Color3.fromRGB(255, 255, 255), flag = "distance_text_color"})

-- Player Filtering Section
local player_filtering_section = visuals:section({name = "Player Filtering", side = "right"})
player_filtering_section:dropdown({name = "Show ESP For", flag = "esp_filter", items = {"All", "Teammates", "Enemies", "NPCs"}, default = "All"})
player_filtering_section:slider({name = "Maximum Visible Range", min = 10, max = 10000, default = 1000, interval = 10, suffix = "studs", flag = "esp_max_range"})

-- RAGE TAB
local rage = window:tab({name = "Rage"})

-- No Recoil Section
local no_recoil_section = rage:section({name = "No Recoil"})
local no_recoil_toggle = no_recoil_section:toggle({name = "Enable No Recoil", flag = "no_recoil_enabled"})
no_recoil_section:slider({name = "Recoil Reduction", min = 0, max = 100, default = 100, interval = 1, suffix = "%", flag = "recoil_reduction"})

-- No Spread Section
local no_spread_section = rage:section({name = "No Spread"})
local no_spread_toggle = no_spread_section:toggle({name = "Enable No Spread", flag = "no_spread_enabled"})
no_spread_section:slider({name = "Spread Reduction", min = 0, max = 100, default = 100, interval = 1, suffix = "%", flag = "spread_reduction"})

-- Rapid Fire Section
local rapid_fire_section = rage:section({name = "Rapid Fire"})
local rapid_fire_toggle = rapid_fire_section:toggle({name = "Enable Rapid Fire", flag = "rapid_fire_enabled"})
rapid_fire_section:slider({name = "Fire Rate Speed", min = 100, max = 1000, default = 500, interval = 10, suffix = "%", flag = "fire_rate_speed"})

-- Wallbang Section
local wallbang_section = rage:section({name = "Wallbang", side = "right"})
local wallbang_toggle = wallbang_section:toggle({name = "Enable Wallbang", flag = "wallbang_enabled"})
wallbang_section:slider({name = "Wall Penetration Distance", min = 1, max = 100, default = 10, interval = 1, suffix = "studs", flag = "wall_penetration"})

-- Instant Hit Section
local instant_hit_section = rage:section({name = "Instant Hit", side = "right"})
local instant_hit_toggle = instant_hit_section:toggle({name = "Enable Instant Hit", flag = "instant_hit_enabled"})
instant_hit_section:slider({name = "Instant Hit Time", min = 0, max = 1000, default = 0, interval = 10, suffix = "ms", flag = "instant_hit_time"})

-- Hit Scan Section
local hit_scan_section = rage:section({name = "Hit Scan", side = "right"})
hit_scan_section:toggle({name = "Enable Hit Scan", flag = "hit_scan_enabled"})

-- Fake Lag Section
local fake_lag_section = rage:section({name = "Fake Lag", side = "right"})
local fake_lag_toggle = fake_lag_section:toggle({name = "Enable Fake Lag", flag = "fake_lag_enabled"})
fake_lag_section:slider({name = "Fake Lag Intensity", min = 0, max = 1000, default = 200, interval = 10, suffix = "ms", flag = "fake_lag_intensity"})

-- Anti Aim Section
local anti_aim_section = rage:section({name = "Anti Aim", side = "right"})
local anti_aim_toggle = anti_aim_section:toggle({name = "Enable Anti Aim", flag = "anti_aim_enabled"})
anti_aim_section:slider({name = "Anti Aim Angle", min = 0, max = 360, default = 180, interval = 1, suffix = "°", flag = "anti_aim_angle"})

-- MISCELLANEOUS TAB
local misc = window:tab({name = "Miscellaneous"})

-- Visual Enhancements Section
local visual_enhancements_section = misc:section({name = "Visual Enhancements"})
visual_enhancements_section:toggle({name = "No Fog", flag = "no_fog_enabled"})
visual_enhancements_section:toggle({name = "No Flashbang", flag = "no_flashbang_enabled"})

-- Weapon Enhancements Section
local weapon_enhancements_section = misc:section({name = "Weapon Enhancements"})
weapon_enhancements_section:toggle({name = "Auto Reload", flag = "auto_reload_enabled"})
local fast_reload_toggle = weapon_enhancements_section:toggle({name = "Fast Reload", flag = "fast_reload_enabled"})
weapon_enhancements_section:slider({name = "Reload Speed Multiplier", min = 1, max = 10, default = 2, interval = 0.1, suffix = "x", flag = "reload_speed_multiplier"})

-- Utility Section
local utility_section = misc:section({name = "Utility", side = "right"})
utility_section:toggle({name = "Anti-Chat Filter", flag = "anti_chat_filter_enabled"})
utility_section:button({name = "Teleport to Player", callback = function()
    print("Teleport to player functionality would go here")
end})

-- SETTINGS TAB
local settings = window:tab({name = "Settings"})

-- Configs Section
local configs_section = settings:section({name = "Configs", side = "left"})
config_holder = configs_section:dropdown({name = "Configs", flag = "config_name_list"}) 
library:update_config_list() 
configs_section:textbox({name = "Config name", flag = "config_name_text_box"})

configs_section:button({name = "Create", callback = function()
    if flags["config_name_text_box"] == "" then 
        return 
    end 

    writefile(library.directory .. "/configs/" .. flags["config_name_text_box"] .. ".cfg", library:get_config())

    library:update_config_list()
end})

configs_section:button({name = "Delete", callback = function()
    delfile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg")
    library:update_config_list()
end})

configs_section:button({name = "Load", callback = function()
    library:load_config(readfile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg"))
end})

configs_section:button({name = "Save", callback = function()
    writefile(library.directory .. "/configs/" .. flags["config_name_list"] .. ".cfg", library:get_config())
    library:update_config_list()
end})

configs_section:button({name = "Refresh configs", callback = function()
    library:update_config_list()
end})

local old_config;

configs_section:button({name = "Unload Config", callback = function()
    library:load_config(old_config)
end})

configs_section:button({name = "Unload Menu", callback = function()
    library:unload_menu()
end})

-- Theme Section
local theme_section = settings:section({name = "Theme", side = "right"})
theme_section:colorpicker({name = "Accent", color = themes.preset.accent, flag = "accent", callback = function(color, alpha)
    library:update_theme("accent", color)
end})
theme_section:colorpicker({name = "Background", color = themes.preset.background, flag = "background", callback = function(color)
    library:update_theme("background", color)
end})
theme_section:colorpicker({name = "Inline", color = themes.preset.inline, callback = function(color, alpha)
    library:update_theme("inline", color)
end})
theme_section:colorpicker({name = "Outline", color = themes.preset.outline, callback = function(color, alpha)
    library:update_theme("outline", color)
end})
theme_section:colorpicker({name = "Text", color = themes.preset.text, callback = function(color, alpha)
    library:update_theme("text", color)
end})
theme_section:colorpicker({name = "Text Outline", color = themes.preset.text_outline, callback = function(color, alpha)
    library:update_theme("text_outline", color)
end})
theme_section:colorpicker({name = "Glow", color = themes.preset.glow, callback = function(color, alpha)
    library:update_theme("glow", color)
end})

-- UI Settings Section
local ui_settings_section = settings:section({name = "UI Settings", side = "right"})
ui_settings_section:toggle({name = "Keybind list", flag = "keybind_list", callback = function(bool)
    library.keybind_list.Visible = bool 
end})
ui_settings_section:toggle({name = "Target Indicator", flag = "target_indicator", callback = function(bool)
    library.target_indicator.Visible = bool 
end})
ui_settings_section:label({name = "UI bind"}):keybind({key = Enum.KeyCode.Insert, default = true, flag = "UI_Bind", callback = function(bool)
    library.gui.Enabled = bool 
end})

old_config = library:get_config()
-- 
