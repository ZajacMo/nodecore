-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local old_place = minetest.item_place_node
function minetest.item_place_node(itemstack, placer, pointed_thing, ...)
	local old_add = minetest.add_node
	minetest.add_node = function(pos, node, ...)
		local function helper2(...)
			nodecore.craft_check(pos, node, nodecore.underride({
						action = "place",
						crafter = placer,
						pointed = pointed_thing
					}, pointed_thing.craftdata or {}))
			return ...
		end
		return helper2(old_add(pos, node, ...))
	end
	local function helper(...)
		minetest.add_node = old_add
		return ...
	end
	return helper(old_place(itemstack, placer, pointed_thing, ...))
end
