-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

do
	local flamedirs = nodecore.dirs()
	local embers = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_items) do
				if v.groups.ember then
					embers[k] = true
				end
			end
		end)
	nodecore.register_limited_abm({
			label = "Fire Requires/Consumes Embers",
			interval = 1,
			chance = 1,
			nodenames = {modname .. ":fire"},
			action = function(pos)
				local found = {}
				for _, dp in ipairs(flamedirs) do
					local npos = vector.add(pos, dp)
					local node = minetest.get_node_or_nil(npos)
					if (not node) or embers[node.name] then
						found[#found + 1] = npos
					end
				end
				if #found < 1 then
					return minetest.remove_node(pos)
				end
				local picked = nodecore.pickrand(found)
				return nodecore.fire_check_expend(picked)
			end
		})
end

nodecore.register_limited_abm({
		label = "Flammables Ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		action = nodecore.fire_check_ignite
	})

nodecore.register_limited_abm({
		label = "Fuel Burning/Snuffing",
		interval = 1,
		chance = 1,
		nodenames = {"group:ember"},
		action = function(pos, node)
			local snuff, vents = nodecore.fire_check_snuff(pos, node)
			if snuff or not vents then return end
			for i = 1, #vents do
				if vents[i].q < 1 then
					minetest.set_node(vents[i], {name = modname .. ":fire"})
				end
			end
		end
	})

nodecore.register_ambiance({
		label = "Flame Ambiance",
		nodenames = {modname .. ":fire"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.3
	})
