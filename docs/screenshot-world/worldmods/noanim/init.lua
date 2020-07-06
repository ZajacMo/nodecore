-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, type
    = minetest, nodecore, pairs, rawset, type
-- LUALOCALS > ---------------------------------------------------------

local function noanim(t)
	if type(t) ~= "table" then return t end
	if t.animation then
		rawset(t.animation, "length", 1000000)
	end
	for _, v in pairs(t) do noanim(v) end
	return t
end

for _, v in pairs(minetest.registered_nodes) do
	noanim(v.tiles)
	noanim(v.special_tiles)
end

nodecore.register_on_register_item(function(_, def)
		noanim(def.tiles)
		noanim(def.special_tiles)
	end)
