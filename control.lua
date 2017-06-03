debug_mode = true --TODO
equipment_name_prefix = "turtle-speed-"

script.on_configuration_changed(function(data)
	global.turtle_speed_state = global.turtle_speed_state or {}
	
	--Reset modifier and simplify global
	if data.mod_changes and data.mod_changes["Turtle_Speed"] and data.mod_changes["Turtle_Speed"].old_version then
		if data.mod_changes["Turtle_Speed"].old_version < "0.1.5" then
			for index, data in pairs(global.turtle_speed_state) do
				if data.state then
					game.players[index].character_running_speed_modifier = data.oldModifier or 0
				end
				global.turtle_speed_state[index] = false
			end
		end
	end
	
	--Migration for old saves
	for _, player in pairs(game.players) do
		if (global.turtle_speed_state[player.index] == nil) then
			global.turtle_speed_state[player.index] = false
		end
	end
end)

--Initialize the global table
script.on_init(function()
	global.turtle_speed_state = global.turtle_speed_state or {}
end)

--Initialize the value for each player (will also turn off turtle mode if they die)
function on_player_created(event)
	global.turtle_speed_state[event.player_index] = false
end

script.on_event(defines.events.on_player_created, on_player_created)

--Turn Turtle mode off if they take off the armor
function on_player_armor_inventory_changed(event)
	local player_index = event.player_index
	local player = game.players[player_index]
	local armor = player.cursor_stack
	
	if global.turtle_speed_state[player_index] then
		toggleEquipmentOff(player, armor)
	end
end

script.on_event(defines.events.on_player_armor_inventory_changed, on_player_armor_inventory_changed)

--Checks on mod hotkey press
function on_hotkey(event)
	local player_index = event.player_index
	local player = game.players[player_index]
	local armor = player.get_inventory(defines.inventory.player_armor)[1]
	
	if global.turtle_speed_state[player_index] then
		toggleEquipmentOff(player, armor)
	else
		toggleEquipmentOn(player, armor)
	end
end

script.on_event("turtle_speed_hotkey", on_hotkey)

--Replace current speed boosting equipment with Turtled versions
function toggleEquipmentOn(player, armor)
	if armor then
		if armor.valid and armor.valid_for_read then
			if armor.grid then
				local minimumEquipment = settings.get_player_settings(player)["Turtle_Speed_minimum_modifiers"].value
				local grid = armor.grid
				local equipmentList = grid.equipment
				local count = 0
				for _, equipment in pairs(equipmentList) do
					if equipment and equipment.valid and equipment.movement_bonus > 0 then
						if count >= minimumEquipment then
							local position = equipment.position
							local name = equipment_name_prefix..equipment.name
							grid.take{position=position}
							grid.put{name=name, position=position}
						end
						count = count + 1
					end
				end
				
				global.turtle_speed_state[player.index] = true
				player.print({"turtle_speed_on"})
			end
		end
	end
end

--Replace Turtled equipment
function toggleEquipmentOff(player, armor)
	if armor then
		if armor.valid and armor.valid_for_read then
			if armor.grid then
				local grid = armor.grid
				local equipmentList = grid.equipment
				for _, equipment in pairs(equipmentList) do
					if string.sub(equipment.name, 1, #equipment_name_prefix) == equipment_name_prefix then
						local position = equipment.position
						local name = string.sub(equipment.name, #equipment_name_prefix+1)
						grid.take{position=position}
						grid.put{name=name, position=position}
					end
				end
				
				global.turtle_speed_state[player.index] = false
				player.print({"turtle_speed_off"})
			end
		end
	end
end

--DEBUG
function debugLog(message)
	if debug_mode then
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
end 