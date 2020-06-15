-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local dirt = modname .. ":dirt"
local grass = modname .. ":dirt_with_grass"

local breathable = {
	airlike = true,
	allfaces = true,
	allfaces_optional = true,
	torchlike = true,
	signlike = true,
	plantlike = true,
	firelike = true,
	raillike = true,
	nodebox = true,
	mesh = true,
	plantlike_rooted = true
}

-- nil = stay, false = die, true = grow
local function grassable(above)
	local node = minetest.get_node(above)
	if node.name == "ignore" then return end

	local def = minetest.registered_items[node.name] or {}

	if (not def.drawtype) or (not breathable[def.drawtype])
	or (def.damage_per_second and def.damage_per_second > 0)
	then return false end

	local ln = nodecore.get_node_light(above)
	if not ln then return end
	return ln >= 10
end

nodecore.register_limited_abm({
		label = "Grass Spread",
		nodenames = {"group:soil"},
		neighbors = {grass},
		interval = 6,
		chance = 50,
		action = function(pos, node)
			if node.name == grass then return end
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not grassable(above) then return end
			return minetest.set_node(pos, {name = grass})
		end
	})

nodecore.register_limited_abm({
		label = "Grass Decay",
		nodenames = {grass},
		interval = 8,
		chance = 50,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if grassable(above) ~= false then return end
			return minetest.set_node(pos, {name = dirt})
		end
	})

nodecore.register_dirt_leaching(dirt, modname .. ":sand_loose")
