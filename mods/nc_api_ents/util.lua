-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, pairs, type
    = getmetatable, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local mismatch = nodecore.prop_mismatch

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
	nodecore.log("warning", "nodecore.ent_prop_set() is now deprecated;"
		.. " just use object:set_properties(), which has been patched")
	return obj:set_properties(def)
end
