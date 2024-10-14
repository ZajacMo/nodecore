-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local old_place = core.item_place_node
function core.item_place_node(itemstack, placer, pointed_thing, ...)
	local old_add = core.add_node
	core.add_node = function(pos, node, ...)
		local function helper2(...)
			nc.craft_check(pos, node, nc.underride({
						action = "place",
						crafter = placer,
						pointed = pointed_thing
					}, pointed_thing.craftdata or {}))
			return ...
		end
		return helper2(old_add(pos, node, ...))
	end
	local function helper(...)
		core.add_node = old_add
		return ...
	end
	return helper(old_place(itemstack, placer, pointed_thing, ...))
end
