-- ================================================================
--  LOADSTRING FINAL - NEXZAN KEY SYSTEM
--  Lengkap dalam satu file untuk loadstring
-- ================================================================

-- Kode ini sudah lengkap dan siap pakai
-- Copy seluruh isi file ini dan paste ke executor
-- Atau pakai: loadstring(game:HttpGet("URL_RAW_FILE"))()

local KeyUI = {}
KeyUI.__index = KeyUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

local function CopyToClipboard(text)
    local ok = false
    pcall(function()
        if setclipboard then setclipboard(text); ok = true
        elseif toclipboard then toclipboard(text); ok = true
        elseif set_clipboard then set_clipboard(text); ok = true
        elseif clipboard and clipboard.set then clipboard.set(text); ok = true
        elseif writeclipboard then writeclipboard(text); ok = true
        end
    end)
    return ok
end

local function ShowToast(parent, title, msg, duration, color)
    duration = duration or 2.5; color = color or Color3.fromRGB(139, 92, 246)
    local toast = Instance.new("Frame")
    toast.Name = "NexzanToast"; toast.Size = UDim2.fromOffset(0, 36); toast.Position = UDim2.new(0.5, 0, 0, 10)
    toast.AnchorPoint = Vector2.new(0.5, 0); toast.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    toast.BackgroundTransparency = 0.08; toast.BorderSizePixel = 0; toast.ClipsDescendants = true; toast.ZIndex = 999
    toast.Parent = parent
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", toast); stroke.Color = color; stroke.Thickness = 1.2; stroke.Transparency = 0.4
    local pad = Instance.new("UIPadding", toast); pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6)
    local layout = Instance.new("UIListLayout", toast)
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.VerticalAlignment = Enum.VerticalAlignment.Center; layout.Padding = UDim.new(0, 6)
    local dot = Instance.new("Frame", toast); dot.Size = UDim2.fromOffset(5, 5); dot.BackgroundColor3 = color
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local textFrame = Instance.new("Frame", toast); textFrame.Size = UDim2.new(1, -20, 1, 0); textFrame.BackgroundTransparency = 1
    local tl = Instance.new("TextLabel", textFrame); tl.Size = UDim2.new(1, 0, 0, 14)
    tl.BackgroundTransparency = 1; tl.Text = title; tl.TextColor3 = Color3.fromRGB(240, 240, 245)
    tl.Font = Enum.Font.GothamBold; tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left
    local ml = Instance.new("TextLabel", textFrame); ml.Size = UDim2.new(1, 0, 0, 12); ml.Position = UDim2.new(0, 0, 0, 14)
    ml.BackgroundTransparency = 1; ml.Text = msg; ml.TextColor3 = Color3.fromRGB(170, 170, 185)
    ml.Font = Enum.Font.Gotham; ml.TextSize = 9; ml.TextXAlignment = Enum.TextXAlignment.Left
    toast.AutomaticSize = Enum.AutomaticSize.X
    TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.08 }):Play()
    task.wait(duration)
    local out = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, -10) })
    out:Play(); out.Completed:Wait(); toast:Destroy()
end

function KeyUI:Create(cfg)
    cfg = cfg or {}
    local Title = cfg.Title or "KEY SYSTEM"
    local SubTitle = cfg.SubTitle or "Verifikasi akses premium"
    local Mode = cfg.Mode or "Single"
    local Keys = cfg.Keys or cfg.Key or {"NEXZAN-HUB", "PREMIUM-2024"}
    local URL = cfg.URL or cfg.Link or cfg.GetKeyLink or "https://discord.gg/nexzanhub"
    local URLs = cfg.URLs or cfg.Links or { ["Discord"] = "https://discord.gg/nexzanhub", ["Work.ink"] = "https://work.ink/nexzan" }
    local Accent = cfg.Accent or Color3.fromRGB(139, 92, 246)
    local Size = cfg.Size or "Compact"
    local OnSuccess = cfg.OnSuccess or cfg.Success or function() end
    local OnFail = cfg.OnFail or cfg.Fail or function() end
    local SaveKey = cfg.SaveKey ~= false
    local FileName = cfg.FileName or "NexzanKey.txt"
    local FolderName = cfg.FolderName or "NexzanHub"
    local AutoDestroy = cfg.AutoDestroy ~= false

    local c = {
        bg = Color3.fromRGB(13, 13, 16), surface = Color3.fromRGB(22, 22, 28), surface2 = Color3.fromRGB(30, 30, 38),
        border = Color3.fromRGB(50, 50, 60), text = Color3.fromRGB(240, 240, 245),
        textDim = Color3.fromRGB(160, 160, 175), textMuted = Color3.fromRGB(110, 112, 125),
        inputBg = Color3.fromRGB(18, 18, 24), inputBorder = Color3.fromRGB(45, 45, 55),
        success = Color3.fromRGB(80, 220, 120), error = Color3.fromRGB(255, 90, 90),
        warning = Color3.fromRGB(255, 200, 70), accent = Accent,
    }

    local isCompact = (Size == "Compact")
    local W = isCompact and 300 or 380
    local H = isCompact and 340 or 420

    local savedKey = nil
    if SaveKey then
        pcall(function()
            if isfolder and isfolder(FolderName) then
                if isfile and isfile(FolderName .. "/" .. FileName) then
                    local content = readfile(FolderName .. "/" .. FileName)
                    if content and content ~= "" then
                        if type(Keys) == "table" then
                            for _, k in ipairs(Keys) do if tostring(k) == content then savedKey = content; break end end
                        elseif type(Keys) == "string" then
                            if Keys == content then savedKey = content end
                        elseif type(Keys) == "function" then
                            local ok2, res = pcall(Keys, content)
                            if ok2 and res == true then savedKey = content end
                        end
                    end
                end
            end
        end)
    end
    if savedKey then pcall(OnSuccess, savedKey); return { Success = true, Key = savedKey, IsSaved = true } end
    if getgenv and getgenv().NEXZAN_KEY then
        local ext = getgenv().NEXZAN_KEY
        if type(Keys) == "table" then
            for _, k in ipairs(Keys) do if tostring(k) == ext then savedKey = ext; break end end
        elseif type(Keys) == "string" and Keys == ext then savedKey = ext end
        if savedKey then pcall(OnSuccess, savedKey); return { Success = true, Key = savedKey, IsSaved = true } end
    end

    local parent = gethui and gethui() or CoreGui
    if not parent then parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui") end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexzanKeySystem"; ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.DisplayOrder = 1000
    if protectgui then pcall(protectgui, ScreenGui) end; ScreenGui.Parent = parent

    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Name = "Overlay"; Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Overlay.BackgroundTransparency = 0.55
    Overlay.BorderSizePixel = 0; Overlay.ZIndex = 10

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"; Main.Size = UDim2.fromOffset(W, H)
    Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    Main.BackgroundColor3 = c.bg; Main.BorderSizePixel = 0
    Main.ClipsDescendants = true; Main.ZIndex = 20
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    local Border = Instance.new("Frame", Main)
    Border.Name = "Border"; Border.Size = UDim2.fromScale(1, 1)
    Border.BackgroundTransparency = 1; Border.BorderSizePixel = 0; Border.ZIndex = 5
    Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 16)
    local BorderStroke = Instance.new("UIStroke", Border)
    BorderStroke.Color = c.accent; BorderStroke.Thickness = 1.2; BorderStroke.Transparency = 0.55

    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, isCompact and 50 or 58)
    Header.BackgroundColor3 = c.surface; Header.BorderSizePixel = 0; Header.ZIndex = 5
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local HeaderLine = Instance.new("Frame", Header)
    HeaderLine.Size = UDim2.new(1, -30, 0, 1); HeaderLine.Position = UDim2.new(0, 15, 1, 0)
    HeaderLine.BackgroundColor3 = c.border; HeaderLine.BorderSizePixel = 0; HeaderLine.BackgroundTransparency = 0.6

    local IconFrame = Instance.new("Frame", Header)
    IconFrame.Name = "IconFrame"
    IconFrame.Size = UDim2.fromOffset(isCompact and 32 or 40, isCompact and 32 or 40)
    IconFrame.Position = UDim2.new(0, 14, 0.5, isCompact and -16 or -20)
    IconFrame.BackgroundColor3 = c.accent; IconFrame.BackgroundTransparency = 0.1; IconFrame.BorderSizePixel = 0
    Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(1, 0)
    local LockIcon = Instance.new("TextLabel", IconFrame)
    LockIcon.Size = UDim2.fromScale(1, 1); LockIcon.BackgroundTransparency = 1
    LockIcon.Text = "🔐"; LockIcon.TextColor3 = c.accent
    LockIcon.Font = Enum.Font.SourceSansBold; LockIcon.TextSize = isCompact and 16 or 20

    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Name = "Title"; TitleLbl.Size = UDim2.new(1, -(isCompact and 80 or 100), 0, 22)
    TitleLbl.Position = UDim2.new(0, isCompact and 52 or 62, 0.5, -14)
    TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = Title; TitleLbl.TextColor3 = c.text
    TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextSize = isCompact and 15 or 18
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local SubLbl = Instance.new("TextLabel", Header)
    SubLbl.Name = "SubTitle"; SubLbl.Size = UDim2.new(1, -(isCompact and 80 or 100), 0, 16)
    SubLbl.Position = UDim2.new(0, isCompact and 52 or 62, 0.5, 6)
    SubLbl.BackgroundTransparency = 1; SubLbl.Text = SubTitle; SubLbl.TextColor3 = c.textDim
    SubLbl.Font = Enum.Font.SourceSans; SubLbl.TextSize = isCompact and 11 or 13
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Name = "CloseBtn"; CloseBtn.Size = UDim2.fromOffset(isCompact and 28 or 32, isCompact and 28 or 32)
    CloseBtn.Position = UDim2.new(1, -(isCompact and 10 or 12), 0.5, -(isCompact and 14 or 16))
    CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "✕"; CloseBtn.TextColor3 = c.textMuted
    CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = isCompact and 14 or 16; CloseBtn.AutoButtonColor = false
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 100, 100), TextSize = isCompact and 16 or 18 }):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), { TextColor3 = c.textMuted, TextSize = isCompact and 14 or 16 }):Play()
    end)

    MakeDraggable(Main, Header)

    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"; Content.Size = UDim2.new(1, -(isCompact and 24 or 30), 1, -(isCompact and 58 or 66))
    Content.Position = UDim2.new(0, isCompact and 12 or 15, 0, isCompact and 54 or 62)
    Content.BackgroundTransparency = 1
    local ContentLayout = Instance.new("UIListLayout", Content)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder; ContentLayout.Padding = UDim.new(0, isCompact and 6 or 8)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local GetKeyBtn = Instance.new("TextButton", Content)
    GetKeyBtn.Name = "GetKeyBtn"; GetKeyBtn.LayoutOrder = 1
    GetKeyBtn.Size = UDim2.new(1, 0, 0, isCompact and 44 or 52)
    GetKeyBtn.BackgroundColor3 = c.surface; GetKeyBtn.AutoButtonColor = false; GetKeyBtn.Text = ""
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 12)
    local GKBStroke = Instance.new("UIStroke", GetKeyBtn)
    GKBStroke.Color = c.accent; GKBStroke.Thickness = 1.2; GKBStroke.Transparency = 0.6

    local GKBInner = Instance.new("Frame", GetKeyBtn)
    GKBInner.Name = "Inner"; GKBInner.Size = UDim2.new(1, -16, 1, 0)
    GKBInner.Position = UDim2.new(0, 8, 0, 0); GKBInner.BackgroundTransparency = 1
    local GKBLayout = Instance.new("UIListLayout", GKBInner)
    GKBLayout.FillDirection = Enum.FillDirection.Horizontal
    GKBLayout.VerticalAlignment = Enum.VerticalAlignment.Center; GKBLayout.Padding = UDim.new(0, 8)

    local GKBIcon = Instance.new("TextLabel", GKBInner)
    GKBIcon.Size = UDim2.fromOffset(isCompact and 20 or 24, isCompact and 20 or 24)
    GKBIcon.BackgroundTransparency = 1; GKBIcon.Text = "🔑"; GKBIcon.TextColor3 = c.accent
    GKBIcon.Font = Enum.Font.GothamBold; GKBIcon.TextSize = isCompact and 15 or 18

    local GKBTextFrame = Instance.new("Frame", GKBInner)
    GKBTextFrame.Size = UDim2.new(1, -(isCompact and 44 or 56), 1, 0); GKBTextFrame.BackgroundTransparency = 1
    local GKBTitle = Instance.new("TextLabel", GKBTextFrame)
    GKBTitle.Size = UDim2.new(1, 0, 0, 20); GKBTitle.BackgroundTransparency = 1
    GKBTitle.Text = "GET YOUR KEY"; GKBTitle.TextColor3 = c.text
    GKBTitle.Font = Enum.Font.GothamBold; GKBTitle.TextSize = isCompact and 13 or 15
    GKBTitle.TextXAlignment = Enum.TextXAlignment.Left
    local GKBSub = Instance.new("TextLabel", GKBTextFrame)
    GKBSub.Name = "SubDisplay"; GKBSub.Size = UDim2.new(1, 0, 0, 18)
    GKBSub.Position = UDim2.new(0, 0, 0, 18); GKBSub.BackgroundTransparency = 1; GKBSub.Text = ""
    GKBSub.TextColor3 = c.textMuted; GKBSub.Font = Enum.Font.SourceSans
    GKBSub.TextSize = isCompact and 9 or 11; GKBSub.TextXAlignment = Enum.TextXAlignment.Left

    local GKBArrow = Instance.new("TextLabel", GKBInner)
    GKBArrow.Size = UDim2.fromOffset(22, 22); GKBArrow.BackgroundTransparency = 1
    GKBArrow.Text = "→"; GKBArrow.TextColor3 = c.textDim
    GKBArrow.Font = Enum.Font.GothamBold; GKBArrow.TextSize = 16

    if Mode == "Single" then
        local d = URL:gsub("^https?://", "")
        if #d > 26 then d = d:sub(1, 23) .. "..." end
        GKBSub.Text = "📋  " .. d
    else
        GKBSub.Text = "▼  Tap untuk pilih link"
    end

    GetKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), { BackgroundColor3 = c.surface2 }):Play()
        GKBStroke.Transparency = 0.3
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), { BackgroundColor3 = c.surface }):Play()
        GKBStroke.Transparency = 0.6
    end)

    local DropHolder = Instance.new("Frame", Content)
    DropHolder.Name = "DropHolder"; DropHolder.LayoutOrder = 2
    DropHolder.Size = UDim2.new(1, 0, 0, 0); DropHolder.BackgroundTransparency = 1
    DropHolder.ClipsDescendants = true; DropHolder.Visible = false
    local DropLayout = Instance.new("UIListLayout", DropHolder)
    DropLayout.SortOrder = Enum.SortOrder.LayoutOrder; DropLayout.Padding = UDim.new(0, 5)
    DropLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InputFrame = Instance.new("Frame", Content)
    InputFrame.Name = "InputFrame"; InputFrame.LayoutOrder = 3
    InputFrame.Size = UDim2.new(1, 0, 0, isCompact and 42 or 48)
    InputFrame.BackgroundColor3 = c.inputBg; InputFrame.BorderSizePixel = 0
    Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 10)
    local InStroke = Instance.new("UIStroke", InputFrame)
    InStroke.Color = c.inputBorder; InStroke.Thickness = 1
    local InPad = Instance.new("UIPadding", InputFrame); InPad.PaddingLeft = UDim.new(0, isCompact and 12 or 14)

    local TextBox = Instance.new("TextBox", InputFrame)
    TextBox.Size = UDim2.new(1, -(isCompact and 12 or 14), 1, 0)
    TextBox.BackgroundTransparency = 1; TextBox.PlaceholderText = "Masukkan key disini..."
    TextBox.Text = ""; TextBox.TextColor3 = c.text; TextBox.PlaceholderColor3 = c.textMuted
    TextBox.Font = Enum.Font.SourceSans; TextBox.TextSize = isCompact and 13 or 15
    TextBox.ClearTextOnFocus = false; TextBox.TextXAlignment = Enum.TextXAlignment.Left

    local CharCount = Instance.new("TextLabel", InputFrame)
    CharCount.Size = UDim2.fromOffset(50, 14); CharCount.Position = UDim2.new(1, -54, 1, -2)
    CharCount.BackgroundTransparency = 1; CharCount.Text = "0/50"
    CharCount.TextColor3 = c.textMuted; CharCount.Font = Enum.Font.SourceSans; CharCount.TextSize = 9
    CharCount.TextXAlignment = Enum.TextXAlignment.Right
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local t = TextBox.Text
        if #t > 50 then TextBox.Text = t:sub(1, 50) end
        CharCount.Text = #TextBox.Text .. "/50"
    end)

    local StatusLbl = Instance.new("TextLabel", Content)
    StatusLbl.Name = "Status"; StatusLbl.LayoutOrder = 4
    StatusLbl.Size = UDim2.new(1, 0, 0, 16); StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = ""; StatusLbl.TextColor3 = c.error
    StatusLbl.Font = Enum.Font.SourceSansBold; StatusLbl.TextSize = isCompact and 10 or 11
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Center

    local ActionFrame = Instance.new("Frame", Content)
    ActionFrame.Name = "Actions"; ActionFrame.LayoutOrder = 5
    ActionFrame.Size = UDim2.new(1, 0, 0, isCompact and 42 or 48); ActionFrame.BackgroundTransparency = 1
    local ActLayout = Instance.new("UIListLayout", ActionFrame)
    ActLayout.FillDirection = Enum.FillDirection.Horizontal; ActLayout.Padding = UDim.new(0, isCompact and 8 or 10)
    ActLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local VerifyBtn = Instance.new("TextButton", ActionFrame)
    VerifyBtn.Name = "VerifyBtn"; VerifyBtn.Size = UDim2.new(0.7, 0, 1, 0)
    VerifyBtn.BackgroundColor3 = c.accent; VerifyBtn.Text = "✓  VERIFY KEY"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.Font = Enum.Font.GothamBold; VerifyBtn.TextSize = isCompact and 13 or 15
    VerifyBtn.AutoButtonColor = false; Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 10)
    VerifyBtn.MouseEnter:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(160, 110, 245) }):Play()
    end)
    VerifyBtn.MouseLeave:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.15), { BackgroundColor3 = c.accent }):Play()
    end)

    local ResetBtn = Instance.new("TextButton", ActionFrame)
    ResetBtn.Name = "ResetBtn"; ResetBtn.Size = UDim2.new(0.25, 0, 1, 0)
    ResetBtn.BackgroundColor3 = c.surface2; ResetBtn.Text = "↺"
    ResetBtn.TextColor3 = c.textDim; ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = isCompact and 16 or 18; ResetBtn.AutoButtonColor = false
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 10)
    local ResetStroke = Instance.new("UIStroke", ResetBtn)
    ResetStroke.Color = c.border; ResetStroke.Thickness = 1
    ResetBtn.MouseEnter:Connect(function()
        TweenService:Create(ResetBtn, TweenInfo.new(0.15), { BackgroundColor3 = c.surface }):Play()
    end)
    ResetBtn.MouseLeave:Connect(function()
        TweenService:Create(ResetBtn, TweenInfo.new(0.15), { BackgroundColor3 = c.surface2 }):Play()
    end)

    local function SetStatus(text, color)
        StatusLbl.Text = text; StatusLbl.TextColor3 = color or c.error
    end

    local function ValidateKey(input)
        if not input or input == "" then return false end
        input = tostring(input):gsub("^%s*", ""):gsub("%s*$", "")
        if type(Keys) == "table" then
            for _, k in ipairs(Keys) do if tostring(k) == input then return true end end
            return false
        elseif type(Keys) == "function" then
            local ok2, res = pcall(Keys, input)
            return ok2 and res == true
        elseif type(Keys) == "string" then
            return Keys == input
        end
        return false
    end

    local function SaveKey(key)
        if not SaveKey then return end
        pcall(function()
            if not isfolder or not isfolder(FolderName) then
                if makefolder then makefolder(FolderName) end
            end
            if writefile then writefile(FolderName .. "/" .. FileName, tostring(key)) end
        end)
    end

    local function OnSuccessFunc(key)
        SetStatus("✓  Access Granted!", c.success)
        SaveKey(key)
        if getgenv then getgenv().NEXZAN_KEY = key end
        ShowToast(ScreenGui, "✓ Access Granted", "Welcome to " .. Title, 2.5, c.accent)
        task.wait(0.9)
        if AutoDestroy then
            local out = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(W, 0), BackgroundTransparency = 1
            })
            out:Play()
            TweenService:Create(Overlay, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            out.Completed:Wait()
            ScreenGui:Destroy()
        end
        pcall(OnSuccess, key)
    end

    local function OnFailFunc()
        SetStatus("✗  Invalid Key!", c.error)
        ShowToast(ScreenGui, "✗ Invalid Key", "Please check and try again", 2.2, c.error)
        local origPos = Main.Position
        for i = 1, 2 do
            TweenService:Create(Main, TweenInfo.new(0.04), { Position = origPos + UDim2.fromOffset(6, 0) }):Play()
            task.wait(0.04)
            TweenService:Create(Main, TweenInfo.new(0.04), { Position = origPos + UDim2.fromOffset(-6, 0) }):Play()
            task.wait(0.04)
        end
        Main.Position = origPos
        pcall(OnFail)
    end

    GetKeyBtn.MouseButton1Click:Connect(function()
        if Mode == "Single" then
            local copied = CopyToClipboard(URL)
            if copied then
                SetStatus("✓  Link copied!", c.success)
                ShowToast(ScreenGui, "✓ Link Copied!", "Open to get your key", 2.5, c.accent)
                pcall(function()
                    local gs = game:GetService("GuiService")
                    if gs and gs.OpenBrowserWindow then gs:OpenBrowserWindow(URL) end
                end)
            else
                SetStatus("⚠  Manual: " .. URL:sub(1, 30) .. (URL:len() > 30 and "..." or ""), c.warning)
                ShowToast(ScreenGui, "⚠ Manual Copy", URL:sub(1, 35), 3, c.warning)
            end
        elseif Mode == "Multi" then
            local visible = not DropHolder.Visible
            DropHolder.Visible = visible
            if visible then
                GKBSub.Text = "▲  Tap untuk tutup"
                local items = {}
                for _, v in pairs(DropHolder:GetChildren()) do
                    if v:IsA("TextButton") then table.insert(items, v) end
                end
                local totalH = 0
                for _, btn in ipairs(items) do totalH = totalH + (btn.AbsoluteSize.Y or 36) + 5 end
                if totalH > 0 then totalH = totalH - 5 end
                TweenService:Create(DropHolder, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, totalH)
                }):Play()
            else
                GKBSub.Text = "▼  Tap untuk pilih link"
                TweenService:Create(DropHolder, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, 0) }):Play()
                task.wait(0.18)
                DropHolder.Visible = false
            end
        end
    end)

    if Mode == "Multi" then
        local linksData = {}
        if URLs and type(URLs) == "table" then
            local isDict = false
            for k, _ in pairs(URLs) do if type(k) == "string" then isDict = true; break end end
            if isDict then
                for name, url in pairs(URLs) do table.insert(linksData, { Name = name, URL = url }) end
            else
                for i, url in ipairs(URLs) do table.insert(linksData, { Name = "Link " .. i, URL = url }) end
            end
        else
            table.insert(linksData, { Name = "Discord", URL = "https://discord.gg/nexzanhub" })
            table.insert(linksData, { Name = "Work.ink", URL = "https://work.ink/nexzan" })
        end

        for i, linkData in ipairs(linksData) do
            local item = Instance.new("TextButton", DropHolder)
            item.LayoutOrder = i; item.Name = "DropItem_" .. i
            item.Size = UDim2.new(0.94, 0, 0, isCompact and 34 or 40)
            item.BackgroundColor3 = c.surface2; item.AutoButtonColor = false; item.Text = ""
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
            local itemStroke = Instance.new("UIStroke", item)
            itemStroke.Color = c.border; itemStroke.Thickness = 1
            local itLayout = Instance.new("UIListLayout", item)
            itLayout.FillDirection = Enum.FillDirection.Horizontal
            itLayout.VerticalAlignment = Enum.VerticalAlignment.Center; itLayout.Padding = UDim.new(0, 8)
            local itPad = Instance.new("UIPadding", item); itPad.PaddingLeft = UDim.new(0, 10)

            local itIcon = Instance.new("TextLabel", item)
            itIcon.Size = UDim2.fromOffset(isCompact and 18 or 22, isCompact and 18 or 22)
            itIcon.BackgroundTransparency = 1; itIcon.Text = "🔗"; itIcon.TextColor3 = c.accent
            itIcon.Font = Enum.Font.SourceSansBold; itIcon.TextSize = isCompact and 12 or 14

            local itNameFrame = Instance.new("Frame", item)
            itNameFrame.Size = UDim2.new(1, -(isCompact and 40 or 50), 1, 0); itNameFrame.BackgroundTransparency = 1
            local itName = Instance.new("TextLabel", itNameFrame)
            itName.Size = UDim2.new(1, 0, 0, 18); itName.BackgroundTransparency = 1
            itName.Text = linkData.Name; itName.TextColor3 = c.text; itName.Font = Enum.Font.GothamBold
            itName.TextSize = isCompact and 11 or 13; itName.TextXAlignment = Enum.TextXAlignment.Left
            local itUrl = Instance.new("TextLabel", itNameFrame)
            itUrl.Size = UDim2.new(1, 0, 0, 16); itUrl.Position = UDim2.new(0, 0, 0, 16)
            itUrl.BackgroundTransparency = 1
            local urlD = linkData.URL:gsub("^https?://", "")
            if #urlD > 24 then urlD = urlD:sub(1, 21) .. "..." end
            itUrl.Text = urlD; itUrl.TextColor3 = c.textMuted; itUrl.Font = Enum.Font.SourceSans
            itUrl.TextSize = isCompact and 8 or 10; itUrl.TextXAlignment = Enum.TextXAlignment.Left

            local itArrow = Instance.new("TextLabel", item)
            itArrow.Size = UDim2.fromOffset(isCompact and 16 or 20, isCompact and 16 or 20)
            itArrow.BackgroundTransparency = 1; itArrow.Text = "→"; itArrow.TextColor3 = c.textDim
            itArrow.Font = Enum.Font.SourceSansBold; itArrow.TextSize = 14

            item.MouseEnter:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 46) }):Play()
                itemStroke.Color = c.accent; itemStroke.Transparency = 0.5
                TweenService:Create(itArrow, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            end)
            item.MouseLeave:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), { BackgroundColor3 = c.surface2 }):Play()
                itemStroke.Color = c.border; itemStroke.Transparency = 0
                TweenService:Create(itArrow, TweenInfo.new(0.15), { TextColor3 = c.textDim }):Play()
            end)

            item.MouseButton1Click:Connect(function()
                local copied = CopyToClipboard(linkData.URL)
                if copied then
                    SetStatus("✓  Copied: " .. linkData.Name, c.success)
                    ShowToast(ScreenGui, "✓ Copied", linkData.Name .. " link copied!", 2, c.accent)
                    pcall(function()
                        local gs = game:GetService("GuiService")
                        if gs and gs.OpenBrowserWindow then gs:OpenBrowserWindow(linkData.URL) end
                    end)
                else
                    SetStatus("⚠  Manual: " .. linkData.URL:sub(1, 25), c.warning)
                    ShowToast(ScreenGui, "⚠ Manual Copy", linkData.URL:sub(1, 30), 3, c.warning)
                end
                DropHolder.Visible = false; GKBSub.Text = "▼  Tap untuk pilih link"
                TweenService:Create(DropHolder, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) }):Play()
            end)
        end
    end

    VerifyBtn.MouseButton1Click:Connect(function()
        local input = TextBox.Text
        if input == "" then SetStatus("⚠  Masukkan key terlebih dahulu!", c.warning); return end
        if ValidateKey(input) then OnSuccessFunc(input) else OnFailFunc() end
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = TextBox.Text
            if input ~= "" then
                if ValidateKey(input) then OnSuccessFunc(input) else OnFailFunc() end
            end
        end
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        TextBox.Text = ""; CharCount.Text = "0/50"; SetStatus("", c.text)
        ShowToast(ScreenGui, "↺ Cleared", "Input sudah dibersihkan", 1.5, c.textDim)
    end)

    Overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if DropHolder and DropHolder.Visible then
                DropHolder.Visible = false; GKBSub.Text = "▼  Tap untuk pilih link"
                TweenService:Create(DropHolder, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) }):Play()
            end
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        local out = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(W, 0), BackgroundTransparency = 1
        })
        out:Play()
        TweenService:Create(Overlay, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        out.Completed:Wait()
        ScreenGui:Destroy()
    end)

    Main.Size = UDim2.fromOffset(W - 30, 0); Main.BackgroundTransparency = 0.3
    Main.Position = UDim2.new(0.5, -W/2, 0.5, -30)
    task.wait(0.02)
    TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(W, H), BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.55 }):Play()

    coroutine.wrap(function()
        while Main and Main.Parent do
            for i = 0.55, 0.3, -0.04 do
                if not Main or not Main.Parent then return end
                BorderStroke.Transparency = i; task.wait(0.04)
            end
            for i = 0.3, 0.55, 0.04 do
                if not Main or not Main.Parent then return end
                BorderStroke.Transparency = i; task.wait(0.04)
            end
        end
    end)()

    local controller = {
        Gui = ScreenGui, Main = Main, TextBox = TextBox,
        Status = StatusLbl, VerifyBtn = VerifyBtn, GetKeyBtn = GetKeyBtn,
        Dropdown = DropHolder, Mode = Mode,
        SetStatus = function(_, text, color) SetStatus(text, color) end,
        Show = function()
            ScreenGui.Enabled = true
            TweenService:Create(Main, TweenInfo.new(0.25), { BackgroundTransparency = 0, Size = UDim2.fromOffset(W, H) }):Play()
        end,
        Hide = function()
            TweenService:Create(Main, TweenInfo.new(0.25), { Size = UDim2.fromOffset(W, 0) }):Play()
            task.wait(0.25); ScreenGui.Enabled = false
        end,
        Destroy = function() ScreenGui:Destroy() end,
    }
    return controller
end

return KeyUI
