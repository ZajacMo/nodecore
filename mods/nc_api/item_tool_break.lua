-- LUALOCALS < ---------------------------------------------------------
local ItemStack, nodecore
    = ItemStack, nodecore
-- LUALOCALS > ---------------------------------------------------------

local function breakfx(who, def)
	if def.sound and def.sound.breaks then
		nodecore.sound_play(def.sound.breaks,
			{object = who, gain = 0.5})
	end
	return nodecore.toolbreakparticles(who, def, 40)
end

nodecore.register_on_register_item(function(_, def)
		if def.tool_wears_to or def.type == "tool" then
			def.after_use = def.after_use or function(what, who, _, dp)
				what:add_wear(dp.wear)
				if what:get_count() == 0 then
					breakfx(who, def)
					return ItemStack(def.tool_wears_to or "")
				end
				return what
			end
		end
	end)
