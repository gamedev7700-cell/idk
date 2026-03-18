-- Place this in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create FireEvent if it doesn't exist
local FireEvent = ReplicatedStorage:FindFirstChild("FireEvent")
if not FireEvent then
	FireEvent = Instance.new("RemoteEvent")
	FireEvent.Name = "FireEvent"
	FireEvent.Parent = ReplicatedStorage
end

-- ------------------------------
-- CONFIG
-- ------------------------------
local BASE_DAMAGE = 20
local HEADSHOT_MULTIPLIER = 2
local OUTLINE_COLOR = Color3.fromRGB(255, 0, 0)

-- ------------------------------
-- FUNCTION: Apply Auto Headshot
-- ------------------------------
local function applyHeadshot(hitPart, attacker)
	if not hitPart then return end
	
	local character = hitPart:FindFirstAncestorOfClass("Model")
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local damage = BASE_DAMAGE * HEADSHOT_MULTIPLIER
	humanoid:TakeDamage(damage)
	
	print(attacker.Name .. " auto headshot -> " .. character.Name)
end

-- Connect FireEvent
FireEvent.OnServerEvent:Connect(applyHeadshot)

-- ------------------------------
-- FUNCTION: Add Highlight to Player
-- ------------------------------
local function addHighlight(character)
	if not character then return end
	if character:FindFirstChild("Highlight") then return end
	
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = OUTLINE_COLOR
	highlight.Parent = character
end

-- ------------------------------
-- SETUP HIGHLIGHTS FOR ALL PLAYERS
-- ------------------------------
local function setupPlayer(p)
	p.CharacterAdded:Connect(function(char)
		task.wait(0.1) -- wait for character to load
		addHighlight(char)
	end)
	
	if p.Character then
		addHighlight(p.Character)
	end
end

for _, p in pairs(Players:GetPlayers()) do
	setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)

-- ------------------------------
-- OPTIONAL: Local gun firing
-- You can call FireEvent from a LocalScript when the player shoots
-- ------------------------------
-- Example LocalScript (Tool.Activated):
-- local mouse = game.Players.LocalPlayer:GetMouse()
-- script.Parent.Activated:Connect(function()
--     if mouse.Target then
--         game.ReplicatedStorage.FireEvent:FireServer(mouse.Target)
--     end
-- end)
