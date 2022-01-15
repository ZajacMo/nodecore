-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs
    = ipairs, math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local particles_add, particles_flush = nodecore.fairlimit(200)

nodecore.register_globalstep("fire sparks", function()
		for _, data in ipairs(particles_flush()) do
			minetest.after(math_random(), function()
					nodecore.soaking_particles(data.pos, data.rate, 5, 0.45)
				end)
		end
	end)

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
			arealoaded = 1,
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
				if data.total < 5000 then
					return particles_add({pos = pos, rate = data.rate})
				end
				nodecore.set_loud(pos, {name = tonode})
				nodecore.witness(pos, "leach " .. fromnode)
				return nodecore.fallcheck(pos)
			end
		})
end

nodecore.register_dirt_leaching("group:dirt_raked", "nc_terrain:sand")
nodecore.register_dirt_leaching("group:humus_raked", "nc_terrain:dirt", 3)
