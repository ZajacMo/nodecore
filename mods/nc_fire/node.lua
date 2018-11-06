-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":fire", {
		description = "Fire",
		drawtype = "firelike",
		visual_scale = 1.5,
		tiles = {modname .. "_fire.png"},
		paramtype = "light",
		light_source = 12,
		damage_per_second = 2,
		propagates_sunlight = true,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true
	})

minetest.register_node(modname .. ":fuel", {
		description = "Burning Embers",
		tiles = {modname .. "_fuel.png"},
		paramtype = "light",
		light_source = 6,
		groups = { falling_node = 1 },
		drop = "",
		diggable = false,
		on_punch = function(pos, node, puncher)
			puncher:set_hp(puncher:get_hp() - 1)
		end
	})

minetest.register_node(modname .. ":ash", {
		description = "Ash",
		tiles = {modname .. "_ash.png"},
		groups = { falling_node = 1, crumbly = 3 }
	})

local fueltest = {name = modname .. ":fuel"}
minetest.register_abm({
		label = "Fire Requires Fuel",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":fire"},
		action = function(pos)
			if not nodecore.node_is({x = pos.x, y = pos.y - 1, z = pos.z }, fueltest)
			or not nodecore.node_is({x = pos.x + 1, y = pos.y, z = pos.z }, fueltest)
			or not nodecore.node_is({x = pos.x - 1, y = pos.y, z = pos.z }, fueltest)
			or not nodecore.node_is({x = pos.x, y = pos.y, z = pos.z + 1 }, fueltest)
			or not nodecore.node_is({x = pos.x, y = pos.y, z = pos.z - 1 }, fueltest)
			then return minetest.remove_node(pos) end
		end
	})

local function mkfire(pos, dx, dy, dz)
	pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	local name = minetest.get_node(pos).name
	if name == modname .. ":fire" then return true end
	if name ~= "air" then return end
	return minetest.set_node(pos, {name = modname .. ":fire"})
end
minetest.register_abm({
		label = "Fuel Spawns Fire",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":fuel"},
		neighbors = {"air"},
		action = function(pos)
			local f = mkfire(pos, 0, 1, 0)
			f = mkfire(pos, 1, 0, 0) or f
			f = mkfire(pos, -1, 0, 0) or f
			f = mkfire(pos, 0, 0, 1) or f
			f = mkfire(pos, 0, 0, -1) or f
			if not f then 
				return minetest.set_node(pos, {name = modname .. ":ash"})
			end
		end
	})
