-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, table
    = minetest, nodecore, pairs, rawset, table
local table_concat
    = table.concat
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
	local warnunused
	warnunused = function()
		warnunused = function() end
		return nodecore.log("warning", "no abm found for mux " .. rawkey)
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
				if not found then return warnunused() end
				found[1].action(pos, node, ...)
				if #found <= 1 then return end
				for i = 2, #found do
					if minetest.get_node(pos).name ~= oldname then return end
					found[i].action(pos, node, ...)
				end
			end
		})
end
