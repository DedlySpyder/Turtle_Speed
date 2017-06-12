local new_prototypes = {}
local equipment_name_prefix = "turtle-speed-"

for name, prototype in pairs(data.raw["movement-bonus-equipment"]) do
	--Equipment
	local turtle_prototype = util.table.deepcopy(prototype)
	
	local sprite = {}
	if turtle_prototype.shape.width == 2 and turtle_prototype.shape.height == 4 then
		sprite = 
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
	else
		sprite = 
		{
			layers = 
			{
				turtle_prototype.sprite,
				{
					filename = "__Turtle_Speed__/graphics/turtle-icon-1x1.png",
					width = "32",
					height = "32",
					priority = "medium"
				}
			}
		}
	end
	
	turtle_prototype.name = equipment_name_prefix..name
	turtle_prototype.localised_name = {"turtle_speed_equipement_prefix", {"equipment-name."..name}}
	turtle_prototype.sprite = sprite
	turtle_prototype.movement_bonus = 0
	turtle_prototype.energy_consumption = "0kW"
	table.insert(new_prototypes, turtle_prototype)
	
	--Item
	local turtle_item_prototype = util.table.deepcopy(data.raw["item"][name])
	turtle_item_prototype.name = equipment_name_prefix..name
	turtle_item_prototype.localised_name = {"turtle_speed_equipement_prefix", {"equipment-name."..name}}
	table.insert(new_prototypes, turtle_item_prototype)
end

data:extend(new_prototypes)