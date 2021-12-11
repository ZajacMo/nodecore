-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_dirt_leaching(fromnode, tonode, rate)
	local waters = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_nodes) do
				if v.groups and v.groups.water and v.groups.water > 0 then
					waters[k] = true
				end
			end
		end)
	local function waterat(pos, dx, dy, dz)
		return waters[minetest.get_node(
			{x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
		).name]
	end
	nodecore.register_soaking_abm({
			label = fromnode .. " leaching to " .. tonode,
			fieldname = "leach",
			nodenames = {fromnode},
			interval = 5,
			quickcheck = function(pos)
				return waterat(pos, 0, 1, 0)
			end,
			soakrate = function(pos)
				local qty = 1
				if waterat(pos, 1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, -1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, 1) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, -1) then qty = qty * 1.5 end
				if waterat(pos, 0, -1, 0) then qty = qty * 1.5 end
				return qty * (rate or 1)
			end,
			soakcheck = function(data, pos)
				if data.total < 5000 then return end
				nodecore.set_loud(pos, {name = tonode})
				nodecore.witness(pos, "leach " .. fromnode)
				return nodecore.fallcheck(pos)
			end
		})
end

nodecore.register_dirt_leaching(modname .. ":dirt_raked", "nc_terrain:sand_loose")
nodecore.register_dirt_leaching(modname .. ":dirt_raked_nexus", "nc_terrain:sand_loose")

nodecore.register_dirt_leaching(modname .. ":humus_raked", "nc_terrain:dirt_loose", 3)
nodecore.register_dirt_leaching(modname .. ":humus_raked_nexus", "nc_terrain:dirt_loose", 3)
