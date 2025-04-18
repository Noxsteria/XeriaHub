local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- Set theme:
-- WindUI:SetTheme("Dark")

--- EXAMPLE !!!

function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end

    return result
end

local Confirmed = false

WindUI:Popup({
    Title = "Welcome!",
    Icon = "info",
    Content = "This is an Example UI for the " .. gradient("Xeria Hub", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")) .. " By Night",
    Buttons = {
        {
            Title = "Cancel",
            --Icon = "",
            Callback = function() end,
            Variant = "Tertiary", -- Primary, Secondary, Tertiary
        },
        {
            Title = "Continue",
            Icon = "arrow-right",
            Callback = function() Confirmed = true end,
            Variant = "Primary", -- Primary, Secondary, Tertiary
        }
    }
})


repeat wait() until Confirmed

--

local Window = WindUI:CreateWindow({
    Title = "Xeria Hub",
    Icon = "sprout",
    Author = "Night",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = false,
    SideBarWidth = 200,
    --Background = "rbxassetid://13511292247", -- rbxassetid only
    HasOutline = true,
    -- remove it below if you don't want to use the key system in your script.
    KeySystem = { 
        Key = { "1234", "5678" },
        Note = "Example Key System. \n\nThe Key is '1234' or '5678",
        -- Thumbnail = {
        --     Image = "rbxassetid://18220445082", -- rbxassetid only
        --     Title = "Thumbnail"
        -- },
        URL = "https://github.com/Footagesus/WindUI", -- remove this if the key is not obtained from the link.
        SaveKey = true, -- optional
    },
})


--Window:SetBackgroundImage("rbxassetid://13511292247")


Window:EditOpenButton({
    Title = "Open Example UI",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    --Enabled = false,
    Draggable = true,
})


local Tabs = {
    ToggleTab = Window:Tab({ Title = "Toggle", Icon = "toggle-left", Desc = "Switch settings on and off." }),
    SettingTab = Window:Tab({ Title = "Settings", Icon = "settings", Desc = "Configuration." }),
    b = Window:Divider(),
    WindowTab = Window:Tab({ Title = "Window and File Configuration", Icon = "settings", Desc = "Manage window settings and file configurations." }),
    CreateThemeTab = Window:Tab({ Title = "Create Theme", Icon = "palette", Desc = "Design and apply custom themes." }),
}

Window:SelectTab(1)

local autoUpgrade = false

Tabs.ToggleTab:Toggle({
    Title = "Auto Upgrade All Units",
    Desc = "Automatically Upgrade All Units For You",
    Default = false,
    Callback = function(state)
        autoUpgrade = state
        if autoUpgrade then
            task.spawn(function()
                while autoUpgrade do
                    local unitsFolder = game:GetService("Players").LocalPlayer:WaitForChild("UnitsFolder")
                    for _, unit in ipairs(unitsFolder:GetChildren()) do
                        pcall(function()
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Remote")
                                :WaitForChild("Server")
                                :WaitForChild("Units")
                                :WaitForChild("Upgrade")
                                :FireServer(unit)
                        end)
                    end
                    task.wait(1) -- adjust delay if needed
                end
            end)
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isAutoVoting = false -- Tracks if the toggle is ON
local voteRemotePath = {
    "Remote",
    "Server",
    "OnGame",
    "Voting",
    "VotePlaying"
}

local function getVoteRemote()
    local current = ReplicatedStorage
    for i, childName in ipairs(voteRemotePath) do
        current = current:WaitForChild(childName, 5) -- Wait up to 5 secs per step
        if not current then
            warn("AutoVoteToggle: Could not find RemoteEvent path component:", childName)
            return nil
        end
    end
    if current:IsA("RemoteEvent") then
        return current
    else
        warn("AutoVoteToggle: Expected RemoteEvent, found:", current.ClassName)
        return nil
    end
end

Tabs.ToggleTab:Toggle({
    Title = "Auto Vote Start",
    Desc = "Automatically votes to start the game periodically.", -- Optional description
    Default = false, -- Start disabled
    Callback = function(state) -- Function runs when toggle is clicked. 'state' is true/false.
        isAutoVoting = state -- Update our control variable

        if isAutoVoting then
            
            -- Start the loop in a new thread ONLY if enabled
            task.spawn(function()
                local voteRemote = getVoteRemote() -- Try to get the remote event
                if not voteRemote then
                    
                    isAutoVoting = false
                    -- Maybe add code here to visually turn the toggle back OFF if the lib supports it
                    -- e.g., toggleElement:SetValue(false) -- Need reference to the toggle object itself
                    return -- Stop this new thread
                end

                
                -- Keep looping as long as the toggle state is true
                while isAutoVoting do
                    
                    local success, err = pcall(function()
                        voteRemote:FireServer() -- Fire the actual event
                    end)

                    if not success then
                        warn("Auto Vote Toggle: Error firing remote -", err)
                        -- Optional: Stop the loop on error?
                        -- isAutoVoting = false
                        -- break
                    end

                    -- IMPORTANT: Wait before firing again
                    task.wait(3) -- Wait 3 seconds (Adjust delay as needed)
                end
                -- Loop exits naturally when isAutoVoting becomes false
                
            end)
        else
            -- If the toggle was turned OFF
            
            -- The loop running in the task.spawn will stop on its next check
        end
    end
})

local isAutoVotingNext = false -- Tracks if this specific toggle is ON
local voteNextRemotePath = {
    "Remote",
    "Server",
    "OnGame",
    "Voting",
    "VoteNext" -- The specific remote for voting next
}
local function getVoteNextRemote()
    local current = ReplicatedStorage
    for i, childName in ipairs(voteNextRemotePath) do
        current = current:WaitForChild(childName, 5) -- Wait up to 5 secs per step
        if not current then
            warn("AutoVoteNextToggle: Could not find RemoteEvent path component:", childName)
            return nil
        end
    end
    if current:IsA("RemoteEvent") then
        return current
    else
        warn("AutoVoteNextToggle: Expected RemoteEvent, found:", current.ClassName)
        return nil
    end
end

Tabs.ToggleTab:Toggle({
    Title = "Auto Vote Next",
    Desc = "Automatically votes for the next stage periodically.", -- Optional description
    Default = false, -- Start disabled
    Callback = function(state) -- Function runs when toggle is clicked. 'state' is true/false.
        isAutoVotingNext = state -- Update our control variable for this toggle

        if isAutoVotingNext then
            
            -- Start the loop in a new thread ONLY if enabled
            task.spawn(function()
                local voteNextRemote = getVoteNextRemote() -- Try to get the remote event
                if not voteNextRemote then
                    
                    isAutoVotingNext = false
                    -- Maybe add code here to visually turn the toggle back OFF if the lib supports it
                    return -- Stop this new thread
                end

                
                -- Keep looping as long as the toggle state is true
                while isAutoVotingNext do
                    
                    local success, err = pcall(function()
                        voteNextRemote:FireServer() -- Fire the actual VoteNext event
                    end)

                    if not success then
                        
                        -- Optional: Stop the loop on error?
                        -- isAutoVotingNext = false
                        -- break
                    end

                    -- IMPORTANT: Wait before firing again
                    task.wait(3) -- Wait 3 seconds (Adjust delay as needed, maybe match Auto Vote Start?)
                end
                -- Loop exits naturally when isAutoVotingNext becomes false
                
            end)
        else
            -- If the toggle was turned OFF
            
            -- The loop running in the task.spawn will stop on its next check
        end
    end
})

local isAutoReplaying = false -- Tracks if this specific toggle is ON
local voteRetryRemotePath = {
    "Remote",
    "Server",
    "OnGame",
    "Voting",
    "VoteRetry" -- The specific remote for voting retry
}

local function getVoteRetryRemote()
    local current = ReplicatedStorage
    for i, childName in ipairs(voteRetryRemotePath) do
        -- Use WaitForChild with a reasonable timeout
        current = current:WaitForChild(childName, 7) -- Wait up to 7 seconds per step
        if not current then
            -- warn("AutoReplayToggle: Could not find RemoteEvent path component:", childName) -- Removed for silence
            return nil
        end
    end
    if current:IsA("RemoteEvent") then
        return current
    else
        -- warn("AutoReplayToggle: Expected RemoteEvent, found:", current.ClassName) -- Removed for silence
        return nil
    end
end

Tabs.ToggleTab:Toggle({
    Title = "Auto Replay", -- Changed back from "Silent" as warnings are removed
    Desc = "Automatically votes to replay the game.",
    Default = false, -- Start disabled
    Callback = function(state) -- Function runs when toggle is clicked. 'state' is true/false.
        isAutoReplaying = state -- Update our control variable for this toggle

        if isAutoReplaying then
            -- Start the loop in a new thread ONLY if enabled
            -- Note: This doesn't prevent multiple loops if toggled quickly, unlike the thread variable approach.
            -- Following the user's example structure.
            task.spawn(function()
                local voteRetryRemote = getVoteRetryRemote() -- Try to get the specific remote event

                if not voteRetryRemote then
                    -- Silently fail if remote not found
                    isAutoReplaying = false
                    -- Maybe add code here to visually turn the toggle back OFF if the lib supports it
                    return -- Stop this new thread
                end

                -- Keep looping as long as the toggle state is true
                while isAutoReplaying do
                    -- Use pcall to silently attempt firing the event
                    local success, err = pcall(function()
                        voteRetryRemote:FireServer() -- Fire the actual VoteRetry event
                    end)

                    -- No error handling needed for silent operation

                    -- IMPORTANT: Wait before firing again
                    task.wait(2.5) -- Wait 2.5 seconds (Adjust delay as needed)
                end
                -- Loop exits naturally when isAutoReplaying becomes false

            end)
        else
            -- If the toggle was turned OFF
            -- The loop running in the task.spawn will stop on its next check
            -- because 'isAutoReplaying' is now false.
        end
    end
})

-- Configuration

local autoDeleteScreenReward = false
local deleteLoop


local function deleteRewardScreens()
    task.wait(0.2)
    local player = game:GetService("Players").LocalPlayer
    local gui = player.PlayerGui:FindFirstChild("GameEndedAnimationUI")
    local rewardscreen = player.PlayerGui:FindFirstChild("RewardsUI")

    if gui then
        gui:Destroy()
    end
    if rewardscreen then
        rewardscreen:Destroy()
    end
end

Tabs.SettingTab:Toggle({
    Title = "Delete Reward Screen",
    Desc = "Automatically Delete Screen Reward",
    Default = false,
    Callback = function(state)
        autoDeleteScreenReward = state

        if autoDeleteScreenReward then
            print("Auto Delete Screen Reward Enabled")
            -- Start loop
            deleteLoop = task.spawn(function()
                while autoDeleteScreenReward do
                    deleteRewardScreens()
                    task.wait(1) -- check every 1 second
                end
            end)
        else
            print("Auto Delete Screen Reward Disabled")
            -- Stop loop
            autoDeleteScreenReward = false
        end
    end
})

Tabs.SettingTab:Button({
    Title = "Reduce Lag",
    Desc = "Reduce Lag By RIP#6666",
    Callback = function()
        _G.Settings = {
            Players = {
                ["Ignore Me"] = true, -- Ignore your Character
                ["Ignore Others"] = true -- Ignore other Characters
            },
            Meshes = {
                Destroy = false, -- Destroy Meshes
                LowDetail = true -- Low detail meshes (NOT SURE IT DOES ANYTHING)
            },
            Images = {
                Invisible = true, -- Invisible Images
                LowDetail = false, -- Low detail images (NOT SURE IT DOES ANYTHING)
                Destroy = false, -- Destroy Images
            },
            ["No Particles"] = true, -- Disables all ParticleEmitter, Trail, Smoke, Fire and Sparkles
            ["No Camera Effects"] = true, -- Disables all PostEffect's (Camera/Lighting Effects)
            ["No Explosions"] = true, -- Makes Explosion's invisible
            ["No Clothes"] = true, -- Removes Clothing from the game
            ["Low Water Graphics"] = true, -- Removes Water Quality
            ["No Shadows"] = true, -- Remove Shadows
            ["Low Rendering"] = true, -- Lower Rendering
            ["Low Quality Parts"] = true -- Lower quality parts
        }
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
    end})

-- Optional


local HttpService = game:GetService("HttpService")

local folderPath = "WindUI"
makefolder(folderPath)

local function SaveFile(fileName, data)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    local jsonData = HttpService:JSONEncode(data)
    writefile(filePath, jsonData)
end

local function LoadFile(fileName)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    if isfile(filePath) then
        local jsonData = readfile(filePath)
        return HttpService:JSONDecode(jsonData)
    end
end

local function ListFiles()
    local files = {}
    for _, file in ipairs(listfiles(folderPath)) do
        local fileName = file:match("([^/]+)%.json$")
        if fileName then
            table.insert(files, fileName)
        end
    end
    return files
end

Tabs.WindowTab:Section({ Title = "Window" })

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = Tabs.WindowTab:Dropdown({
    Title = "Select Theme",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select(WindUI:GetCurrentTheme())

local ToggleTransparency = Tabs.WindowTab:Toggle({
    Title = "Toggle Window Transparency",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

Tabs.WindowTab:Section({ Title = "Save" })

local fileNameInput = ""
Tabs.WindowTab:Input({
    Title = "Write File Name",
    PlaceholderText = "Enter file name",
    Callback = function(text)
        fileNameInput = text
    end
})

Tabs.WindowTab:Button({
    Title = "Save File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.WindowTab:Section({ Title = "Load" })

local filesDropdown
local files = ListFiles()

filesDropdown = Tabs.WindowTab:Dropdown({
    Title = "Select File",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

Tabs.WindowTab:Button({
    Title = "Load File",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "File Loaded",
                    Content = "Loaded data: " .. HttpService:JSONEncode(data),
                    Duration = 5,
                })
                if data.Transparent then 
                    Window:ToggleTransparency(data.Transparent)
                    ToggleTransparency:SetValue(data.Transparent)
                end
                if data.Theme then WindUI:SetTheme(data.Theme) end
            end
        end
    end
})

Tabs.WindowTab:Button({
    Title = "Overwrite File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.WindowTab:Button({
    Title = "Refresh List",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})

local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].PlaceholderText

function updateTheme()
    WindUI:AddTheme({
        Name = currentThemeName,
        Accent = ThemeAccent,
        Outline = ThemeOutline,
        Text = ThemeText,
        PlaceholderText = ThemePlaceholderText
    })
    WindUI:SetTheme(currentThemeName)
end

local CreateInput = Tabs.CreateThemeTab:Input({
    Title = "Theme Name",
    Value = currentThemeName,
    Callback = function(name)
        currentThemeName = name
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "Background Color",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "Outline Color",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "Text Color",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "Placeholder Text Color",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
    end
})

Tabs.CreateThemeTab:Button({
    Title = "Update Theme",
    Callback = function()
        updateTheme()
    end
})