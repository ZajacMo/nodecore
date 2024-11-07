-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, rawset, string, table
    = core, nc, pairs, rawset, string, table
local string_format, string_sub, table_concat
    = string.format, string.sub, table.concat
-- LUALOCALS > ---------------------------------------------------------

local muxdefs = {}
local abmsdefined = {}

local prefix = "abmmux_"

local function fixgroups(name, def)
	local groups = {}
	for k, v in pairs(def.groups or {}) do
		if v ~= 0 and string_sub(k, 1, #prefix) ~= prefix then
			groups[k] = v
		end
	end
	for _, mux in pairs(muxdefs) do
		if nc.would_match(name, def, mux.nodenames) then
			groups[prefix .. mux.muxkey] = 1
		end
	end
	return groups
end

nc.register_on_register_item(function(name, def)
		if def.type == "node" then
			rawset(def, "groups", fixgroups(name, def))
		end
	end)

local muxidx = nc.item_matching_index(muxdefs,
	function(i) return i.nodenames end,
	"register_abm",
	true,
	function(n, i) return i.muxkey .. n end
)

local rawreg = {}
nc.registered_abms_demux = rawreg

local anonid = 1
local function runaction(def, ...)
	local start = core.get_us_time()
	def.action(...)
	def.runcount = def.runcount + 1
	def.timeused = def.timeused + (core.get_us_time() - start) / 1000000
end
local oldreg = core.register_abm
function core.register_abm(def)
	rawreg[#rawreg + 1] = def
	local rawkey = table_concat({
			def.interval or 1,
			def.chance or 1,
			def.catchup and 1 or 0,
			table_concat(def.neighbors or {}, ";")
		}, "|")
	def.rawkey = rawkey
	local muxkey = core.sha1(rawkey):sub(1, 8)
	def.muxkey = muxkey
	def.timeused = 0
	def.runcount = 0
	if not def.label then
		def.label = "unknown " .. anonid .. " " .. core.get_current_modname()
		anonid = anonid + 1
	end
	muxdefs[#muxdefs + 1] = def
	for k, v in pairs(core.registered_nodes) do
		core.override_item(k, {groups = fixgroups(k, v)})
	end
	if abmsdefined[muxkey] then return end
	abmsdefined[muxkey] = true
	local warned = {}
	local function warnunused(nn, pos)
		if warned[nn] then return end
		warned[nn] = true
		return nc.log("warning", string_format(
				"no abm found for mux %q node %s at %s",
				rawkey, nn, core.pos_to_string(pos)))
	end
	return oldreg({
			label = "mux abm for " .. rawkey,
			interval = def.interval,
			chance = def.chance,
			catchup = def.catchup,
			neighbors = def.neighbors,
			nodenames = {"group:" .. prefix .. muxkey},
			action = function(pos, node, ...)
				local oldname = node.name
				local found = muxidx[muxkey .. oldname]
				if not found then
					return warnunused(oldname, pos)
				end
				runaction(found[1], pos, node, ...)
				if #found <= 1 then return end
				for i = 2, #found do
					if core.get_node(pos).name ~= oldname then return end
					runaction(found[i], pos, node, ...)
				end
			end
		})
end
