-- Server Script (put in ServerScriptService)

local BASE_DAMAGE = 20
local HEADSHOT_MULTIPLIER = 2

game.ReplicatedStorage.FireEvent.OnServerEvent:Connect(function(player, hitPart)
	if not hitPart then return end
	
	local character = hitPart:FindFirstAncestorOfClass("Model")
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	-- FORCE HEADSHOT DAMAGE
	local damage = BASE_DAMAGE * HEADSHOT_MULTIPLIER
	humanoid:TakeDamage(damage)
	
	print("AUTO HEADSHOT applied to:", character.Name)
end)
