-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local max_time_per_step = 0.05
local max_entities = 50

local fallthru = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.buildable_to or not v.walkable then
				fallthru[k] = true
			end
		end
	end)

local hash = minetest.hash_node_position
local pending = {}

local function toomanyents()
	local entqty = 0
	for _, ent in pairs(minetest.luaentities) do
		if ent.name == "__builtin:falling_node" then
			entqty = entqty + 1
			if entqty > max_entities then return true end
		end
	end
end

minetest.register_globalstep(function()
		if toomanyents() then return end
		local stop = minetest.get_us_time() + max_time_per_step * 1000000
		local done = {}
		for k, pos in pairs(pending) do
			local bpos = vector.offset(pos, 0, -1, 0)
			if not pending[hash(bpos)] then
				local bnode = minetest.get_node_or_nil(bpos)
				if bnode and fallthru[bnode.name] then
					nodecore.log("action", "falling node unsuspend at "
						.. minetest.pos_to_string(pos))
					minetest.check_for_falling(pos)
					if toomanyents() then break end
				end
			end
			done[#done + 1] = k
			if minetest.get_us_time() >= stop then break end
		end
		for i = 1, #done do pending[done[i]] = nil end
	end)

local function pend(pos) pending[hash(pos)] = pos end

nodecore.register_lbm({
		name = minetest.get_current_modname() .. ":unsuspend",
		run_at_every_load = true,
		nodenames = {"group:falling_node"},
		action = pend
	})

minetest.register_abm({
		label = minetest.get_current_modname() .. ":unsuspend",
		nodenames = {"group:falling_node"},
		interval = 10,
		chance = 10,
		action = pend
	})
