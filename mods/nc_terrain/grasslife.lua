-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local dirt = "nc_terrain:dirt"
local grass = "nc_terrain:dirt_with_grass"

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

	local ln = minetest.get_node_light(above) or 0
	if ln >= 10 then return true end
	local ld = minetest.get_node_light(above, 0.5) or 0
	if ld >= 10 then return end
end

nodecore.register_limited_abm({
		label = "Grass Spread",
		nodenames = {dirt, "nc_terrain:dirt_loose"},
		neighbors = {grass},
		interval = 6,
		chance = 50,
		action = function(pos)
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
