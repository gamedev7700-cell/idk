-- Place this as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- CREATE EVENTS IF MISSING
local FireEvent = ReplicatedStorage:FindFirstChild("FireEvent")
if not FireEvent then
	FireEvent = Instance.new("RemoteEvent")
	FireEvent.Name = "FireEvent"
	FireEvent.Parent = ReplicatedStorage
end

local ToggleHeadshot = ReplicatedStorage:FindFirstChild("ToggleHeadshot")
if not ToggleHeadshot then
	ToggleHeadshot = Instance.new("RemoteEvent")
	ToggleHeadshot.Name = "ToggleHeadshot"
	ToggleHeadshot.Parent = ReplicatedStorage
end

-- ======================
-- STATES
-- ======================
local highlightOn = true
local headshotOn = true

-- ======================
-- GUI SETUP
-- ======================
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Highlight button
local highlightBtn = Instance.new("TextButton", frame)
highlightBtn.Size = UDim2.new(1, -10, 0, 40)
highlightBtn.Position = UDim2.new(0,5,0,10)
highlightBtn.Text = "Highlight: ON"

-- Headshot button
local headshotBtn = Instance.new("TextButton", frame)
headshotBtn.Size = UDim2.new(1, -10, 0, 40)
headshotBtn.Position = UDim2.new(0,5,0,60)
headshotBtn.Text = "Headshot: ON"

-- ======================
-- HIGHLIGHT LOGIC
-- ======================
local function addHighlight(character)
	if character:FindFirstChild("Highlight") then return end
	local h = Instance.new("Highlight")
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = Color3.fromRGB(255,0,0)
	h.Parent = character
end

local function removeHighlight(character)
	local h = character:FindFirstChild("Highlight")
	if h then h:Destroy() end
end

local function updateHighlights()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			if highlightOn then
				addHighlight(p.Character)
			else
				removeHighlight(p.Character)
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.5)
		updateHighlights()
	end
end)

-- ======================
-- BUTTON EVENTS
-- ======================
highlightBtn.MouseButton1Click:Connect(function()
	highlightOn = not highlightOn
	highlightBtn.Text = "Highlight: " .. (highlightOn and "ON" or "OFF")
end)

headshotBtn.MouseButton1Click:Connect(function()
	headshotOn = not headshotOn
	headshotBtn.Text = "Headshot: " .. (headshotOn and "ON" or "OFF")
	ToggleHeadshot:FireServer(headshotOn)
end)

-- ======================
-- SHOOTING SYSTEM
-- ======================
script.Parent.Activated:Connect(function()
	if mouse.Target then
		FireEvent:FireServer(mouse.Target)
	end
end)

-- ======================
-- SERVER SCRIPT (Put in ServerScriptService)
-- ======================
--[[

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FireEvent = ReplicatedStorage:WaitForChild("FireEvent")
local ToggleHeadshot = ReplicatedStorage:WaitForChild("ToggleHeadshot")

local headshotEnabled = {}
local BASE_DAMAGE = 20
local HEADSHOT_MULTIPLIER = 2

ToggleHeadshot.OnServerEvent:Connect(function(player,state)
	headshotEnabled[player] = state
end)

FireEvent.OnServerEvent:Connect(function(player, hitPart)
	if not hitPart then return end
	local character = hitPart:FindFirstAncestorOfClass("Model")
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local damage = BASE_DAMAGE
	if headshotEnabled[player] then
		damage = BASE_DAMAGE * HEADSHOT_MULTIPLIER
	end

	humanoid:TakeDamage(damage)
end)

]]
