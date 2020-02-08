-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
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

local grasscost = 1000

nodecore.register_soaking_abm({
		label = "Grass Spread",
		nodenames = {"group:soil_not_grass"},
		neighbors = {grass},
		fieldname = "grassify",
		interval = 10,
		chance = 1,
		soakrate = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not grassable(above) then return end
			return 10
		end,
		soakcheck = function(data, pos)
			if nodecore.near_unloaded(pos) then return end
			if data.total < grasscost then return end
			minetest.set_node(pos, {name = grass})
			local found = nodecore.find_nodes_around(pos, {"group:soil_not_grass"})
			if #found < 1 then return false end
			for i = 1, #found do
				local j = math_random(1, #found)
				found[i], found[j] = found[j], found[i]
			end
			for _, p in pairs(found) do
				p.y = p.y + 1
				if grassable(p) then
					p.y = p.y - 1
					nodecore.soaking_abm_push(p,
						"grassify", data.total - grasscost)
					return false
				end
			end
			return false
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

nodecore.register_dirt_leeching(dirt, modname .. ":sand_loose")
