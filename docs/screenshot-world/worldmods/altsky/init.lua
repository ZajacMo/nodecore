-- LUALOCALS < ---------------------------------------------------------
local nc
    = nc
-- LUALOCALS > ---------------------------------------------------------

local txr
nc.register_playerstep({
		label = "skyrealm skybox",
		priority = -1000,
		action = function(_, data)
			if not txr then
				if not (data.sky and data.sky.textures) then return end
				txr = data.sky.textures[1]
				txr = {txr, txr, txr, txr, txr, txr}
			end
			data.sky.textures = txr
		end
	})
