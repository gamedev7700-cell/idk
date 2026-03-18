-- Put this in ServerScriptService
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- CONFIG
local BASE_DAMAGE = 20
local HEADSHOT_MULTIPLIER = 2
local OUTLINE_COLOR = Color3.fromRGB(255,0,0)
local HIGHLIGHT_ON = true -- toggle highlights on/off

-- =====================
-- HIGHLIGHT PLAYERS
-- =====================
local function addHighlight(character)
	if not character then return end
	if character:FindFirstChild("Highlight") then return end
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

local function updateHighlights()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			if HIGHLIGHT_ON then
				addHighlight(p.Character)
			else
				removeHighlight(p.Character)
			end
		end
	end
end

-- Update highlights every 0.5s
RunService.Heartbeat:Connect(function()
	updateHighlights()
end)

-- =====================
-- AUTO HEADSHOT DAMAGE
-- =====================
local function onPlayerShoot(shooter, targetPart)
	if not targetPart then return end
	local character = targetPart:FindFirstAncestorOfClass("Model")
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end

	-- Always apply headshot damage
	humanoid:TakeDamage(BASE_DAMAGE * HEADSHOT_MULTIPLIER)
end

-- =====================
-- EXAMPLE WEAPON HOOK
-- =====================
-- Replace this with your actual weapon/fire system
-- This is an example: when player clicks on another player, apply headshot

for _, playerObj in pairs(Players:GetPlayers()) do
	if playerObj.Character then
		local char = playerObj.Character
		-- Replace Tool.Activated event with your own shooting system
		if char:FindFirstChildOfClass("Tool") then
			local tool = char:FindFirstChildOfClass("Tool")
			tool.Activated:Connect(function()
				local mouse = playerObj:GetMouse()
				if mouse.Target then
					onPlayerShoot(playerObj, mouse.Target)
				end
			end)
		end
	end
end

-- Optional: listen for new players
Players.PlayerAdded:Connect(function(playerObj)
	playerObj.CharacterAdded:Connect(function(char)
		-- Setup tool shooting for new character
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			tool.Activated:Connect(function()
				local mouse = playerObj:GetMouse()
				if mouse.Target then
					onPlayerShoot(playerObj, mouse.Target)
				end
			end)
		end
	end)
end)
