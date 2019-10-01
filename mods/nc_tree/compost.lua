-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local airnames = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.air_equivalent then
				airnames[#airnames + 1] = k
			end
		end
	end)

nodecore.register_soaking_abm({
		label = "Composting Growing",
		nodenames = {modname .. ":leaves_loose"},
		neighbors = {"group:soil"},
		interval = 10,
		chance = 10,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = function(pos)
			local min = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
			local max = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}
			if #minetest.find_nodes_in_area(min, max, airnames) then
				return false
			end
			local d = 0
			local w = 1
			nodecore.scan_flood(pos, 3, function(p)
					local nn = minetest.get_node(p).name
					local def = minetest.registered_items[nn] or {}
					if not def.groups then
						return false
					end
					if def.groups.soil then
						d = d + def.groups.soil
						w = w + 0.2
					elseif def.groups.moist then
						w = w + def.groups.moist
						return false
					else
						return false
					end
				end)
			minetest.chat_send_all("" .. math_sqrt(d * w))
			return math_sqrt(d * w)
		end,
		soakcheck = function(data, pos)
			if data.total < 5000 then return end
			minetest.set_node(pos, {name = "nc_terrain:dirt_loose"})
			nodecore.node_sound(pos, "place")
		end
	})
