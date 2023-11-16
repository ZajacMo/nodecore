-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, minetest, nodecore, pairs, rawset, string, type
    = error, ipairs, minetest, nodecore, pairs, rawset, string, type
local string_gsub, string_lower
    = string.gsub, string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_concrete_pattern,
nodecore.registered_concrete_patterns
= nodecore.mkreg()

nodecore.register_concrete_etchable,
nodecore.registered_concrete_etchables
= nodecore.mkreg()

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
	def.groups = def.groups or {}
	def.groups[group] = def.groups[group] or 1
end

local function regetched(basenode, etch, patt)
	basenode = nodecore.underride({}, basenode)
	basenode.alternate_loose = nil
	basenode.after_dig_node = nil
	basenode.node_dig_prediction = nil
	basenode.silktouch = nil
	basenode.strata = nil
	local plyname = modname .. ":" .. etch.name .. "_" .. patt.name .. "_ply"
	if not minetest.registered_nodes[plyname] then
		local def = {}
		nodecore.underride(def, etch.pliant)
		nodecore.underride(def, etch)
		nodecore.underride(def, patt)
		nodecore.underride(def, basenode)
		def.tiles = applytile(def.tiles, patttile(etch, patt))
		def.tiles = applytile(def.tiles, etch.pliant_tile)
		def.name = nil
		def.description = (patt.blank and "" or (patt.description .. " "))
		.. "Pliant " .. basenode.description
		def.pattern_def = patt
		def.etch_def = etch
		def.groups = def.groups or {}
		if not patt.blank then
			defaultgroup(def, modname .. "_pattern_" .. patt.name)
		end
		defaultgroup(def, modname .. "_pliant")
		if def.paramtype2 == "4dir" then
			def.on_rightclick = function(pos, node)
				node.param2 = (node.param2 + 1) % 4
				nodecore.set_loud(pos, node)
			end
		end
		minetest.register_node(":" .. plyname, def)
	end
	if not patt.blank then
		local pattname = modname .. ":" .. etch.name .. "_" .. patt.name
		if not minetest.registered_nodes[pattname] then
			local def = {}
			nodecore.underride(def, etch.solid)
			nodecore.underride(def, etch)
			nodecore.underride(def, patt)
			nodecore.underride(def, basenode)
			def.tiles = applytile(def.tiles, patttile(etch, patt))
			def.name = nil
			def.description = (patt.blank and "" or (patt.description .. " "))
			.. basenode.description
			def.pattern_def = patt
			def.etch_def = etch
			if not patt.blank then
				defaultgroup(def, modname .. "_pattern_" .. patt.name)
			end
			defaultgroup(def, modname .. "_etched")
			minetest.register_node(":" .. pattname, def)
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
	for _, patt in pairs(nodecore.registered_concrete_patterns) do
		patt.name = patt.name or string_gsub(string_lower(patt.description),
			"%W", "_")
		patt.pattern_tile = patt.pattern_tile or string_gsub(
			"#_etched.png^[mask:#_pattern_" .. patt.name
			.. ".png", "#", modname)
	end
	for _, etch in pairs(nodecore.registered_concrete_etchables) do
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
	for _, etch in pairs(nodecore.registered_concrete_etchables) do
		local basenode = minetest.registered_nodes[etch.basename]
		if basenode then
			for _, patt in pairs(nodecore.registered_concrete_patterns) do
				regetched(basenode, etch, patt)
			end
		end
	end
end

minetest.after(0, function()
		local patts = nodecore.registered_concrete_patterns
		for i, patt in ipairs(patts) do
			patt.next = patts[(i < #patts) and (i + 1) or 1]
		end
	end)

for k in pairs({
		register_concrete_pattern = true,
		register_concrete_etchable = true
	}) do
	local old = nodecore[k];
	rawset(nodecore, k, function(...)
			local function helper(...)
				buildpatterns()
				return ...
			end
			return helper(old(...))
		end)
end

nodecore.register_concrete_pattern({description = "Blank", blank = true})
nodecore.register_concrete_pattern({description = "Bricky"})
nodecore.register_concrete_pattern({description = "Vermy"})
nodecore.register_concrete_pattern({description = "Hashy"})
nodecore.register_concrete_pattern({description = "Bindy"})
nodecore.register_concrete_pattern({description = "Verty", paramtype2 = "4dir"})
nodecore.register_concrete_pattern({description = "Horzy", paramtype2 = "4dir"})
nodecore.register_concrete_pattern({description = "Boxy"})
nodecore.register_concrete_pattern({description = "Iceboxy"})
