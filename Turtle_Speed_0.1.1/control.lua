debug_mode = false

script.on_configuration_changed(function(data)
	global.turtle_speed_state = global.turtle_speed_state or {}
	
	--Migration to new global data
	if data.mod_changes ~= nil and data.mod_changes["Turtle_Speed"] ~= nil and data.mod_changes["Turtle_Speed"].old_version ~= nil then
		if data.mod_changes["Turtle_Speed"].old_version < "0.1.1" then
			local newGlobal = {}
			for player_index, state in pairs(global.turtle_speed_state) do
				if state then
					newGlobal[player_index] = {state=true, oldModifier=0}
				end
			end
			global.turtle_speed_state = newGlobal
		end
	end
	
	--Migration for old saves
	for _, player in pairs(game.players) do
		if (global.turtle_speed_state[player.index] == nil) then
			global.turtle_speed_state[player.index] = {state=false, oldModifier=0}
		end
	end
end)

--Initialize the global table
script.on_init(function()
	global.turtle_speed_state = global.turtle_speed_state or {}
end)

--Initialize the value for each player (will also turn off turtle mode if they die)
function on_player_created(event)
	global.turtle_speed_state[event.player_index] = {state=false, oldModifier=0}
end

script.on_event(defines.events.on_player_created, on_player_created)

--Checks on mod hotkey press
function on_hotkey(event)
	debugLog("Turtle Speed triggered")
	local player_index = event.player_index
	local player = game.players[player_index]
	
	--If the player has already press the key once
	if global.turtle_speed_state[player_index].state then
		--Turn off the running speed modifier and flip the global bool
		player.character_running_speed_modifier = global.turtle_speed_state[player_index].oldModifier
		global.turtle_speed_state[player_index].state = false
		
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
	global.turtle_speed_state[player_index].oldModifier = player.character_running_speed_modifier
	global.turtle_speed_state[player_index].state = true
	player.character_running_speed_modifier = runningModifier
	
	
	player.print({"turtle_speed_on"})
end

script.on_event("turtle_speed_hotkey", on_hotkey)

--Function to count the number of movement speed modifiers
function countRunningModifiers(player)
	local armorInventory = player.get_inventory(defines.inventory.player_armor)
	local movementSpeedCounter = 0
	
	if (armorInventory ~= nil) then
		if (armorInventory[1] ~= nil and armorInventory[1].valid_for_read) then
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