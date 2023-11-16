-- LUALOCALS < ---------------------------------------------------------
local math, minetest, next, nodecore, pairs, vector
    = math, minetest, next, nodecore, pairs, vector
local math_random
    = math.random
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
local function pend(pos) pending[hash(pos)] = pos end

local function toomanyents()
	local entqty = 0
	for _, ent in pairs(minetest.luaentities) do
		if ent.name == "__builtin:falling_node" then
			entqty = entqty + 1
			if entqty > max_entities then return true end
		end
	end
end

local batch = {}
local batchpos = 1

minetest.register_globalstep(function()
		if toomanyents() then return end
		local stop = minetest.get_us_time() + max_time_per_step * 1000000
		if batchpos > #batch and (#batch > 0 or next(pending)) then
			batch = {}
			for _, v in pairs(pending) do batch[#batch + 1] = v end
			for i = #batch, 2, -1 do
				local j = math_random(1, i)
				local x = batch[i]
				batch[i] = batch[j]
				batch[j] = x
			end
			batchpos = 1
			pending = {}
		end
		while batchpos <= #batch do
			local pos = batch[batchpos]
			local bpos = vector.offset(pos, 0, -1, 0)
			if not pending[hash(bpos)] then
				local bnode = minetest.get_node_or_nil(bpos)
				if not bnode then
					pend(pos)
				elseif fallthru[bnode.name] then
					local node = minetest.get_node(pos)
					if node.name ~= bnode.name then
						nodecore.log("action",
							"falling node unsuspend at "
							.. minetest.pos_to_string(pos))
						minetest.check_for_falling(pos)
						if toomanyents() then break end
					end
				end
			end
			batchpos = batchpos + 1
			if minetest.get_us_time() >= stop then break end
		end
	end)

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
