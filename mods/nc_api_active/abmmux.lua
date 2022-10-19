-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, string, table
    = minetest, nodecore, pairs, rawset, string, table
local string_format, table_concat
    = string.format, table.concat
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

local rawreg = {}
nodecore.registered_abms_demux = rawreg

local anonid = 1
local function runaction(def, ...)
	local start = minetest.get_us_time()
	def.action(...)
	def.runcount = def.runcount + 1
	def.timeused = def.timeused + (minetest.get_us_time() - start) / 1000000
end
local oldreg = minetest.register_abm
function minetest.register_abm(def)
	rawreg[#rawreg + 1] = def
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
	local function warnunused(nn, pos)
		if warned[nn] then return end
		warned[nn] = true
		return nodecore.log("warning", string_format(
				"no abm found for mux %q node %s at %s",
				rawkey, nn, minetest.pos_to_string(pos)))
	end
	return oldreg({
			label = "mux abm for " .. rawkey,
			interval = def.interval,
			chance = def.chance,
			catchup = def.catchup,
			neighbors = def.neighbors,
			nodenames = {"group:abmmux_" .. muxkey},
			action = function(pos, node, ...)
				local oldname = node.name
				local found = muxidx[muxkey .. oldname]
				if not found then
					return warnunused(oldname, pos)
				end
				runaction(found[1], pos, node, ...)
				if #found <= 1 then return end
				for i = 2, #found do
					if minetest.get_node(pos).name ~= oldname then return end
					runaction(found[i], pos, node, ...)
				end
			end
		})
end
