-- LUALOCALS < ---------------------------------------------------------
local math, nodecore
    = math, nodecore
local math_abs
    = math.abs
-- LUALOCALS > ---------------------------------------------------------

local granularity = 0.02

local function clamp(x)
	if x > 1 then return 1 end
	if x < 0 then return 0 end
	return x
end

nodecore.register_playerstep({
		label = "health visual effects",
		action = function(player, data, dtime)
			local old = data.phealth_fx_old or 0
			local new = clamp(1 - nodecore.getphealth(player) / 8)
			new = clamp(new ^ 0.5)
			local blend = 0.5 ^ dtime
			local cur = old * blend + new * (1 - blend)
			if cur - new < granularity then cur = new end
			cur = clamp(cur)
			data.phealth_fx_old = cur

			local setto = data.phealth_fx_setto or 0
			if cur ~= old and math_abs(cur - setto) < granularity then
				return
			end
			data.phealth_fx_setto = cur
			return player:set_lighting({
					bloom = {
						intensity = cur * 0.8,
						strength_factor = 1/8,
						radius = cur * 8,
					}
				})
		end
	})
