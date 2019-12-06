-- LUALOCALS < ---------------------------------------------------------
local minetest, rawset
    = minetest, rawset
-- LUALOCALS > ---------------------------------------------------------

-- minetest.rotate_node uses sneak to invert the wall/floor orientation
-- direction, but REMOVES the use of sneak to prevent right-click on the
-- underlying node, which is a far more important function.

minetest.rotate_node = function(itemstack, placer, pointed_thing)
	local invert_wall = placer and placer:get_player_control().sneak or false
	local function commit()
		return minetest.rotate_and_place(itemstack, placer, pointed_thing, false,
			{invert_wall = invert_wall}, true)
	end
	if not invert_wall then return commit() end

	local node = minetest.get_node_or_nil(pointed_thing.under)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	if not def.on_rightclick then return commit() end

	local oldrc = def.on_rightclick
	local function helper(...)
		rawset(def, "on_rightclick", oldrc)
		return ...
	end
	rawset(def, "on_rightclick", nil)
	return helper(commit())
end
