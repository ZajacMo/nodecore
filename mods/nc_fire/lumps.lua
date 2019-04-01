-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_craftitem(modname .. ":lump_ash", {
		description = "Ash Lump",
		inventory_image = modname .. "_ash.png^[mask:" .. modname .. "_lump.png",
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})
minetest.register_craftitem(modname .. ":lump_coal", {
		description = "Charcoal Lump",
		inventory_image = modname .. "_coal_4.png^[mask:" .. modname .. "_lump.png",
		groups = {flammable = 1},
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})

local function split(items, name, qty)
	local two = math_floor(qty / 2)
	if two > 0 then
		items[#items + 1] = {name = name .. " 2", count = two, scatter = 5}
	end
	qty = qty - (two * 2)
	if qty > 0 then
		items[#items + 1] = {name = name, count = qty, scatter = 5}
	end
end
for num = 0, nodecore.fire_max do
	local items = {}
	split(items, modname .. ":lump_coal", num)
	split(items, modname .. ":lump_ash", nodecore.fire_max - num)
	local name = modname .. ((num == 0) and ":ash" or (":coal" .. num))
	nodecore.register_craft({
			label = "chop " .. name .. " block",
			action = "pummel",
			toolgroups = {choppy = 1},
			nodes = {
				{match = name, replace = "air"}
			},
			items = items
		})
end

nodecore.register_craft({
		label = "compress ash block",
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = {name = modname .. ":lump_ash", count = 8},
				replace = modname .. ":ash"
			}
		}
	})
nodecore.register_craft({
		label = "compress coal block",
		action = "pummel",
		toolgroups = {thumpy = 2},
		nodes = {
			{
				match = {name = modname .. ":lump_coal", count = 8},
				replace = modname .. ":coal8"
			}
		}
	})
