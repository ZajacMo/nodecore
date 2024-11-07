-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, string
    = core, nc, pairs, string
local string_gsub
    = string.gsub
-- LUALOCALS > ---------------------------------------------------------

function nc.register_dirt_leaching(fromnode, recipematch, tonode, rate)
	local waters = {}
	core.after(0, function()
			for k, v in pairs(core.registered_nodes) do
				if v.groups and v.groups.water and v.groups.water > 0 then
					waters[k] = true
				end
			end
		end)
	local function waterat(pos, dx, dy, dz)
		return waters[core.get_node(
			{x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
		).name]
	end
	local fieldname = "leach_" .. string_gsub(tonode, "%W+", "_")
	nc.register_soaking_abm({
			label = fromnode .. " leaching to " .. tonode,
			fieldname = fieldname,
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
				if data.total < 5000 then return end
				nc.set_loud(pos, {name = tonode})
				nc.witness(pos, "leach " .. fromnode)
				return nc.fallcheck(pos)
			end
		})

	nc.register_craft({
			label = "tickle leach " .. fromnode,
			action = "pummel",
			toolgroups = {cuddly = 1},
			normal = {y = 1},
			indexkeys = {fromnode},
			check = function(pos)
				return waterat(pos, 0, 1, 0)
			end,
			nodes = {
				{match = recipematch}
			},
			after = function(pos)
				nc.soaking_abm_tickle(pos, fieldname)
				nc.soaking_particles(pos, 25, 0.5, .45)
			end
		})
end

nc.register_dirt_leaching(
	"group:dirt_raked",
	{groups = {dirt_raked = true}, stacked = false},
	"nc_terrain:sand"
)
nc.register_dirt_leaching(
	"group:humus_raked",
	{groups = {humus_raked = true}, stacked = false},
	"nc_terrain:dirt",
	3
)
