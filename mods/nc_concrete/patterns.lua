-- LUALOCALS < ---------------------------------------------------------
local core, error, ipairs, nc, pairs, rawset, string, type
    = core, error, ipairs, nc, pairs, rawset, string, type
local string_gsub, string_lower
    = string.gsub, string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_concrete_pattern,
nc.registered_concrete_patterns
= nc.mkreg()

nc.register_concrete_etchable,
nc.registered_concrete_etchables
= nc.mkreg()

local function applytile(tiles, spec)
	if not spec then return tiles end
	local newt = {}
	for k, v in pairs(tiles) do
		if type(spec) == "function" then
			newt[k] = spec(v)
		else
			newt[k] = v .. spec
		end
	end
	return newt
end

local function patttile(etch, patt)
	if patt.blank then return function(...) return ... end end
	return function(t)
		return t .. "^(" .. patt.pattern_tile
		.. (etch.pattern_invert and "^[invert:rgb" or "")
		.. "^[opacity:" .. (etch.pattern_opacity or 64) .. ")"
	end
end

local function defaultgroup(def, group)
	local groups = {}
	if def.groups then
		for k, v in pairs(def.groups) do groups[k] = v end
	end
	groups[group] = groups[group] or 1
	def.groups = groups
end

local function regetched(basenode, etch, patt)
	basenode = nc.underride({}, basenode)
	basenode.alternate_loose = nil
	basenode.after_dig_node = nil
	basenode.node_dig_prediction = nil
	basenode.silktouch = nil
	basenode.strata = nil
	local plyname = modname .. ":" .. etch.name .. "_" .. patt.name .. "_ply"
	if not core.registered_nodes[plyname] then
		local def = {}
		nc.underride(def, etch.pliant)
		nc.underride(def, etch)
		nc.underride(def, patt)
		nc.underride(def, basenode)
		def.tiles = applytile(def.tiles, patttile(etch, patt))
		def.tiles = applytile(def.tiles, etch.pliant_tile)
		def.name = nil
		def.description = (patt.blank and "" or (patt.description .. " "))
		.. "Pliant " .. basenode.description
		def.pattern_def = patt
		def.etch_def = etch
		if not patt.blank then
			defaultgroup(def, modname .. "_pattern_" .. patt.name)
		end
		defaultgroup(def, modname .. "_pliant")
		if def.paramtype2 == "4dir" then
			def.on_rightclick = function(pos, node)
				node.param2 = (node.param2 + 1) % 4
				nc.set_loud(pos, node)
			end
		end
		core.register_node(":" .. plyname, def)
	end
	if not patt.blank then
		local pattname = modname .. ":" .. etch.name .. "_" .. patt.name
		if not core.registered_nodes[pattname] then
			local def = {}
			nc.underride(def, etch.solid)
			nc.underride(def, etch)
			nc.underride(def, patt)
			nc.underride(def, basenode)
			def.tiles = applytile(def.tiles, patttile(etch, patt))
			def.name = nil
			def.description = (patt.blank and "" or (patt.description .. " "))
			.. basenode.description
			def.pattern_def = patt
			def.etch_def = etch
			defaultgroup(def, modname .. "_pattern_" .. patt.name)
			defaultgroup(def, modname .. "_etched")
			core.register_node(":" .. pattname, def)
		end
	end
end

local mudgroups = {
	cracky = 0,
	crumbly = 1,
	snappy = 0,
	choppy = 0,
	stone = 0,
	smoothstone = 0,
	rock = 0
}
local function buildpatterns()
	for _, patt in pairs(nc.registered_concrete_patterns) do
		nc.translate_inform(patt.description)
		patt.name = patt.name or string_gsub(string_lower(patt.description),
			"%W", "_")
		patt.pattern_tile = patt.pattern_tile or string_gsub(
			"#_etched.png^[mask:#_pattern_" .. patt.name
			.. ".png", "#", modname)
	end
	for _, etch in pairs(nc.registered_concrete_etchables) do
		if not etch.basename then return error("etchable basename required") end
		etch.name = etch.name or string_gsub(string_lower(string_gsub(
					etch.basename, "^nc_", "")), "%W", "_")
		etch.pliant_tile = etch.pliant_tile or "^(" .. modname
		.. "_pliant.png^[opacity:" .. (etch.pliant_opacity or 64) .. ")"
		etch.pliant = etch.pliant or {}
		etch.pliant.groups = etch.pliant.groups or mudgroups
		etch.pliant.groups.concrete_etchable = 1
		etch.solid = etch.solid or {}
		etch.drop_in_place = etch.drop_in_place or etch.basenode
	end
	for _, etch in pairs(nc.registered_concrete_etchables) do
		local basenode = core.registered_nodes[etch.basename]
		if basenode then
			for _, patt in pairs(nc.registered_concrete_patterns) do
				regetched(basenode, etch, patt)
			end
		end
	end
end

core.after(0, function()
		local patts = nc.registered_concrete_patterns
		for i, patt in ipairs(patts) do
			patt.next = patts[(i < #patts) and (i + 1) or 1]
		end
	end)

for k in pairs({
		register_concrete_pattern = true,
		register_concrete_etchable = true
	}) do
	local old = nc[k];
	rawset(nc, k, function(...)
			local function helper(...)
				buildpatterns()
				return ...
			end
			return helper(old(...))
		end)
end

nc.register_concrete_pattern({description = "Blank", blank = true})
nc.register_concrete_pattern({description = "Bricky"})
nc.register_concrete_pattern({description = "Vermy"})
nc.register_concrete_pattern({description = "Hashy"})
nc.register_concrete_pattern({description = "Bindy"})
nc.register_concrete_pattern({description = "Verty", paramtype2 = "4dir"})
nc.register_concrete_pattern({description = "Horzy", paramtype2 = "4dir"})
nc.register_concrete_pattern({description = "Boxy"})
nc.register_concrete_pattern({description = "Iceboxy"})
