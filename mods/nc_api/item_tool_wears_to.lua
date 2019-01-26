-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item(function(name, def)
		if def.tool_wears_to then
			def.after_use = def.after_use or function(what, who, node, dp)
				what:add_wear(dp.wear)
				if what:get_count() == 0 then
					if def.sound and def.sound.breaks then
						minetest.sound_play(def.sound.breaks,
							{pos = who:get_pos(), gain = 0.5})
					end
					return ItemStack(def.tool_wears_to)
				end
				return what
			end
		end
	end)
