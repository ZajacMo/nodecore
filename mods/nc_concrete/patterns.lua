-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, rawset, string
    = error, minetest, nodecore, pairs, rawset, string
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

local function regetched(basenode, etch, patt)
	local plyname = modname .. ":" .. etch.name .. "_" .. patt.name
	if not minetest.registered_nodes[plyname] then
		local def = nodecore.underride(etch, {

			}, basenode)
		minetest.register_node(plyname, def)
	end
	local pattname = modname .. ":" .. etch.name .. "_" .. patt.name
	if not minetest.registered_nodes[pattname] then
		local def = nodecore.underride(etch, {

			}, basenode)
		minetest.register_node(pattname, def)
	end
end

local function buildpatterns()
	for _, patt in pairs(nodecore.registered_concrete_patterns) do
		patt.name = patt.name or string_gsub(string_lower(patt.description),
			"%W", "_")
		patt.pattern_tile = patt.pattern_tile or string_gsub(
			"^(#_etched.png^[mask:#_pattern_" .. patt.name
			.. ".png^[opacity:128)", "#", modname)
	end
	for _, etch in pairs(nodecore.registered_concrete_etchables) do
		if not etch.basename then return error("etchable basename required") end
		etch.name = etch.name or string_gsub(string_lower(string_gsub(
					etch.basename, "^nc_", "")), "%W", "_")
		etch.pliant_tile = etch.pliant_tile or "^" .. modname .. "_pliant.png"
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

nodecore.register_concrete_pattern({name = "blank", tile = ""})
nodecore.register_concrete_pattern({description = "Bricky"})
nodecore.register_concrete_pattern({description = "Vermi"})
nodecore.register_concrete_pattern({description = "Hashy"})
nodecore.register_concrete_pattern({description = "Bindy"})
nodecore.register_concrete_pattern({description = "Verti"})
nodecore.register_concrete_pattern({description = "Horzi"})
nodecore.register_concrete_pattern({description = "Icebox"})
nodecore.register_concrete_pattern({description = "Enol"})
