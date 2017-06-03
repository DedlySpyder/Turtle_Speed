require("hotkey")

local new_prototypes = {}
local equipment_name_prefix = "turtle-speed-"

for name, prototype in pairs(data.raw["movement-bonus-equipment"]) do
	local turtle_prototype = util.table.deepcopy(prototype)
	local sprite = 
	{
		layers = 
		{
			turtle_prototype.sprite,
			{
				filename = "__Turtle_Speed__/graphics/turtle-icon.png",
				width = "64",
				height = "128",
				priority = "medium"
			}
		}
	}
	turtle_prototype.name = equipment_name_prefix..name
	turtle_prototype.localised_name = {"turtle_speed_equipement_prefix", {"equipment-name."..name}}
	turtle_prototype.sprite = sprite
	turtle_prototype.movement_bonus = 0
	table.insert(new_prototypes, turtle_prototype)
	
	local turtle_item_prototype = util.table.deepcopy(data.raw["item"][name])
	turtle_item_prototype.name = equipment_name_prefix..name
	turtle_item_prototype.localised_name = {"turtle_speed_equipement_prefix", {"equipment-name."..name}}
	table.insert(new_prototypes, turtle_item_prototype)
end

data:extend(new_prototypes)