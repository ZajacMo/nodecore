-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.rotate_node = function(itemstack, placer, pointed_thing)
	local invert_wall = placer and placer:get_player_control().sneak or false
	return minetest.rotate_and_place(itemstack, placer, pointed_thing, false,
		{invert_wall = invert_wall}, true)
end
