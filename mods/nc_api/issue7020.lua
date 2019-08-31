-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, setmetatable, type
    = minetest, pairs, setmetatable, type
-- LUALOCALS > ---------------------------------------------------------

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	set_node = function(self, node, meta, ...)
		meta = meta or {}
		if type(meta) ~= "table" then meta = meta:to_table() end
		for _, v1 in pairs(meta.inventory or {}) do
			for k2, v2 in pairs(v1) do
				if type(v2) == "userdata" then
					v1[k2] = v2:to_string()
				end
			end
		end
		return bifn.set_node(self, node, meta, ...)
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)
