-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, string, table
    = minetest, nodecore, pairs, rawset, string, table
local string_format, table_concat, table_sort
    = string.format, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local muxdefs = {}
local abmsdefined = {}

nodecore.register_on_register_item(function(name, def)
		if def.type == "node" then
			for _, mux in pairs(muxdefs) do
				if (not (def.groups and def.groups[mux.muxkey]))
				and nodecore.would_match(name, def, mux.nodenames) then
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

local totaltime = 0
local function totaltimeupdate(start)
	totaltime = totaltime + (minetest.get_us_time() - start) / 1000000
end
local nodes = 0
local actions = 0

local statinterval = nodecore.setting_float(minetest.get_current_modname()
	.. "_abm_stat_time", 300, "ABM Statistics Interval",
	[[Time in seconds between ABM performance statistics being.
	written to the log.]])
if statinterval > 0 then
	local players = 0
	local started = minetest.get_us_time() / 1000000
	local function statistics()
		local now = minetest.get_us_time() / 1000000
		local elapsed = now - started
		started = now
		if actions > 0 then
			local rawtime = totaltime
			local top = {}
			for _, def in pairs(muxdefs) do
				totaltime = totaltime - def.timeused
				top[def.label] = def
			end
			top.overhead = {runcount = actions, timeused = totaltime}
			local topkeys = {}
			for k in pairs(top) do topkeys[#topkeys + 1] = k end
			table_sort(topkeys, function(a, b)
					return top[b].timeused < top[a].timeused
				end)
			while #topkeys > 20 do topkeys[#topkeys] = nil end
			for i = 1, #topkeys do
				topkeys[i] = string_format("%s*%d=%0.2f%%",
					topkeys[i],
					top[topkeys[i]].runcount,
					top[topkeys[i]].timeused / rawtime * 100)
			end
			nodecore.log("action", string_format("ABM average"
					.. " %0.2f actions for %0.2f nodes"
					.. " with %0.2f players, %0.2f%% running, top: %s",
					actions / elapsed, nodes / elapsed,
					players / elapsed, rawtime / elapsed * 100,
					table_concat(topkeys, "; ")))
		end
		for _, def in pairs(muxdefs) do
			def.timeused = 0
			def.runcount = 0
		end
		nodes = 0
		actions = 0
		players = 0
		totaltime = 0
		minetest.after(statinterval, statistics)
	end
	minetest.after(statinterval, statistics)
	local function pcount()
		players = players + #minetest.get_connected_players()
		minetest.after(1, pcount)
	end
	minetest.after(1, pcount)
end

local anonid = 1
local function runaction(def, ...)
	local start = minetest.get_us_time()
	actions = actions + 1
	def.action(...)
	def.runcount = def.runcount + 1
	def.timeused = def.timeused + (minetest.get_us_time() - start) / 1000000
end
local oldreg = minetest.register_abm
function minetest.register_abm(def)
	local rawkey = table_concat({
			def.interval or 1,
			def.chance or 1,
			def.catchup and 1 or 0,
			table_concat(def.neighbors or {}, ";")
		}, "|")
	def.rawkey = rawkey
	local muxkey = minetest.sha1(rawkey):sub(1, 8)
	def.muxkey = muxkey
	def.timeused = 0
	def.runcount = 0
	if not def.label then
		def.label = "unknown " .. anonid .. " " .. minetest.get_current_modname()
		anonid = anonid + 1
	end
	muxdefs[#muxdefs + 1] = def
	for k, v in pairs(minetest.registered_nodes) do
		if (not v.groups[muxkey]) and nodecore.would_match(k, v, def.nodenames) then
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
				local start = minetest.get_us_time()
				nodes = nodes + 1
				local oldname = node.name
				local found = muxidx[muxkey .. oldname]
				if not found then
					warnunused(oldname)
					return totaltimeupdate(start)
				end
				runaction(found[1], pos, node, ...)
				if #found <= 1 then
					return totaltimeupdate(start)
				end
				for i = 2, #found do
					if minetest.get_node(pos).name ~= oldname then
						return totaltimeupdate(start)
					end
					runaction(found[i], pos, node, ...)
				end
				return totaltimeupdate(start)
			end
		})
end
