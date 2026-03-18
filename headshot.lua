-- Put this in StarterPlayerScripts (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Create RemoteEvents if missing
local FireEvent = ReplicatedStorage:FindFirstChild("FireEvent") or Instance.new("RemoteEvent")
FireEvent.Name = "FireEvent"
FireEvent.Parent = ReplicatedStorage

local ToggleHeadshot = ReplicatedStorage:FindFirstChild("ToggleHeadshot") or Instance.new("RemoteEvent")
ToggleHeadshot.Name = "ToggleHeadshot"
ToggleHeadshot.Parent = ReplicatedStorage

-- =====================
-- SETTINGS
-- =====================
local highlightOn = true
local headshotOn = true
local BASE_DAMAGE = 20
local HEADSHOT_MULTIPLIER = 2
local OUTLINE_COLOR = Color3.fromRGB(255,0,0)

-- =====================
-- GUI
-- =====================
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0,20,0,20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local highlightBtn = Instance.new("TextButton", frame)
highlightBtn.Size = UDim2.new(1,-10,0,40)
highlightBtn.Position = UDim2.new(0,5,0,10)
highlightBtn.Text = "Highlight: ON"

local headshotBtn = Instance.new("TextButton", frame)
headshotBtn.Size = UDim2.new(1,-10,0,40)
headshotBtn.Position = UDim2.new(0,5,0,60)
headshotBtn.Text = "Headshot: ON"

-- =====================
-- HIGHLIGHT FUNCTIONS
-- =====================
local function addHighlight(character)
	if character:FindFirstChild("Highlight") then return end
	local h = Instance.new("Highlight")
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = OUTLINE_COLOR
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

-- =====================
-- BUTTON EVENTS
-- =====================
highlightBtn.MouseButton1Click:Connect(function()
	highlightOn = not highlightOn
	highlightBtn.Text = "Highlight: "..(highlightOn and "ON" or "OFF")
end)

headshotBtn.MouseButton1Click:Connect(function()
	headshotOn = not headshotOn
	headshotBtn.Text = "Headshot: "..(headshotOn and "ON" or "OFF")
	ToggleHeadshot:FireServer(headshotOn)
end)

-- =====================
-- SHOOTING SYSTEM
-- =====================
script.Parent.Activated:Connect(function()
	local targetPart = mouse.Target
	if not targetPart then return end
	local targetCharacter = targetPart:FindFirstAncestorOfClass("Model")
	if not targetCharacter then return end
	local head = targetCharacter:FindFirstChild("Head")
	if not head then return end

	-- FireEvent sends the HEAD part (auto headshot)
	FireEvent:FireServer(head)
end)

-- =====================
-- SERVER LOGIC INLINE
-- =====================
if RunService:IsServer() then
	local headshotEnabled = {}

	ToggleHeadshot.OnServerEvent:Connect(function(player, state)
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
end
