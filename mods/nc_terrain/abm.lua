-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local dirt = modname .. ":dirt"
local grass = modname .. ":dirt_with_grass"

local grassable_nodes = {}
do
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
	minetest.after(0, function()
			for name, def in pairs(minetest.registered_nodes) do
				if def.drawtype and breathable[def.drawtype]
				and (def.damage_per_second or 0) <= 0 then
					grassable_nodes[name] = true
				end
			end
		end)
end

-- nil = stay, false = die, true = grow
local function grassable(above)
	local nodename = minetest.get_node(above).name
	if nodename == "ignore" then return end
	if (not grassable_nodes[nodename]) then return false end
	local ln = nodecore.get_node_light(above)
	if not ln then return end
	return ln >= 10
end

nodecore.register_limited_abm({
		label = "grass spread",
		nodenames = {"group:soil"},
		neighbors = {grass},
		neighbors_invert = true,
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
		label = "grass decay",
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
