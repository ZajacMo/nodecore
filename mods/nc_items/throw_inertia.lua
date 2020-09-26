-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local item_last_added

local old_add = minetest.add_item
function minetest.add_item(...)
	local function helper(obj, ...)
		item_last_added = obj
		return obj, ...
	end
	return helper(old_add(...))
end

local old_drop = minetest.item_drop
function minetest.item_drop(itemstack, dropper, ...)
	if not dropper or not dropper:is_player() then
		return old_drop(itemstack, dropper, ...)
	end
	local function helper(...)
		if item_last_added then
			item_last_added:add_velocity(dropper:get_player_velocity())
			local speed = vector.length(item_last_added:get_velocity())
			local disc = {}
			for i = 1, speed do disc["item_drop_speed_" .. i] = true end
			nodecore.player_discover(dropper, disc)
		end
		return ...
	end
	item_last_added = nil
	return helper(old_drop(itemstack, dropper, ...))
end
