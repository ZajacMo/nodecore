-- LUALOCALS < ---------------------------------------------------------
local core, nc, next, pairs, table
    = core, nc, next, pairs, table
local table_shuffle
    = table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local max_time_per_step = 0.05
local max_entities = 50

local fallthru = {}
core.after(0, function()
		for k, v in pairs(core.registered_nodes) do
			if v.buildable_to or not v.walkable then
				fallthru[k] = true
			end
		end
	end)

local hash = core.hash_node_position

local pending = {}
local function pend(pos)
	if not pos.hash then pos.hash = hash(pos) end
	pending[pos.hash] = pos
end

local function toomanyents()
	local entqty = 0
	for _, ent in pairs(core.luaentities) do
		if ent.name == "__builtin:falling_node" then
			entqty = entqty + 1
			if entqty > max_entities then return true end
		end
	end
end

local batch = {}
local batchpos = 1

local defer
do
	local deferred
	defer = function(pos)
		if not deferred then
			deferred = {}
			core.after(5, function()
					for k, v in pairs(deferred) do
						pending[k] = v
					end
					deferred = nil
				end)
		end
		if not pos.hash then pos.hash = hash(pos) end
		deferred[pos.hash] = pos
	end
end

core.register_globalstep(function()
		if toomanyents() then return end
		local stop = core.get_us_time() + max_time_per_step * 1000000
		if batchpos > #batch and (#batch > 0 or next(pending)) then
			batch = {}
			for _, v in pairs(pending) do batch[#batch + 1] = v end
			table_shuffle(batch)
			batchpos = 1
			pending = {}
		end
		while batchpos <= #batch do
			local pos = batch[batchpos]
			local bpos = {x = pos.x, y = pos.y - 1, z = pos.z}
			if not pending[hash(bpos)] then
				local bnode = core.get_node_or_nil(bpos)
				if not bnode then
					if core.get_node_or_nil(pos) then
						defer(pos)
					end
				elseif fallthru[bnode.name] then
					local node = core.get_node(pos)
					if node.name ~= bnode.name then
						nc.log("action",
							node.name .. " unsuspend at "
							.. core.pos_to_string(pos))
						core.check_for_falling(pos)
						if core.get_node(pos).name ~= node.name
						and toomanyents() then break end
					end
				end
			end
			batchpos = batchpos + 1
			if core.get_us_time() >= stop then break end
		end
	end)

nc.register_lbm({
		name = core.get_current_modname() .. ":unsuspend",
		run_at_every_load = true,
		nodenames = {"group:falling_node"},
		action = pend
	})

core.register_abm({
		label = core.get_current_modname() .. ":unsuspend",
		nodenames = {"group:falling_node"},
		interval = 10,
		chance = 10,
		action = pend
	})
