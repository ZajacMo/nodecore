-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_playerstep({
		label = "player model visuals",
		action = function(player, data)
			if data.properties.visual_size.x <= 0 then return end

			local props = nodecore.player_visuals_base(player)

			-- Skin can be set preemptively by visuals_base; if so, then will
			-- not be modified here.
			if not props.textures then
				-- Recheck skin only every couple seconds to avoid
				-- interfering with animations if skin includes continuous
				-- effects.
				local now = minetest.get_us_time() / 1000000
				if (not data.skincalctime) or (now >= data.skincalctime + 2) then
					data.skincalctime = now
					local t = nodecore.player_skin(player)
					props.textures = {t}
				end
			end

			for k, v in pairs(props) do data.properties[k] = v end

			local anim = nodecore.player_anim(player)
			data.animation = {{x = anim.x, y = anim.y}, anim.speed}
		end
	})
