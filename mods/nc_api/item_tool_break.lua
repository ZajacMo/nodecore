-- LUALOCALS < ---------------------------------------------------------
local ItemStack, nodecore, type
    = ItemStack, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local function breakfx(who, def)
	if def.sound and def.sound.breaks then
		nodecore.sound_play(def.sound.breaks,
			{object = who, gain = 0.5})
	end
	return nodecore.toolbreakparticles(who, def, 40)
end
nodecore.toolbreakeffects = breakfx

nodecore.register_on_register_item(function(_, def)
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
