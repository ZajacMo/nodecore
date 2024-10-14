-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local dirt = modname .. ":dirt"
local grass = modname .. ":dirt_with_grass"

local grass_under_nodes = {}
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
	}
	core.after(0, function()
			for name, def in pairs(core.registered_nodes) do
				if def.drawtype and breathable[def.drawtype]
				and (not (def.groups and def.groups.moist))
				and (def.damage_per_second or 0) <= 0 then
					grass_under_nodes[name] = true
				end
			end
		end)
end

-- nil = stay, false = die, true = grow
local function can_grass_grow_under(above)
	local nodename = core.get_node(above).name
	if nodename == "ignore" then return end
	if (not grass_under_nodes[nodename]) then return false end
	local ln = nc.get_node_light(above)
	if not ln then return end
	return ln >= 10
end
nc.can_grass_grow_under = can_grass_grow_under

nc.grassable = function(...)
	nc.log("warning", "deprecated nc.grassable(pos)")
	return nc.can_grass_grow_under(...)
end

core.register_abm({
		label = "grass spread",
		nodenames = {"group:grassable"},
		neighbors = {grass},
		neighbors_invert = true,
		interval = 6,
		chance = 50,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not can_grass_grow_under(above) then return end
			return core.set_node(pos, {name = grass})
		end
	})

core.register_abm({
		label = "grass decay",
		nodenames = {grass},
		interval = 8,
		chance = 50,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if can_grass_grow_under(above) ~= false then return end
			return core.set_node(pos, {name = dirt})
		end
	})
