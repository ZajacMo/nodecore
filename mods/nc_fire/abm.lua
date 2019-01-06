-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
= math, minetest, nodecore
local math_random
= math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local fueltest = {groups = {fire_fuel = true}}
nodecore.register_limited_abm({
		label = "Fire Requires Fuel",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":fire"},
		action = function(pos)
			if not nodecore.node_is({x = pos.x, y = pos.y - 1, z = pos.z }, fueltest)
			and not nodecore.node_is({x = pos.x + 1, y = pos.y, z = pos.z }, fueltest)
			and not nodecore.node_is({x = pos.x - 1, y = pos.y, z = pos.z }, fueltest)
			and not nodecore.node_is({x = pos.x, y = pos.y, z = pos.z + 1 }, fueltest)
			and not nodecore.node_is({x = pos.x, y = pos.y, z = pos.z - 1 }, fueltest)
			then return minetest.remove_node(pos) end
		end
	})

nodecore.register_limited_abm({
		label = "Flammables Ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		action = function(pos, node)
			node = node or minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			local flam = def and def.groups and def.groups.flammable
			if not flam then return end
			if def.groups.visinv then
				local stack = minetest.get_meta(pos)
				:get_inventory():get_stack("solo", 1)
				if stack and not stack:is_empty() then
					local idef = minetest.registered_items[stack:get_name()]
					flam = idef and idef.groups and idef.groups.flammable
				end
			end
			if not flam then return end
			if math_random(1, flam) ~= 1 then return end
			minetest.set_node(pos, {name = def.groups.burn_away
					and (modname .. ":fire")
					or (modname .. ":fuel")})
		end
	})

local function mkfire(pos, dx, dy, dz)
	pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	if nodecore.node_is(pos, modname .. ":fire") then return true end
	if nodecore.node_is(pos, "air") then
		return minetest.set_node(pos, {name = modname .. ":fire"})
	end
	if nodecore.node_is(pos, "ignore") then return true end
	if nodecore.node_is(pos, {groups = {flammable = true, burn_away = true}}) then
		return minetest.set_node(pos, {name = modname .. ":fire"})
	end
end
nodecore.register_limited_abm({
		label = "Fuel Burning/Snuffing",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":fuel"},
		neighbors = {"air"},
		action = function(pos)
			local f = mkfire(pos, 0, 1, 0)
			f = mkfire(pos, 1, 0, 0) or f
			f = mkfire(pos, -1, 0, 0) or f
			f = mkfire(pos, 0, 0, 1) or f
			f = mkfire(pos, 0, 0, -1) or f
			if not f then 
				return minetest.set_node(pos, {name = modname .. ":ash"})
			end
		end
	})
