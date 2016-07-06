debug_mode = false

script.on_init(function()
	global.turtle_speed_state = global.turtle_speed_state or {}
end)

--Checks on mod hotkey press
function on_hotkey(event)
	debugLog("Turtle Speed triggered")
	local player_index = event.player_index
	local player = game.players[player_index]
	
	--If the player has already press the key once
	if global.turtle_speed_state[player_index] then
		--Turn off the running speed modifier and flip the global bool
		player.character_running_speed_modifier = 0
		global.turtle_speed_state[player_index] = false
		
		player.print({"turtle_speed_off"})
		return
	end
	
	--Calculate the running modifier
	--The math works out that about 1 (default game) modifier is the same as 0.1 in the character_running_speed_modifier
	local runningModifier = (countRunningModifiers(player) * -0.1)
	debugLog("Current Bonus Speed Effects: "..runningModifier)
	
	--A modifier of -1 stops the player, while less that -1 will make them move in reverse
	--This can only occur with modded equipment
	if (runningModifier < -0.9) then runningModifier = -0.9 end
	
	--Set the new speed modifier and flip the global bool
	player.character_running_speed_modifier = runningModifier
	global.turtle_speed_state[player_index] = true
	
	player.print({"turtle_speed_on"})
end

script.on_event("turtle_speed_hotkey", on_hotkey)

--Function to count the number of movement speed modifiers
function countRunningModifiers(player)
	local armorInventory = player.get_inventory(defines.inventory.player_armor)
	local movementSpeedCounter = 0
	
	if (armorInventory ~= nil) then
		if (armorInventory[1] ~= nil) then
			if (armorInventory[1].has_grid) then
				local equipmentList = armorInventory[1].grid.equipment
				for _, equipment in pairs(equipmentList) do
					if (equipment.movement_bonus > 0) then
						movementSpeedCounter = movementSpeedCounter + 1
						debugLog(equipment.name.." gives a bonus. New count: "..movementSpeedCounter)
					end
				end
			end
		end
	end
	
	return movementSpeedCounter
end


--DEBUG
function debugLog(message)
	if debug_mode then
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
end 