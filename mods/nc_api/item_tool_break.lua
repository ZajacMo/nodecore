-- LUALOCALS < ---------------------------------------------------------
local ItemStack, nc, type
    = ItemStack, nc, type
-- LUALOCALS > ---------------------------------------------------------

local function breakfx(who, def)
	if def.sound and def.sound.breaks then
		nc.sound_play(def.sound.breaks,
			{object = who, gain = 0.5})
	end
	return nc.toolbreakparticles(who, def, 40)
end
nc.toolbreakeffects = breakfx

nc.register_on_register_item(function(_, def)
		if def.tool_wears_to or def.type == "tool" then
			def.after_use = def.after_use or function(what, who, node, dp, ...)
				what:add_wear(dp.wear)
				if what:get_count() == 0 then
					breakfx(who, def)
					if type(def.tool_wears_to) == "function" then
						return def.tool_wears_to(what, who, node, dp, ...)
					else
						return ItemStack(def.tool_wears_to or "")
					end
				end
				return what
			end
		end
	end)
