-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_entity("nc_api:stackent", {
		on_activate = function(self) return self.object:remove() end
	})
