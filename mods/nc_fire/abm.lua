-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_pow, math_random
    = math.pow, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local fueltest = {groups = {ember = true}}
nodecore.register_limited_abm({
		label = "Fire Requires Embers",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":fire"},
		action = function(pos)
			if not nodecore.match({x = pos.x, y = pos.y - 1, z = pos.z }, fueltest)
			and not nodecore.match({x = pos.x + 1, y = pos.y, z = pos.z }, fueltest)
			and not nodecore.match({x = pos.x - 1, y = pos.y, z = pos.z }, fueltest)
			and not nodecore.match({x = pos.x, y = pos.y, z = pos.z + 1 }, fueltest)
			and not nodecore.match({x = pos.x, y = pos.y, z = pos.z - 1 }, fueltest)
			then return minetest.remove_node(pos) end
		end
	})

local function mkfire(pos, dx, dy, dz, testonly)
	pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	if nodecore.match(pos, modname .. ":fire") then return true end
	if nodecore.match(pos, "air") then
		return testonly or minetest.set_node(pos, {name = modname .. ":fire"})
	end
	if nodecore.match(pos, "ignore") then return true end
	if nodecore.match(pos, {groups = {flammable = true, fire_fuel = false}}) then
		return testonly or minetest.set_node(pos, {name = modname .. ":fire"})
	end
end

nodecore.register_limited_abm({
		label = "Flammables Ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		action = function(pos, node)
			-- Cannot be wet.
			if nodecore.quenched(pos) then return end

			-- Must have oxygen supply.
			if not mkfire(pos, 0, 1, 0, true)
			and not mkfire(pos, 1, 0, 0, true)
			and not mkfire(pos, -1, 0, 0, true)
			and not mkfire(pos, 0, 0, 1, true)
			and not mkfire(pos, 0, 0, -1, true)
			then return end

			-- Get flammability level.
			node = node or minetest.get_node(pos)
			local def = minetest.registered_nodes[node.name]
			local flam = def and def.groups and def.groups.flammable
			if not flam then return end

			-- Ignite randomly.
			if math_random(1, flam) ~= 1 then return end
			nodecore.ignite(pos, node)
		end
	})

nodecore.register_limited_abm({
		label = "Fuel Burning/Snuffing",
		interval = 1,
		chance = 1,
		nodenames = {"group:ember"},
		action = function(pos, node)
			if nodecore.quenched(pos) then
				return nodecore.snuff(pos, node)
			end
			local f = mkfire(pos, 0, 1, 0)
			f = mkfire(pos, 1, 0, 0) or f
			f = mkfire(pos, -1, 0, 0) or f
			f = mkfire(pos, 0, 0, 1) or f
			f = mkfire(pos, 0, 0, -1) or f
			if math_random(1, math_pow(2,
					nodecore.node_group("ember", pos, node)
					+ (f and 4 or 0))) == 1 then 
				return nodecore.snuff(pos, node)
			end
		end
	})
