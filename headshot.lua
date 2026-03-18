-- LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- =====================
-- SETTINGS
-- =====================
local BASE_DAMAGE = 67
local HEADSHOT_MULTIPLIER = 2
local OUTLINE_COLOR = Color3.fromRGB(255,0,0)

local headshotOn = true
local highlightOn = true

-- =====================
-- GUI (Mobile-Friendly)
-- =====================
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

-- Highlight button
local highlightBtn = Instance.new("TextButton", frame)
highlightBtn.Size = UDim2.new(1,-20,0,60)
highlightBtn.Position = UDim2.new(0,10,0,10)
highlightBtn.Text = "Highlight: ON"
highlightBtn.TextScaled = true
highlightBtn.AutoButtonColor = true

-- Headshot button
local headshotBtn = Instance.new("TextButton", frame)
headshotBtn.Size = UDim2.new(1,-20,0,60)
headshotBtn.Position = UDim2.new(0,10,0,70)
headshotBtn.Text = "Headshot: ON"
headshotBtn.TextScaled = true
headshotBtn.AutoButtonColor = true

-- =====================
-- HIGHLIGHT SYSTEM
-- =====================
local function addHighlight(character)
	if not character or character:FindFirstChild("Highlight") then return end
	local h = Instance.new("Highlight")
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = OUTLINE_COLOR
	h.Parent = character
end

local function removeHighlight(character)
	if not character then return end
	local h = character:FindFirstChild("Highlight")
	if h then h:Destroy() end
end

RunService.Heartbeat:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			if highlightOn then
				addHighlight(p.Character)
			else
				removeHighlight(p.Character)
			end
		end
	end
end)

-- =====================
-- GUI BUTTON EVENTS
-- =====================
highlightBtn.MouseButton1Click:Connect(function()
	highlightOn = not highlightOn
	highlightBtn.Text = "Highlight: "..(highlightOn and "ON" or "OFF")
end)

headshotBtn.MouseButton1Click:Connect(function()
	headshotOn = not headshotOn
	headshotBtn.Text = "Headshot: "..(headshotOn and "ON" or "OFF")
end)

-- =====================
-- AUTO HEADSHOT FUNCTION
-- =====================
local function autoHeadshot(targetPart)
	if not targetPart or not headshotOn then return end
	local character = targetPart:FindFirstAncestorOfClass("Model")
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or not head then return end

	humanoid:TakeDamage(BASE_DAMAGE * HEADSHOT_MULTIPLIER)
end

-- =====================
-- SHOOTING INPUT (PC + Mobile)
-- =====================
-- PC: left click
mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target then
		autoHeadshot(target)
	end
end)

-- Mobile: touch screen
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Touch then
		local target = mouse.Target
		if target then
			autoHeadshot(target)
		end
	end
end)
