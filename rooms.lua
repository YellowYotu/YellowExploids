-- SERVICES --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- INFO --

local VERSION = "v2.0.2 Manual Assist"
local AUTHOR = "Yell00clidd"

-- CLEANUP OLD INSTANCE --

local env = getgenv and getgenv() or _G

if env.Yell00ManualAssistCleanup then
	pcall(env.Yell00ManualAssistCleanup)
end

local running = true
local connections = {}

local function addConnection(connection)
	table.insert(connections, connection)
	return connection
end

-- PLAYER --

local player = Players.LocalPlayer
local character
local humanoid
local root

local function updateCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
end

updateCharacter()

addConnection(player.CharacterAdded:Connect(function()
	task.wait(0.5)
	updateCharacter()
end))

-- GAME DATA --

local currentRooms = workspace:WaitForChild("CurrentRooms")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local latestRoom = gameData:WaitForChild("LatestRoom")
local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")
local a90Remote = remotesFolder:WaitForChild("A90")

-- SETTINGS --

local speedBoost = 0

local fullbrightEnabled = true
local antiAFKEnabled = true
local roomHudEnabled = true
local monsterWarningEnabled = true
local monsterESPEnabled = true
local lockerESPEnabled = true
local nearestLockerEnabled = true
local a90FreezeEnabled = true
local warningSoundEnabled = true

local originalAmbient = Lighting.Ambient

-- A90 --

local A90_FREEZE_TIME = 2
local a90ActiveUntil = 0

local ACTION_NAME = "Yell00A90Freeze"
local CAMERA_FREEZE_NAME = "Yell00A90CameraFreeze"

local frozenCameraCFrame = nil
local previousMouseBehavior = nil
local previousMouseIconEnabled = nil

local function isA90Active()
	return os.clock() < a90ActiveUntil
end

local function stopPlayerMovement()
	if not root then
		return
	end

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

-- GUI PARENT --

local guiParent = CoreGui

if gethui then
	local success, result = pcall(gethui)

	if success and result then
		guiParent = result
	end
end

local oldGui = guiParent:FindFirstChild("Yell00ManualAssist")

if oldGui then
	oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Yell00ManualAssist"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

-- COLORS --

local backgroundColor = Color3.fromRGB(15, 17, 23)
local cardColor = Color3.fromRGB(24, 27, 36)
local textColor = Color3.fromRGB(245, 245, 250)
local subTextColor = Color3.fromRGB(145, 155, 180)
local accentColor = Color3.fromRGB(75, 115, 235)
local dangerColor = Color3.fromRGB(220, 55, 65)
local safeColor = Color3.fromRGB(65, 200, 120)

-- MAIN WINDOW --

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(520, 470)
window.Position = UDim2.new(0.5, -260, 0.5, -235)
window.BackgroundColor3 = backgroundColor
window.BorderSizePixel = 0
window.Active = true
window.ZIndex = 20
window.Parent = gui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 14)
windowCorner.Parent = window

local windowStroke = Instance.new("UIStroke")
windowStroke.Color = Color3.fromRGB(70, 78, 105)
windowStroke.Transparency = 0.35
windowStroke.Parent = window

-- TITLE --

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 64)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.ZIndex = 21
titleBar.Parent = window

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 28)
title.Position = UDim2.fromOffset(18, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextColor3 = textColor
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Rooms Manual Assist"
title.ZIndex = 22
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -110, 0, 18)
subtitle.Position = UDim2.fromOffset(18, 36)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = subTextColor
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = VERSION .. " • " .. AUTHOR
subtitle.ZIndex = 22
subtitle.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.Position = UDim2.new(1, -48, 0, 14)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 28, 34)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "×"
closeButton.TextSize = 22
closeButton.TextColor3 = Color3.fromRGB(255, 125, 135)
closeButton.ZIndex = 30
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- DRAG --

local dragging = false
local dragStart
local dragOrigin

addConnection(titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		dragOrigin = window.Position
	end
end))

addConnection(UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragStart

	window.Position = UDim2.new(
		dragOrigin.X.Scale,
		dragOrigin.X.Offset + delta.X,
		dragOrigin.Y.Scale,
		dragOrigin.Y.Offset + delta.Y
	)
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end))

-- SIDEBAR --

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 125, 1, -78)
sidebar.Position = UDim2.fromOffset(10, 70)
sidebar.BackgroundColor3 = Color3.fromRGB(19, 21, 28)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 21
sidebar.Parent = window

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 10)
sidebarCorner.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -155, 1, -86)
content.Position = UDim2.fromOffset(145, 74)
content.BackgroundTransparency = 1
content.ZIndex = 21
content.Parent = window

local pages = {}
local tabs = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(90, 100, 130)
	page.CanvasSize = UDim2.new()
	page.Visible = false
	page.ZIndex = 22
	page.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 9)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	addConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 15)
	end))

	pages[name] = page

	return page
end

local function selectPage(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	for tabName, button in pairs(tabs) do
		button.BackgroundColor3 = tabName == name and Color3.fromRGB(40, 47, 67) or Color3.fromRGB(19, 21, 28)
		button.TextColor3 = tabName == name and textColor or subTextColor
	end
end

local function createTab(name, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, 44)
	button.Position = UDim2.fromOffset(6, y)
	button.BackgroundColor3 = Color3.fromRGB(19, 21, 28)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.TextColor3 = subTextColor
	button.Text = name
	button.ZIndex = 25
	button.Parent = sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	addConnection(button.MouseButton1Click:Connect(function()
		selectPage(name)
	end))

	tabs[name] = button
end

local mainPage = createPage("Main")
local visualsPage = createPage("Visuals")
local safetyPage = createPage("Safety")
local infoPage = createPage("Info")

createTab("Main", 8)
createTab("Visuals", 58)
createTab("Safety", 108)
createTab("Info", 158)

selectPage("Main")

-- COMPONENTS --

local function createHeader(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -5, 0, 24)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = subTextColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.ZIndex = 23
	label.Parent = parent
end

local function createToggle(parent, text, description, default, callback)
	local value = default

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -5, 0, 67)
	frame.BackgroundColor3 = cardColor
	frame.BorderSizePixel = 0
	frame.ZIndex = 23
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 0, 22)
	label.Position = UDim2.fromOffset(12, 8)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = textColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.ZIndex = 24
	label.Parent = frame

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -80, 0, 27)
	desc.Position = UDim2.fromOffset(12, 33)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 10
	desc.TextColor3 = subTextColor
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Text = description
	desc.ZIndex = 24
	desc.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(52, 28)
	button.Position = UDim2.new(1, -64, 0.5, -14)
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.ZIndex = 30
	button.Parent = frame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(1, 0)
	buttonCorner.Parent = button

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(22, 22)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
	knob.BorderSizePixel = 0
	knob.ZIndex = 31
	knob.Parent = button

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local function refresh()
		if value then
			button.BackgroundColor3 = accentColor
			knob.Position = UDim2.fromOffset(27, 3)
		else
			button.BackgroundColor3 = Color3.fromRGB(52, 57, 70)
			knob.Position = UDim2.fromOffset(3, 3)
		end
	end

	addConnection(button.MouseButton1Click:Connect(function()
		value = not value
		refresh()
		callback(value)
	end))

	refresh()
end

local function createNumberControl(parent, text, description, default, callback)
	local value = default

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -5, 0, 92)
	frame.BackgroundColor3 = cardColor
	frame.BorderSizePixel = 0
	frame.ZIndex = 23
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 22)
	label.Position = UDim2.fromOffset(12, 7)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = textColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.ZIndex = 24
	label.Parent = frame

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -24, 0, 18)
	desc.Position = UDim2.fromOffset(12, 30)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 10
	desc.TextColor3 = subTextColor
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Text = description
	desc.ZIndex = 24
	desc.Parent = frame

	local minus = Instance.new("TextButton")
	minus.Size = UDim2.fromOffset(42, 34)
	minus.Position = UDim2.fromOffset(12, 51)
	minus.BackgroundColor3 = Color3.fromRGB(39, 43, 55)
	minus.BorderSizePixel = 0
	minus.Font = Enum.Font.GothamBold
	minus.TextSize = 19
	minus.TextColor3 = textColor
	minus.Text = "-"
	minus.ZIndex = 30
	minus.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -132, 0, 34)
	box.Position = UDim2.fromOffset(60, 51)
	box.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
	box.BorderSizePixel = 0
	box.Font = Enum.Font.GothamBold
	box.TextSize = 14
	box.TextColor3 = textColor
	box.Text = tostring(value)
	box.ClearTextOnFocus = false
	box.ZIndex = 31
	box.Parent = frame

	local plus = Instance.new("TextButton")
	plus.Size = UDim2.fromOffset(42, 34)
	plus.Position = UDim2.new(1, -54, 0, 51)
	plus.BackgroundColor3 = Color3.fromRGB(39, 43, 55)
	plus.BorderSizePixel = 0
	plus.Font = Enum.Font.GothamBold
	plus.TextSize = 19
	plus.TextColor3 = textColor
	plus.Text = "+"
	plus.ZIndex = 30
	plus.Parent = frame

	for _, item in ipairs({minus, box, plus}) do
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 8)
		itemCorner.Parent = item
	end

	local function apply(newValue)
		value = math.max(0, tonumber(newValue) or 0)
		box.Text = tostring(value)
		callback(value)
	end

	addConnection(minus.MouseButton1Click:Connect(function()
		apply(value - 1)
	end))

	addConnection(plus.MouseButton1Click:Connect(function()
		apply(value + 1)
	end))

	addConnection(box.FocusLost:Connect(function()
		apply(box.Text)
	end))
end

-- MAIN --

createHeader(mainPage, "PLAYER")

createNumberControl(mainPage, "Speed Boost", "Manual movement speed boost.", 0, function(value)
	speedBoost = value
end)

createToggle(mainPage, "Fullbright", "Makes the Rooms fully visible.", true, function(value)
	fullbrightEnabled = value

	if not value then
		Lighting.Ambient = originalAmbient
	end
end)

createToggle(mainPage, "Anti-AFK", "Prevents the idle kick.", true, function(value)
	antiAFKEnabled = value
end)

createToggle(mainPage, "Room HUD", "Shows current room, monster and nearest locker.", true, function(value)
	roomHudEnabled = value
end)

-- VISUALS --

createHeader(visualsPage, "ESP")

createToggle(visualsPage, "Monster ESP", "Highlights A60/A120 and shows distance.", true, function(value)
	monsterESPEnabled = value
end)

createToggle(visualsPage, "Locker ESP", "Highlights available lockers.", true, function(value)
	lockerESPEnabled = value
end)

createToggle(visualsPage, "Nearest Locker", "Strongly highlights the nearest free locker.", true, function(value)
	nearestLockerEnabled = value
end)

createToggle(visualsPage, "Warnings", "Shows A60/A90/A120 warning overlay.", true, function(value)
	monsterWarningEnabled = value
end)

-- SAFETY --

createHeader(safetyPage, "A90")

createToggle(safetyPage, "A90 Freeze", "Freezes movement and camera for 2 seconds.", true, function(value)
	a90FreezeEnabled = value

	if not value then
		pcall(function()
			ContextActionService:UnbindAction(ACTION_NAME)
		end)

		pcall(function()
			RunService:UnbindFromRenderStep(CAMERA_FREEZE_NAME)
		end)
	end
end)

createToggle(safetyPage, "Warning Sound", "Plays a loud warning when a monster appears.", true, function(value)
	warningSoundEnabled = value
end)

-- INFO --

createHeader(infoPage, "RUN MODE")

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -5, 0, 255)
info.BackgroundColor3 = cardColor
info.BorderSizePixel = 0
info.Font = Enum.Font.Gotham
info.TextSize = 13
info.TextColor3 = Color3.fromRGB(215, 220, 235)
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Text =
	"\n   MANUAL MODE\n\n" ..
	"   No Auto Walk\n" ..
	"   No CFrame flight\n" ..
	"   No automatic locker entry\n" ..
	"   No gravity/collision changes\n\n" ..
	"   A60/A120: ESP + live distance\n" ..
	"   A90: RemoteEvent + 2 sec full freeze\n" ..
	"   Lockers: ESP + nearest locker\n" ..
	"   Warning volume: 10\n\n" ..
	"   RightShift: hide/show menu"
info.ZIndex = 24
info.Parent = infoPage

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 10)
infoCorner.Parent = info

-- ROOM HUD --

local hud = Instance.new("Frame")
hud.Size = UDim2.fromOffset(280, 92)
hud.Position = UDim2.new(0, 18, 1, -112)
hud.BackgroundColor3 = backgroundColor
hud.BackgroundTransparency = 0.06
hud.BorderSizePixel = 0
hud.ZIndex = 80
hud.Parent = gui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hud

local hudRoom = Instance.new("TextLabel")
hudRoom.Size = UDim2.new(1, -16, 0, 24)
hudRoom.Position = UDim2.fromOffset(8, 6)
hudRoom.BackgroundTransparency = 1
hudRoom.Font = Enum.Font.GothamBold
hudRoom.TextSize = 18
hudRoom.TextColor3 = textColor
hudRoom.TextXAlignment = Enum.TextXAlignment.Left
hudRoom.Text = "Room A-" .. tostring(latestRoom.Value)
hudRoom.ZIndex = 81
hudRoom.Parent = hud

local hudLocker = Instance.new("TextLabel")
hudLocker.Size = UDim2.new(1, -16, 0, 20)
hudLocker.Position = UDim2.fromOffset(8, 34)
hudLocker.BackgroundTransparency = 1
hudLocker.Font = Enum.Font.Gotham
hudLocker.TextSize = 12
hudLocker.TextColor3 = Color3.fromRGB(115, 195, 255)
hudLocker.TextXAlignment = Enum.TextXAlignment.Left
hudLocker.Text = "Nearest locker: --"
hudLocker.ZIndex = 81
hudLocker.Parent = hud

local hudMonster = Instance.new("TextLabel")
hudMonster.Size = UDim2.new(1, -16, 0, 20)
hudMonster.Position = UDim2.fromOffset(8, 58)
hudMonster.BackgroundTransparency = 1
hudMonster.Font = Enum.Font.GothamBold
hudMonster.TextSize = 12
hudMonster.TextColor3 = safeColor
hudMonster.TextXAlignment = Enum.TextXAlignment.Left
hudMonster.Text = "Monster: SAFE"
hudMonster.ZIndex = 81
hudMonster.Parent = hud

-- WARNING --

local warning = Instance.new("Frame")
warning.Size = UDim2.fromOffset(470, 110)
warning.AnchorPoint = Vector2.new(0.5, 0)
warning.Position = UDim2.new(0.5, 0, 0, -140)
warning.BackgroundColor3 = Color3.fromRGB(78, 18, 24)
warning.BorderSizePixel = 0
warning.Visible = false
warning.ZIndex = 200
warning.Parent = gui

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 12)
warningCorner.Parent = warning

local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.fromScale(1, 1)
warningText.BackgroundTransparency = 1
warningText.Font = Enum.Font.GothamBold
warningText.TextSize = 18
warningText.TextColor3 = Color3.fromRGB(255, 235, 238)
warningText.TextWrapped = true
warningText.ZIndex = 201
warningText.Parent = warning

local warningVisible = false

local function showWarning(text)
	if not monsterWarningEnabled then
		return
	end

	warningText.Text = text

	if warningVisible then
		return
	end

	warningVisible = true
	warning.Visible = true

	TweenService:Create(warning, TweenInfo.new(0.15), {
		Position = UDim2.new(0.5, 0, 0, 22),
	}):Play()
end

local function hideWarning()
	if not warningVisible then
		return
	end

	warningVisible = false

	TweenService:Create(warning, TweenInfo.new(0.15), {
		Position = UDim2.new(0.5, 0, 0, -140),
	}):Play()

	task.delay(0.18, function()
		if not warningVisible then
			warning.Visible = false
		end
	end)
end

-- SOUND --

local warningSound = Instance.new("Sound")
warningSound.Name = "RoomsAssistWarning"
warningSound.SoundId = "rbxassetid://550209561"
warningSound.Volume = 10
warningSound.Parent = gui

local lastSoundTime = 0

local function playWarningSound()
	if not warningSoundEnabled then
		return
	end

	if os.clock() - lastSoundTime < 1 then
		return
	end

	lastSoundTime = os.clock()

	pcall(function()
		warningSound:Play()
	end)
end

-- ESP --

local espObjects = {}

local function getVisualPart(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if not instance:IsA("Model") then
		return nil
	end

	local main = instance:FindFirstChild("Main")

	if main and main:IsA("BasePart") then
		return main
	end

	local door = instance:FindFirstChild("Door", true)

	if door and door:IsA("BasePart") then
		return door
	end

	local base = instance:FindFirstChild("Base", true)

	if base and base:IsA("BasePart") then
		return base
	end

	return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
end

local function removeESP(instance)
	local data = espObjects[instance]

	if not data then
		return
	end

	pcall(function()
		data.highlight:Destroy()
	end)

	pcall(function()
		data.billboard:Destroy()
	end)

	espObjects[instance] = nil
end

local function createESP(instance, name, color)
	local existing = espObjects[instance]

	if existing then
		return existing
	end

	local part = getVisualPart(instance)

	if not part then
		return nil
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color
	highlight.FillTransparency = 0.72
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0.05
	highlight.Parent = gui

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(200, 36)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = name
	label.Parent = billboard

	local labelCorner = Instance.new("UICorner")
	labelCorner.CornerRadius = UDim.new(0, 7)
	labelCorner.Parent = label

	local data = {
		highlight = highlight,
		billboard = billboard,
		label = label,
		part = part,
		name = name,
	}

	espObjects[instance] = data

	return data
end

-- LOCKERS --

local nearestLocker = nil

local function getNearestLocker()
	if not root then
		return nil
	end

	local closest = nil
	local closestDistance = math.huge

	for _, instance in ipairs(currentRooms:GetDescendants()) do
		if instance.Name ~= "Rooms_Locker" then
			continue
		end

		local hiddenPlayer = instance:FindFirstChild("HiddenPlayer")
		local base = instance:FindFirstChild("Base")
		local door = instance:FindFirstChild("Door")

		local part = base or door

		if not part or not part:IsA("BasePart") then
			continue
		end

		if part.Position.Y <= -3 then
			continue
		end

		if hiddenPlayer and hiddenPlayer.Value then
			continue
		end

		local distance = (root.Position - part.Position).Magnitude

		if distance < closestDistance then
			closestDistance = distance
			closest = instance
		end
	end

	return closest, closestDistance
end

-- VISUAL UPDATE --

local lastMonsterState = nil

local function updateVisuals()
	if not root then
		return
	end

	local seen = {}

	local locker, lockerDistance = getNearestLocker()
	nearestLocker = locker

	if locker then
		hudLocker.Text = "Nearest locker: " .. math.floor(lockerDistance) .. " studs"
	else
		hudLocker.Text = "Nearest locker: --"
	end

	if lockerESPEnabled then
		for _, instance in ipairs(currentRooms:GetDescendants()) do
			if instance.Name ~= "Rooms_Locker" then
				continue
			end

			local hiddenPlayer = instance:FindFirstChild("HiddenPlayer")

			if hiddenPlayer and hiddenPlayer.Value then
				continue
			end

			local data = createESP(instance, "LOCKER", Color3.fromRGB(65, 160, 255))

			if data then
				seen[instance] = true

				local distance = (root.Position - data.part.Position).Magnitude

				data.label.Text = "LOCKER • " .. math.floor(distance) .. " studs"

				if nearestLockerEnabled and instance == nearestLocker then
					data.highlight.FillTransparency = 0.25
					data.highlight.OutlineTransparency = 0
					data.label.Text = "★ NEAREST LOCKER • " .. math.floor(distance) .. " studs"
				else
					data.highlight.FillTransparency = 0.78
					data.highlight.OutlineTransparency = 0.05
				end
			end
		end
	end

	local nearestMonsterName = nil
	local nearestMonsterDistance = math.huge

	for _, monsterName in ipairs({"A60", "A120"}) do
		local monster = workspace:FindFirstChild(monsterName)

		if monster then
			local part = getVisualPart(monster)

			if part then
				local distance = (root.Position - part.Position).Magnitude

				if distance < nearestMonsterDistance then
					nearestMonsterName = monsterName
					nearestMonsterDistance = distance
				end

				if monsterESPEnabled then
					local data = createESP(monster, monsterName, Color3.fromRGB(255, 60, 70))

					if data then
						seen[monster] = true
						data.label.Text = monsterName .. " • " .. math.floor(distance) .. " studs"
					end
				end
			end
		end
	end

	for instance in pairs(espObjects) do
		if not seen[instance] then
			removeESP(instance)
		end
	end

	if isA90Active() then
		hudMonster.Text = "Monster: A90"
		hudMonster.TextColor3 = dangerColor
		return
	end

	if nearestMonsterName then
		hudMonster.Text =
			"Monster: " ..
			nearestMonsterName ..
			" • " ..
			math.floor(nearestMonsterDistance) ..
			" studs"

		hudMonster.TextColor3 = dangerColor

		showWarning(
			nearestMonsterName ..
				" INCOMING\nMonster distance: " ..
				math.floor(nearestMonsterDistance) ..
				" studs\nNearest locker: " ..
				(locker and math.floor(lockerDistance) .. " studs" or "NOT FOUND")
		)

		if lastMonsterState ~= nearestMonsterName then
			playWarningSound()
		end

		lastMonsterState = nearestMonsterName
	else
		hudMonster.Text = "Monster: SAFE"
		hudMonster.TextColor3 = safeColor

		lastMonsterState = nil
		hideWarning()
	end
end

-- A90 FULL FREEZE --

local function sinkA90Input()
	return Enum.ContextActionResult.Sink
end

local function disableA90Freeze()
	pcall(function()
		ContextActionService:UnbindAction(ACTION_NAME)
	end)

	pcall(function()
		RunService:UnbindFromRenderStep(CAMERA_FREEZE_NAME)
	end)

	if previousMouseBehavior then
		pcall(function()
			UserInputService.MouseBehavior = previousMouseBehavior
		end)
	end

	if previousMouseIconEnabled ~= nil then
		pcall(function()
			UserInputService.MouseIconEnabled = previousMouseIconEnabled
		end)
	end

	frozenCameraCFrame = nil
	previousMouseBehavior = nil
	previousMouseIconEnabled = nil
end

local function enableA90Freeze()
	disableA90Freeze()

	local camera = workspace.CurrentCamera

	if camera then
		frozenCameraCFrame = camera.CFrame
	end

	previousMouseBehavior = UserInputService.MouseBehavior
	previousMouseIconEnabled = UserInputService.MouseIconEnabled

	ContextActionService:BindActionAtPriority(
		ACTION_NAME,
		sinkA90Input,
		false,
		999999,
		Enum.PlayerActions.CharacterForward,
		Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft,
		Enum.PlayerActions.CharacterRight,
		Enum.PlayerActions.CharacterJump,
		Enum.UserInputType.MouseMovement
	)

	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end)

	RunService:BindToRenderStep(
		CAMERA_FREEZE_NAME,
		Enum.RenderPriority.Camera.Value + 100,
		function()
			if not running or not a90FreezeEnabled or not isA90Active() then
				return
			end

			stopPlayerMovement()

			local currentCamera = workspace.CurrentCamera

			if currentCamera and frozenCameraCFrame then
				currentCamera.CFrame = frozenCameraCFrame
			end
		end
	)
end

addConnection(a90Remote.OnClientEvent:Connect(function()
	a90ActiveUntil = os.clock() + A90_FREEZE_TIME

	playWarningSound()
	showWarning("A90 DETECTED\nDO NOT MOVE OR LOOK • 2 SECOND FREEZE")

	if a90FreezeEnabled then
		enableA90Freeze()
		stopPlayerMovement()
	end

	task.delay(A90_FREEZE_TIME, function()
		if not running then
			return
		end

		if not isA90Active() then
			disableA90Freeze()

			if not workspace:FindFirstChild("A60") and not workspace:FindFirstChild("A120") then
				hideWarning()
			end
		end
	end)
end))

-- ANTI AFK --

addConnection(player.Idled:Connect(function()
	if not antiAFKEnabled then
		return
	end

	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end))

-- ROOM --

addConnection(latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
	hudRoom.Text = "Room A-" .. tostring(latestRoom.Value)
end))

-- GUI HOTKEY --

addConnection(UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		window.Visible = not window.Visible
	end
end))

-- MAIN LOOP --

local lastVisualUpdate = 0

addConnection(RunService.RenderStepped:Connect(function()
	if not running then
		return
	end

	if fullbrightEnabled then
		Lighting.Ambient = Color3.new(1, 1, 1)
	end

	if character then
		character:SetAttribute("SpeedBoost", speedBoost)
	end

	hud.Visible = roomHudEnabled

	if isA90Active() and a90FreezeEnabled then
		stopPlayerMovement()
	end

	if os.clock() - lastVisualUpdate >= 0.1 then
		lastVisualUpdate = os.clock()
		updateVisuals()
	end
end))

-- CLEANUP --

env.Yell00ManualAssistCleanup = function()
	if not running then
		return
	end

	running = false

	disableA90Freeze()

	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	for instance in pairs(espObjects) do
		removeESP(instance)
	end

	if character then
		character:SetAttribute("SpeedBoost", 0)
	end

	Lighting.Ambient = originalAmbient

	if gui then
		gui:Destroy()
	end

	env.Yell00ManualAssistCleanup = nil

	print("Rooms Manual Assist removed")
end

addConnection(closeButton.MouseButton1Click:Connect(function()
	env.Yell00ManualAssistCleanup()
end))

print("Rooms Manual Assist loaded")
print("Version:", VERSION)
print("Warning volume: 10")
print("A90 movement + camera freeze: 2 seconds")
print("RightShift = hide/show menu")
