-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, string, table
    = minetest, nodecore, pairs, rawset, string, table
local string_format, table_concat
    = string.format, table.concat
-- LUALOCALS > ---------------------------------------------------------

local muxdefs = {}
local abmsdefined = {}

local grp = "group:"
local function matches(name, def, nodenames)
	for _, n in pairs(nodenames) do
		if name == n then return true
		elseif n:sub(1, #grp) == grp then
			local g = def.groups and def.groups[n:sub(#grp + 1)]
			if g and g > 0 then return true end
		end
	end
end

nodecore.register_on_register_item(function(name, def)
		if def.type == "node" then
			for _, mux in pairs(muxdefs) do
				if (not (def.groups and def.groups[mux.muxkey]))
				and matches(name, def, mux.nodenames) then
					rawset(def.groups, "abmmux_" .. mux.muxkey, 1)
				end
			end
		end
	end)

local muxidx = nodecore.item_matching_index(muxdefs,
	function(i) return i.nodenames end,
	"register_abm",
	true,
	function(n, i) return i.muxkey .. n end
)

local nodes = 0
local actions = 0
local started = minetest.get_us_time() / 1000000
local function statistics()
	local now = minetest.get_us_time() / 1000000
	local elapsed = now - started
	started = now
	nodecore.log("action", string_format("ABM average %0.2f actions for %0.2f nodes per second",
			actions / elapsed, nodes / elapsed))
	minetest.after(300, statistics)
end
minetest.after(300, statistics)

local oldreg = minetest.register_abm
function minetest.register_abm(def)
	local rawkey = table_concat({
			def.interval,
			def.chance,
			def.catchup and 1 or 0,
			table_concat(def.neighbors or {}, ";")
		}, "|")
	def.rawkey = rawkey
	local muxkey = minetest.sha1(rawkey):sub(1, 8)
	def.muxkey = muxkey
	muxdefs[#muxdefs + 1] = def
	for k, v in pairs(minetest.registered_nodes) do
		if (not v.groups[muxkey]) and matches(k, v, def.nodenames) then
			rawset(v.groups, "abmmux_" .. muxkey, 1)
			minetest.override_item(k, {groups = v.groups})
		end
	end
	if abmsdefined[muxkey] then return end
	abmsdefined[muxkey] = true
	local warned = {}
	local function warnunused(nn)
		if warned[nn] then return end
		warned[nn] = true
		return nodecore.log("warning", "no abm found for mux " .. rawkey
			.. " node " .. nn)
	end
	return oldreg({
			label = "mux abm for " .. rawkey,
			interval = def.interval,
			chance = def.chance,
			catchup = def.catchup,
			neighbors = def.neighbors,
			nodenames = {"group:abmmux_" .. muxkey},
			action = function(pos, node, ...)
				nodes = nodes + 1
				local oldname = node.name
				local found = muxidx[muxkey .. oldname]
				if not found then return warnunused(oldname) end
				actions = actions + 1
				found[1].action(pos, node, ...)
				if #found <= 1 then return end
				for i = 2, #found do
					if minetest.get_node(pos).name ~= oldname then return end
					actions = actions + 1
					found[i].action(pos, node, ...)
				end
			end
		})
end
