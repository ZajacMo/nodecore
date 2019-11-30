-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
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

	local ln = minetest.get_node_light(above) or 0
	if ln >= 10 then return true end
	local ld = minetest.get_node_light(above, 0.5) or 0
	if ld >= 10 then return end
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

local function waterat(pos, dx, dy, dz)
	pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	local node = minetest.get_node(pos)
	return minetest.get_item_group(node.name, "water") ~= 0
end
nodecore.register_limited_abm({
		label = "Dirt Leeching to Sand",
		nodenames = {dirt},
		neighbors = {"group:water"},
		interval = 5,
		chance = 50,
		action = function(pos)
			if not waterat(pos, 0, 1, 0) then return end
			local qty = 1
			if waterat(pos, 1, 0, 0) then qty = qty * 1.5 end
			if waterat(pos, -1, 0, 0) then qty = qty * 1.5 end
			if waterat(pos, 0, 0, 1) then qty = qty * 1.5 end
			if waterat(pos, 0, 0, -1) then qty = qty * 1.5 end
			if waterat(pos, 0, -1, 0) then qty = qty * 1.5 end
			if math_random() * 100 >= qty then return end
			minetest.set_node(pos, {name = modname .. ":sand_loose"})
			nodecore.node_sound(pos, "place")
			nodecore.fallcheck(pos)
		end
	})
