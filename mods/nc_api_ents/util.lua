-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs, type
    = nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function mismatch(a, b)
	if type(a) == "table" then
		if type(b) ~= "table" then return true end
		for k, v in pairs(a) do
			if mismatch(v, b[k]) then return true end
		end
		return
	end
	if type(a) == "number" and type(b) == "number" then
		local ratio = a / b
		-- Floating point rounding...
		if ratio > 0.99999 and ratio < 1.00001 then return end
	end
	return a ~= b
end

local sprite_vis = {sprite = true, upright_sprite = true}
local sprite_props = {initial_sprite_basepos = true, spritediv = true}

function nodecore.ent_prop_set(obj, def)
	local old = obj:get_properties()
	if not old then return end
	if type(def) == "function" then
		def = def(old, obj)
	end
	local issprite = sprite_vis[def.visual or old and old.visual or ""]
	local toset
	for k, v in pairs(def) do
		if (issprite or not sprite_props[k]) and mismatch(v, old[k]) then
			toset = toset or {}
			toset[k] = v
		end
	end
	return toset and obj:set_properties(toset)
end
