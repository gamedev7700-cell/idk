-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")

local function addOutline(character)
	if character:FindFirstChild("Highlight") then return end
	
	local h = Instance.new("Highlight")
	h.FillTransparency = 1
	h.OutlineColor = Color3.fromRGB(255, 0, 0)
	h.Parent = character
end

local function setup(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(0.1)
		addOutline(char)
	end)
end

for _, p in pairs(Players:GetPlayers()) do
	setup(p)
end

Players.PlayerAdded:Connect(setup)
