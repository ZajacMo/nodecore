-- LUALOCALS < ---------------------------------------------------------
local ItemStack, nodecore, vector
    = ItemStack, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local function breakfx(who, def)
	if def.sound and def.sound.breaks then
		nodecore.sound_play(def.sound.breaks,
			{object = who, gain = 0.5})
	end
	local pos = who:get_pos()
	if pos then
		pos.y = pos.y + who:get_properties().eye_height - 0.1
		local look = vector.multiply(who:get_look_dir(), 2)
		for _ = 1, 5 do
			nodecore.digparticles(def, {
					time = 0.05,
					amount = 10,
					minpos = pos,
					maxpos = pos,
					minvel = vector.add(look, {x = -2, y = -2, z = -2}),
					maxvel = vector.add(look, {x = 2, y = 2, z = 2}),
					minacc = {x = 0, y = -8, z = 0},
					maxacc = {x = 0, y = -8, z = 0},
					minexptime = 0.25,
					maxexptime = 1
				})
		end
	end
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
