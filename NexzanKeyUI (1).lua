--// ================================================================ //
--//  NEXZAN KEY SYSTEM UI - ELEGAN & COMPACT
--//  Bisa Single/Multi Link, Draggable, Compact buat Mobile
--//  Created for Nexzan Hub Library
--// ================================================================ //

local NexzanKeyUI = {}
NexzanKeyUI.__index = NexzanKeyUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ================================================================ --
-- FUNGSI DRAG (biar UI bisa digeser)
-- ================================================================ --
local function MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ================================================================ --
-- FUNGSI COPY KE CLIPBOARD
-- ================================================================ --
local function CopyToClipboard(text)
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        elseif toclipboard then
            toclipboard(text)
            success = true
        elseif set_clipboard then
            set_clipboard(text)
            success = true
        elseif clipboard then
            clipboard.set(text)
            success = true
        elseif writeclipboard then
            writeclipboard(text)
            success = true
        end
    end)
    return success
end

-- ================================================================ --
-- NOTIFIKASI BUILT-IN (small toast)
-- ================================================================ --
local function ShowToast(parentGui, title, message, duration, accentColor)
    duration = duration or 3
    accentColor = accentColor or Color3.fromHex("#7c3aed")

    local toast = Instance.new("Frame")
    toast.Name = "NexzanToast"
    toast.Size = UDim2.fromOffset(0, 38)
    toast.Position = UDim2.new(0.5, 0, 0, 20)
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    toast.BackgroundTransparency = 0.1
    toast.BorderSizePixel = 0
    toast.ClipsDescendants = true
    toast.Parent = parentGui

    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.4

    local pad = Instance.new("UIPadding", toast)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)

    local layout = Instance.new("UIListLayout", toast)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)

    local dot = Instance.new("Frame", toast)
    dot.Size = UDim2.fromOffset(6, 6)
    dot.BackgroundColor3 = accentColor
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local textFrame = Instance.new("Frame", toast)
    textFrame.Size = UDim2.new(1, -30, 1, 0)
    textFrame.BackgroundTransparency = 1

    local titleLbl = Instance.new("TextLabel", textFrame)
    titleLbl.Size = UDim2.new(1, 0, 0, 16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local msgLbl = Instance.new("TextLabel", textFrame)
    msgLbl.Size = UDim2.new(1, 0, 0, 14)
    msgLbl.Position = UDim2.new(0, 0, 0, 16)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 11
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Animasi masuk
    toast.Size = UDim2.fromOffset(0, 38)
    toast.AutomaticSize = Enum.AutomaticSize.X
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()

    task.wait(duration)

    -- Animasi keluar
    local out = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, -20)
    })
    out:Play()
    out.Completed:Wait()
    toast:Destroy()
end

-- ================================================================ --
-- FUNGSI MEMBUAT KEY SYSTEM UI UTAMA
-- ================================================================ --

---[[
-- CONTOH PEMAKAIAN (Single URL):
-- 
-- local Keys = NexzanKeyUI:Create({
--     Title = "Nexzan Hub",
--     SubTitle = "Premium Script",
--     Mode = "Single",  -- "Single" atau "Multi"
--     Keys = {"KEY123", "PREMIUM2024"},
--     URL = "https://discord.gg/nexzanhub",
--     Accent = Color3.fromHex("#7c3aed"),
--     OnSuccess = function(key) print("Key valid: " .. key) end,
-- })
--
-- CONTOH PEMAKAIAN (Multi URL):
--
-- local Keys = NexzanKeyUI:Create({
--     Title = "Nexzan Hub",
--     SubTitle = "Premium Script",
--     Mode = "Multi",
--     Keys = {"KEY123", "PREMIUM2024"},
--     URLs = {
--         ["Discord"] = "https://discord.gg/nexzanhub",
--         ["Work.ink"] = "https://work.ink/nexzankey",
--         ["Linkvertise"] = "https://linkvertise.com/nexzan",
--         ["Pastebin"] = "https://pastebin.com/raw/xxx",
--     },
--     Accent = Color3.fromHex("#7c3aed"),
--     OnSuccess = function(key) print("Key valid: " .. key) end,
-- })
--]]

function NexzanKeyUI:Create(config)
    config = config or {}

    -- ===== KONFIGURASI =====
    local Title          = config.Title or "Nexzan Hub"
    local SubTitle       = config.SubTitle or "Key Verification"
    local Mode           = config.Mode or "Single"  -- "Single" atau "Multi"
    local ValidKeys      = config.Keys or config.Key or {"NEXZAN2024", "PREMIUM"}
    local SingleURL      = config.URL or config.Link or "https://discord.gg/nexzanhub"
    local MultiURLs      = config.URLs or config.Links or nil
    local AccentColor    = config.Accent or Color3.fromHex("#7c3aed")
    local OnSuccessCB    = config.OnSuccess or config.Success or function() end
    local OnFailCB       = config.OnFail or config.Fail or function() end
    local SaveKeyEnabled = config.SaveKey ~= false
    local FileName       = config.FileName or "NexzanKey.txt"
    local FolderName     = config.FolderName or "NexzanHub"
    local Size           = config.Size or "Compact" -- "Compact" atau "Normal"
    local AutoDestroy    = config.AutoDestroy ~= false

    -- Warna-warna
    local colors = {
        bg          = Color3.fromRGB(14, 14, 20),
        surface     = Color3.fromRGB(20, 20, 30),
        surface2    = Color3.fromRGB(26, 26, 38),
        border      = Color3.fromRGB(40, 40, 55),
        text        = Color3.fromRGB(255, 255, 255),
        textDim     = Color3.fromRGB(160, 160, 175),
        textMuted   = Color3.fromRGB(110, 110, 125),
        inputBg     = Color3.fromRGB(22, 22, 34),
        inputBorder = Color3.fromRGB(50, 50, 65),
        success     = Color3.fromRGB(80, 220, 120),
        error       = Color3.fromRGB(255, 90, 90),
        warning     = Color3.fromRGB(255, 200, 70),
        accent      = AccentColor,
    }

    -- Ukuran berdasarkan mode
    local isCompact = (Size == "Compact")
    local W = isCompact and 280 or 340
    local H = isCompact and 320 or 380

    -- ===== CEK SAVED KEY =====
    local function CheckSavedKey()
        if not SaveKeyEnabled then return nil end
        local ok, content = pcall(function()
            if isfile and isfile(FolderName .. "/" .. FileName) then
                return readfile(FolderName .. "/" .. FileName)
            end
            return nil
        end)
        if ok and content and content ~= "" then
            -- Validasi
            if type(ValidKeys) == "table" then
                for _, v in ipairs(ValidKeys) do
                    if tostring(v) == content then return content end
                end
            elseif type(ValidKeys) == "function" then
                local ok2, res = pcall(ValidKeys, content)
                if ok2 and res then return content end
            elseif type(ValidKeys) == "string" then
                if ValidKeys == content then return content end
            end
        end
        return nil
    end

    local savedKey = CheckSavedKey()
    if savedKey then
        -- Auto login kalo ada saved key
        local ok, err = pcall(OnSuccessCB, savedKey)
        return { Success = true, Key = savedKey, IsSaved = true }
    end

    -- Cek juga dari getgenv
    if getgenv and getgenv().NEXZAN_KEY then
        local extKey = getgenv().NEXZAN_KEY
        if type(ValidKeys) == "table" then
            for _, v in ipairs(ValidKeys) do
                if tostring(v) == extKey then
                    pcall(OnSuccessCB, extKey)
                    return { Success = true, Key = extKey, IsSaved = true }
                end
            end
        end
    end

    -- ===== BUILD PARENT =====
    local parent = gethui and gethui() or CoreGui
    if not parent then
        parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexzanKeyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 1000
    ScreenGui.Parent = parent
    if protectgui then pcall(protectgui, ScreenGui) end

    -- ===== BACKGROUND (overlay gelap) =====
    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Name = "Overlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.45
    Overlay.BorderSizePixel = 0

    -- ===== MAIN FRAME =====
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(W, H)
    Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    Main.BackgroundColor3 = colors.bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true

    -- Shadow effect
    local Shadow = Instance.new("ImageLabel", Main)
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.fromScale(1, 1)
    Shadow.Position = UDim2.fromOffset(8, 8)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = -1

    -- Rounded corners
    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, isCompact and 14 or 16)

    -- Border glow
    local Border = Instance.new("Frame", Main)
    Border.Name = "Border"
    Border.Size = UDim2.fromScale(1, 1)
    Border.BackgroundTransparency = 1
    Border.BorderSizePixel = 0
    Border.ZIndex = 10
    local BorderCorner = Instance.new("UICorner", Border)
    BorderCorner.CornerRadius = UDim.new(0, isCompact and 14 or 16)
    local BorderStroke = Instance.new("UIStroke", Border)
    BorderStroke.Color = colors.accent
    BorderStroke.Thickness = 1.5
    BorderStroke.Transparency = 0.5

    -- ===== DRAG HEADER =====
    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, isCompact and 44 or 50)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 5

    -- Gradient line di bawah header
    local HeaderLine = Instance.new("Frame", Header)
    HeaderLine.Name = "HeaderLine"
    HeaderLine.Size = UDim2.new(1, -30, 0, 1)
    HeaderLine.Position = UDim2.new(0, 15, 1, 0)
    HeaderLine.BackgroundColor3 = colors.border
    HeaderLine.BorderSizePixel = 0
    HeaderLine.BackgroundTransparency = 0.5

    -- Icon Bulat
    local IconFrame = Instance.new("Frame", Header)
    IconFrame.Name = "Icon"
    IconFrame.Size = UDim2.fromOffset(isCompact and 24 or 28, isCompact and 24 or 28)
    IconFrame.Position = UDim2.new(0, isCompact and 14 or 18, 0.5, isCompact and -12 or -14)
    IconFrame.BackgroundColor3 = colors.accent
    IconFrame.BackgroundTransparency = 0.85
    Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(1, 0)

    local IconText = Instance.new("TextLabel", IconFrame)
    IconText.Size = UDim2.fromScale(1, 1)
    IconText.BackgroundTransparency = 1
    IconText.Text = "🔐"
    IconText.TextSize = isCompact and 13 or 15
    IconText.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Title
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Name = "Title"
    TitleLbl.Size = UDim2.new(1, -(isCompact and 80 or 90), 0, 18)
    TitleLbl.Position = UDim2.new(0, isCompact and 44 or 52, 0.5, -10)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = colors.text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = isCompact and 14 or 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- SubTitle
    local SubLbl = Instance.new("TextLabel", Header)
    SubLbl.Name = "SubTitle"
    SubLbl.Size = UDim2.new(1, -(isCompact and 80 or 90), 0, 14)
    SubLbl.Position = UDim2.new(0, isCompact and 44 or 52, 0.5, 6)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Text = SubTitle
    SubLbl.TextColor3 = colors.textDim
    SubLbl.Font = Enum.Font.Gotham
    SubLbl.TextSize = isCompact and 10 or 11
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button (X)
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.fromOffset(isCompact and 28 or 32, isCompact and 28 or 32)
    CloseBtn.Position = UDim2.new(1, -(isCompact and 12 or 16), 0.5, -(isCompact and 14 or 16))
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = colors.textMuted
    CloseBtn.TextSize = isCompact and 14 or 16
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.AutoButtonColor = false

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 100, 100),
            TextSize = isCompact and 16 or 18
        }):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
            TextColor3 = colors.textMuted,
            TextSize = isCompact and 14 or 16
        }):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        -- Animasi keluar
        local out = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(W, 0),
            BackgroundTransparency = 1
        })
        out:Play()
        TweenService:Create(Overlay, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        out.Completed:Wait()
        ScreenGui:Destroy()
    end)

    -- DRAG pada Header
    MakeDraggable(Main, Header)

    -- ===== ISI CONTENT =====
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -(isCompact and 20 or 24), 1, -(isCompact and 54 or 62))
    Content.Position = UDim2.new(0, isCompact and 10 or 12, 0, isCompact and 50 or 56)
    Content.BackgroundTransparency = 1

    local ContentLayout = Instance.new("UIListLayout", Content)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, isCompact and 8 or 10)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- ===== GET KEY BUTTON =====
    local GetKeyBtn = Instance.new("TextButton", Content)
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.LayoutOrder = 1
    GetKeyBtn.Size = UDim2.new(1, 0, 0, isCompact and 40 or 46)
    GetKeyBtn.BackgroundColor3 = colors.surface
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Text = ""
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, isCompact and 10 or 12)

    local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
    GetKeyStroke.Color = colors.accent
    GetKeyStroke.Thickness = 1
    GetKeyStroke.Transparency = 0.55

    local GetKeyInner = Instance.new("Frame", GetKeyBtn)
    GetKeyInner.Name = "Inner"
    GetKeyInner.Size = UDim2.new(1, -20, 1, 0)
    GetKeyInner.Position = UDim2.new(0, 10, 0, 0)
    GetKeyInner.BackgroundTransparency = 1

    local GetKeyLayout = Instance.new("UIListLayout", GetKeyInner)
    GetKeyLayout.FillDirection = Enum.FillDirection.Horizontal
    GetKeyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    GetKeyLayout.Padding = UDim.new(0, isCompact and 6 or 8)

    -- Icon
    local GetKeyIcon = Instance.new("TextLabel", GetKeyInner)
    GetKeyIcon.Size = UDim2.fromOffset(isCompact and 18 or 22, isCompact and 18 or 22)
    GetKeyIcon.BackgroundTransparency = 1
    GetKeyIcon.Text = "🔑"
    GetKeyIcon.TextSize = isCompact and 14 or 16

    -- Text + URL display
    local GetKeyTextFrame = Instance.new("Frame", GetKeyInner)
    GetKeyTextFrame.Size = UDim2.new(1, -(isCompact and 40 or 50), 1, 0)
    GetKeyTextFrame.BackgroundTransparency = 1

    local GetKeyTitleLbl = Instance.new("TextLabel", GetKeyTextFrame)
    GetKeyTitleLbl.Size = UDim2.new(1, 0, 0, 18)
    GetKeyTitleLbl.BackgroundTransparency = 1
    GetKeyTitleLbl.Text = "Get Key"
    GetKeyTitleLbl.TextColor3 = colors.text
    GetKeyTitleLbl.Font = Enum.Font.GothamBold
    GetKeyTitleLbl.TextSize = isCompact and 13 or 14
    GetKeyTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local GetKeySubLbl = Instance.new("TextLabel", GetKeyTextFrame)
    GetKeySubLbl.Name = "URLDisplay"
    GetKeySubLbl.Size = UDim2.new(1, 0, 0, 14)
    GetKeySubLbl.Position = UDim2.new(0, 0, 0, 18)
    GetKeySubLbl.BackgroundTransparency = 1
    GetKeySubLbl.Text = ""
    GetKeySubLbl.TextColor3 = colors.textMuted
    GetKeySubLbl.Font = Enum.Font.Gotham
    GetKeySubLbl.TextSize = isCompact and 9 or 10
    GetKeySubLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Arrow
    local GetKeyArrow = Instance.new("TextLabel", GetKeyInner)
    GetKeyArrow.Size = UDim2.fromOffset(isCompact and 18 or 22, isCompact and 18 or 22)
    GetKeyArrow.BackgroundTransparency = 1
    GetKeyArrow.Text = "→"
    GetKeyArrow.TextColor3 = colors.textDim
    GetKeyArrow.TextSize = isCompact and 16 or 18

    -- Set URL display for Single mode
    if Mode == "Single" then
        local display = SingleURL:gsub("^https?://", "")
        if #display > 30 then display = display:sub(1, 27) .. "..." end
        GetKeySubLbl.Text = "📋 " .. display
    elseif Mode == "Multi" then
        GetKeySubLbl.Text = "▼ Tap to choose link"
    end

    -- Hover effects
    GetKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 44)
        }):Play()
        GetKeyStroke.Transparency = 0.3
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.surface
        }):Play()
        GetKeyStroke.Transparency = 0.55
    end)

    -- ===== DROPDOWN MULTI (hidden by default) =====
    local DropdownHolder = Instance.new("Frame", Content)
    DropdownHolder.Name = "DropdownHolder"
    DropdownHolder.LayoutOrder = 2
    DropdownHolder.Size = UDim2.new(1, 0, 0, 0)
    DropdownHolder.BackgroundTransparency = 1
    DropdownHolder.ClipsDescendants = true
    DropdownHolder.Visible = false

    local DropdownLayout = Instance.new("UIListLayout", DropdownHolder)
    DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownLayout.Padding = UDim.new(0, 4)
    DropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- ===== INPUT FIELD =====
    local InputHolder = Instance.new("Frame", Content)
    InputHolder.Name = "InputHolder"
    InputHolder.LayoutOrder = 3
    InputHolder.Size = UDim2.new(1, 0, 0, isCompact and 36 or 42)
    InputHolder.BackgroundColor3 = colors.inputBg
    InputHolder.BorderSizePixel = 0
    Instance.new("UICorner", InputHolder).CornerRadius = UDim.new(0, isCompact and 8 or 10)

    local InputStroke = Instance.new("UIStroke", InputHolder)
    InputStroke.Color = colors.inputBorder
    InputStroke.Thickness = 1

    local InputPadding = Instance.new("UIPadding", InputHolder)
    InputPadding.PaddingLeft = UDim.new(0, isCompact and 10 or 14)

    local TextBox = Instance.new("TextBox", InputHolder)
    TextBox.Size = UDim2.new(1, -(isCompact and 10 or 14), 1, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.PlaceholderText = "Paste your key here..."
    TextBox.Text = ""
    TextBox.TextColor3 = colors.text
    TextBox.PlaceholderColor3 = colors.textMuted
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = isCompact and 12 or 14
    TextBox.ClearTextOnFocus = false
    TextBox.TextXAlignment = Enum.TextXAlignment.Left

    -- ===== STATUS LABEL =====
    local StatusLbl = Instance.new("TextLabel", Content)
    StatusLbl.Name = "Status"
    StatusLbl.LayoutOrder = 4
    StatusLbl.Size = UDim2.new(1, 0, 0, 14)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = ""
    StatusLbl.TextColor3 = colors.error
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = isCompact and 10 or 11
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- ===== ACTION BUTTONS =====
    local ActionHolder = Instance.new("Frame", Content)
    ActionHolder.Name = "Actions"
    ActionHolder.LayoutOrder = 5
    ActionHolder.Size = UDim2.new(1, 0, 0, isCompact and 36 or 42)
    ActionHolder.BackgroundTransparency = 1

    local ActionLayout = Instance.new("UIListLayout", ActionHolder)
    ActionLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionLayout.Padding = UDim.new(0, isCompact and 8 or 10)
    ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Verify Button
    local VerifyBtn = Instance.new("TextButton", ActionHolder)
    VerifyBtn.Name = "VerifyBtn"
    VerifyBtn.Size = UDim2.new(0.65, 0, 1, 0)
    VerifyBtn.BackgroundColor3 = colors.accent
    VerifyBtn.Text = "✓ Verify Key"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.TextSize = isCompact and 12 or 14
    VerifyBtn.AutoButtonColor = false
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, isCompact and 8 or 10)

    VerifyBtn.MouseEnter:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(160, 100, 255)
        }):Play()
    end)
    VerifyBtn.MouseLeave:Connect(function()
        TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.accent
        }):Play()
    end)

    -- Reset Button
    local ResetBtn = Instance.new("TextButton", ActionHolder)
    ResetBtn.Name = "ResetBtn"
    ResetBtn.Size = UDim2.new(0.25, 0, 1, 0)
    ResetBtn.BackgroundColor3 = colors.surface2
    ResetBtn.Text = "↺"
    ResetBtn.TextColor3 = colors.textDim
    ResetBtn.Font = Enum.Font.Gotham
    ResetBtn.TextSize = isCompact and 16 or 18
    ResetBtn.AutoButtonColor = false
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, isCompact and 8 or 10)
    local ResetStroke = Instance.new("UIStroke", ResetBtn)
    ResetStroke.Color = colors.border
    ResetStroke.Thickness = 1

    ResetBtn.MouseEnter:Connect(function()
        TweenService:Create(ResetBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        }):Play()
    end)
    ResetBtn.MouseLeave:Connect(function()
        TweenService:Create(ResetBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.surface2
        }):Play()
    end)

    -- ===== FUNGSI-FUNGSI =====
    local function SetStatus(text, color)
        StatusLbl.Text = text
        StatusLbl.TextColor3 = color or colors.error
    end

    local function ValidateKey(input)
        if not input or input == "" then return false end
        input = tostring(input):gsub("^%s+", ""):gsub("%s+$", "")

        if type(ValidKeys) == "table" then
            for _, k in ipairs(ValidKeys) do
                if tostring(k) == input then return true end
            end
            return false
        elseif type(ValidKeys) == "function" then
            local ok, res = pcall(ValidKeys, input)
            return ok and res == true
        elseif type(ValidKeys) == "string" then
            return ValidKeys == input
        end
        return false
    end

    local function SaveKey(key)
        if not SaveKeyEnabled then return end
        pcall(function()
            if not isfolder(FolderName) then makefolder(FolderName) end
            writefile(FolderName .. "/" .. FileName, tostring(key))
        end)
    end

    local function OnSuccess(key)
        SetStatus("✓ Access Granted!", colors.success)
        SaveKey(key)
        if getgenv then getgenv().NEXZAN_KEY = key end

        ShowToast(ScreenGui, "✓ Access Granted", "Welcome to " .. Title .. "!", 2.5, colors.accent)

        task.wait(0.8)

        -- Animasi keluar
        if AutoDestroy then
            local out = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(W - 20, 0),
                BackgroundTransparency = 1
            })
            out:Play()
            TweenService:Create(Overlay, TweenInfo.new(0.4), {
                BackgroundTransparency = 1
            }):Play()
            out.Completed:Wait()
            ScreenGui:Destroy()
        end

        pcall(OnSuccessCB, key)
    end

    local function OnFail()
        SetStatus("✗ Invalid Key!", colors.error)
        ShowToast(ScreenGui, "✗ Invalid Key", "Please check your key and try again", 2, colors.error)

        -- Shake animation
        local origPos = Main.Position
        for i = 1, 3 do
            TweenService:Create(Main, TweenInfo.new(0.04), {
                Position = origPos + UDim2.fromOffset(5, 0)
            }):Play()
            task.wait(0.04)
            TweenService:Create(Main, TweenInfo.new(0.04), {
                Position = origPos + UDim2.fromOffset(-5, 0)
            }):Play()
            task.wait(0.04)
        end
        Main.Position = origPos

        pcall(OnFailCB)
    end

    -- ===== GET KEY CLICK HANDLER =====
    GetKeyBtn.MouseButton1Click:Connect(function()
        if Mode == "Single" then
            -- Single: langsung copy
            local copied = CopyToClipboard(SingleURL)

            if copied then
                SetStatus("✓ Link copied!", colors.success)
                ShowToast(ScreenGui, "✓ Link Copied!", "Open link to get your key", 2.5, colors.accent)
                -- Open browser
                pcall(function()
                    local gs = game:GetService("GuiService")
                    if gs and gs.OpenBrowserWindow then
                        gs:OpenBrowserWindow(SingleURL)
                    end
                end)
            else
                SetStatus("⚠ Manual: " .. SingleURL:sub(1, 35) .. "...", colors.warning)
                ShowToast(ScreenGui, "⚠ Copy Manual", SingleURL:sub(1, 40), 4, colors.warning)
            end

        elseif Mode == "Multi" then
            -- Multi: toggle dropdown
            DropdownHolder.Visible = not DropdownHolder.Visible

            if DropdownHolder.Visible then
                GetKeySubLbl.Text = "▲ Tap to close"
                -- Animate dropdown open
                local totalHeight = 0
                for _, child in ipairs(DropdownHolder:GetChildren()) do
                    if child:IsA("TextButton") then
                        totalHeight = totalHeight + (isCompact and 32 or 38) + 4
                    end
                end
                if totalHeight > 0 then totalHeight = totalHeight - 4 end

                TweenService:Create(DropdownHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, totalHeight)
                }):Play()
            else
                GetKeySubLbl.Text = "▼ Tap to choose link"
                TweenService:Create(DropdownHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
                task.wait(0.2)
            end
        end
    end)

    -- ===== BUILD DROPDOWN ITEMS (MULTI MODE) =====
    if Mode == "Multi" then
        local linksToShow = {}
        if MultiURLs and type(MultiURLs) == "table" then
            -- Check if dictionary
            local isDict = false
            for k, _ in pairs(MultiURLs) do
                if type(k) == "string" then isDict = true; break end
            end
            if isDict then
                for name, url in pairs(MultiURLs) do
                    table.insert(linksToShow, { Name = name, URL = url })
                end
            else
                for i, url in ipairs(MultiURLs) do
                    table.insert(linksToShow, { Name = "Link " .. i, URL = url })
                end
            end
        else
            -- Fallback
            table.insert(linksToShow, { Name = "Discord", URL = "https://discord.gg/nexzanhub" })
            table.insert(linksToShow, { Name = "Work.ink", URL = "https://work.ink/nexzankey" })
        end

        for i, linkData in ipairs(linksToShow) do
            local item = Instance.new("TextButton", DropdownHolder)
            item.Name = "DropdownItem_" .. i
            item.LayoutOrder = i
            item.Size = UDim2.new(0.92, 0, 0, isCompact and 32 or 38)
            item.BackgroundColor3 = colors.surface2
            item.AutoButtonColor = false
            item.Text = ""
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, isCompact and 6 or 8)
            local itemStroke = Instance.new("UIStroke", item)
            itemStroke.Color = colors.border
            itemStroke.Thickness = 1

            local itemLayout = Instance.new("UIListLayout", item)
            itemLayout.FillDirection = Enum.FillDirection.Horizontal
            itemLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            itemLayout.Padding = UDim.new(0, isCompact and 6 or 8)
            local itemPad = Instance.new("UIPadding", item)
            itemPad.PaddingLeft = UDim.new(0, isCompact and 8 or 12)

            local itemIcon = Instance.new("TextLabel", item)
            itemIcon.Size = UDim2.fromOffset(isCompact and 16 or 20, isCompact and 16 or 20)
            itemIcon.BackgroundTransparency = 1
            itemIcon.Text = "🔗"
            itemIcon.TextSize = isCompact and 12 or 14

            local itemNameFrame = Instance.new("Frame", item)
            itemNameFrame.Size = UDim2.new(1, -(isCompact and 40 or 50), 1, 0)
            itemNameFrame.BackgroundTransparency = 1

            local itemName = Instance.new("TextLabel", itemNameFrame)
            itemName.Size = UDim2.new(1, 0, 0, 16)
            itemName.BackgroundTransparency = 1
            itemName.Text = linkData.Name
            itemName.TextColor3 = colors.text
            itemName.Font = Enum.Font.GothamBold
            itemName.TextSize = isCompact and 11 or 13
            itemName.TextXAlignment = Enum.TextXAlignment.Left

            local itemUrl = Instance.new("TextLabel", itemNameFrame)
            itemUrl.Size = UDim2.new(1, 0, 0, 12)
            itemUrl.Position = UDim2.new(0, 0, 0, 16)
            itemUrl.BackgroundTransparency = 1
            local urlDisplay = linkData.URL:gsub("^https?://", "")
            if #urlDisplay > 25 then urlDisplay = urlDisplay:sub(1, 22) .. "..." end
            itemUrl.Text = urlDisplay
            itemUrl.TextColor3 = colors.textMuted
            itemUrl.Font = Enum.Font.Gotham
            itemUrl.TextSize = isCompact and 8 or 10
            itemUrl.TextXAlignment = Enum.TextXAlignment.Left

            local itemArrow = Instance.new("TextLabel", item)
            itemArrow.Size = UDim2.fromOffset(isCompact and 16 or 20, isCompact and 16 or 20)
            itemArrow.BackgroundTransparency = 1
            itemArrow.Text = "→"
            itemArrow.TextColor3 = colors.textDim
            itemArrow.TextSize = isCompact and 14 or 16

            -- Hover
            item.MouseEnter:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(36, 36, 50)
                }):Play()
                itemStroke.Color = colors.accent
                itemStroke.Transparency = 0.5
            end)
            item.MouseLeave:Connect(function()
                TweenService:Create(item, TweenInfo.new(0.15), {
                    BackgroundColor3 = colors.surface2
                }):Play()
                itemStroke.Color = colors.border
                itemStroke.Transparency = 0
            end)

            -- Click: copy link
            item.MouseButton1Click:Connect(function()
                local copied = CopyToClipboard(linkData.URL)
                if copied then
                    SetStatus("✓ Copied: " .. linkData.Name, colors.success)
                    ShowToast(ScreenGui, "✓ Copied!", linkData.Name .. " link copied!", 2, colors.accent)
                    -- Open browser
                    pcall(function()
                        local gs = game:GetService("GuiService")
                        if gs and gs.OpenBrowserWindow then
                            gs:OpenBrowserWindow(linkData.URL)
                        end
                    end)
                else
                    SetStatus("⚠ Manual copy: " .. linkData.URL:sub(1, 30), colors.warning)
                    ShowToast(ScreenGui, "⚠ Copy Manual", linkData.URL:sub(1, 40), 3.5, colors.warning)
                end

                -- Close dropdown
                DropdownHolder.Visible = false
                GetKeySubLbl.Text = "▼ Tap to choose link"
                TweenService:Create(DropdownHolder, TweenInfo.new(0.15), {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
            end)
        end
    end

    -- ===== VERIFY CLICK =====
    VerifyBtn.MouseButton1Click:Connect(function()
        local input = TextBox.Text
        if input == "" then
            SetStatus("⚠ Enter a key first!", colors.warning)
            return
        end
        if ValidateKey(input) then
            OnSuccess(input)
        else
            OnFail()
        end
    end)

    -- Enter key
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = TextBox.Text
            if input ~= "" then
                if ValidateKey(input) then
                    OnSuccess(input)
                else
                    OnFail()
                end
            end
        end
    end)

    -- Reset button: clear input
    ResetBtn.MouseButton1Click:Connect(function()
        TextBox.Text = ""
        SetStatus("", colors.text)
        ShowToast(ScreenGui, "↺ Cleared", "Input has been reset", 1.5, colors.textDim)
    end)

    -- Click overlay = close dropdown (kalo multi mode)
    Overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if DropdownHolder and DropdownHolder.Visible then
                DropdownHolder.Visible = false
                GetKeySubLbl.Text = "▼ Tap to choose link"
                TweenService:Create(DropdownHolder, TweenInfo.new(0.15), {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
            end
        end
    end)

    -- ===== ANIMASI MASUK =====
    Main.Size = UDim2.fromOffset(W - 20, 0)
    Main.BackgroundTransparency = 0.3
    Overlay.BackgroundTransparency = 1
    Main.Position = UDim2.new(0.5, -(W/2), 0.5, -20)

    task.wait(0.05)

    -- Smooth enter
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(W, H),
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    }):Play()

    TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.45
    }):Play()

    -- Pulse border glow
    coroutine.wrap(function()
        while Main and Main.Parent do
            for i = 0.5, 0.1, -0.05 do
                if not Main or not Main.Parent then return end
                BorderStroke.Transparency = i
                task.wait(0.03)
            end
            for i = 0.1, 0.5, 0.05 do
                if not Main or not Main.Parent then return end
                BorderStroke.Transparency = i
                task.wait(0.03)
            end
        end
    end)()

    -- ===== RETURN CONTROLLER =====
    local controller = {
        Gui = ScreenGui,
        Main = Main,
        TextBox = TextBox,
        Status = StatusLbl,
        VerifyBtn = VerifyBtn,
        GetKeyBtn = GetKeyBtn,
        Dropdown = DropdownHolder,
        Mode = Mode,

        SetStatus = function(_, text, color)
            SetStatus(text, color)
        end,

        Destroy = function()
            ScreenGui:Destroy()
        end,

        Show = function()
            ScreenGui.Enabled = true
            TweenService:Create(Main, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
        end,

        Hide = function()
            TweenService:Create(Main, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            ScreenGui.Enabled = false
        end,
    }

    return controller
end

-- ================================================================ --
-- EXPORT
-- ================================================================ --
return NexzanKeyUI
