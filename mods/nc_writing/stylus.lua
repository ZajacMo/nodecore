-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stylus", {
		description = "Charcoal Stylus",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		tiles = {
			"nc_fire_coal_4.png",
			"nc_tree_tree_top.png",
			"nc_fire_coal_4.png^[lowpart:25:nc_tree_tree_side.png"
		},
		stack_max = 1,
		place_as_item = true,
		node_placement_prediction = "",
		groups = {
			firestick = 1,
			snappy = 1,
			flammable = 1,
		},
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_stack_touchtip = function(stack, desc)
			local glyph = stack:get_meta():get_int("glyph")
			glyph = nodecore.writing_glyphs[glyph]
			if not glyph then return desc end
			return desc .. "\n" .. glyph.name
		end
	})

nodecore.register_craft({
		label = "assemble charcoal stylus",
		normal = {y = 1},
		indexkeys = {"nc_fire:lump_coal"},
		nodes = {
			{match = "nc_fire:lump_coal", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = "air"},
		},
		after = function(pos)
			pos.y = pos.y - 1
			local item = ItemStack(modname .. ":stylus")
			item:get_meta():set_int("glyph", math_random(1, #nodecore.writing_glyphs))
			return nodecore.item_eject(pos, item)
		end
	})
