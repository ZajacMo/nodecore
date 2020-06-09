-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, pairs, type
    = getmetatable, minetest, nodecore, pairs, type
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

local old_set_props

local function set_properties_compare(obj, def)
	if type(def) ~= "table" then return old_set_props(obj, def) end
	local old = obj:get_properties()
	if not old then return end
	if type(def) == "function" then
		def = def(old, obj)
	end
	local toset
	for k, v in pairs(def) do
		if mismatch(v, old[k]) then
			toset = toset or {}
			toset[k] = v
		end
	end
	return toset and old_set_props(obj, toset)
end

local function tryhook()
	for _, v in pairs(minetest.object_refs) do
		local mt = v and getmetatable(v)
		if mt and mt.set_properties then
			old_set_props = mt.set_properties
			mt.set_properties = set_properties_compare
			return
		end
	end
	return minetest.after(0, tryhook)
end
tryhook()

function nodecore.ent_prop_set(obj, def)
	minetest.log("warning", "WARNING: nodecore.ent_prop_set() is now deprecated;"
		.. " just use object:set_properties(), which has been patched")
	return obj:set_properties(def)
end
