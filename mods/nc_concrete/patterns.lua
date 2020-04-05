-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, rawset, string, type
    = error, minetest, nodecore, pairs, rawset, string, type
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
		return t .. "^(" .. patt.pattern_tile .. "^[opacity:"
		.. (etch.pattern_opacity or 64) .. ")"
	end
end

local function regetched(basenode, etch, patt)
	basenode = nodecore.underride({}, basenode)
	basenode.drop = nil
	basenode.alternate_loose = nil
	basenode.drop_in_place = nil
	basenode.after_dig_node = nil
	basenode.node_dig_prediction = nil
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
		minetest.register_node(plyname, def)
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
			minetest.register_node(pattname, def)
		end
	end
end

local mudgroups = {
	cracky = 0,
	crumbly = 1,
	snappy = 0,
	choppy = 0
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
		.. "_pliant.png^[opacity:192)"
		etch.pliant = etch.pliant or {}
		etch.pliant.groups = etch.pliant.groups or mudgroups
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

for k in pairs({
		register_concrete_pattern = true,
		register_concrete_etchable = true
	}) do
	minetest.log(k)
	local old = nodecore[k];
	rawset(nodecore, k, function(...)
			local function helper(...)
				buildpatterns()
				return ...
			end
			return helper(old(...))
		end)
end

nodecore.register_concrete_pattern({name = "blank", blank = true})
nodecore.register_concrete_pattern({description = "Bricky"})
nodecore.register_concrete_pattern({description = "Vermi"})
nodecore.register_concrete_pattern({description = "Hashy"})
nodecore.register_concrete_pattern({description = "Bindy"})
nodecore.register_concrete_pattern({description = "Verti"})
nodecore.register_concrete_pattern({description = "Horzi"})
nodecore.register_concrete_pattern({description = "Icebox"})
nodecore.register_concrete_pattern({description = "Enol"})
