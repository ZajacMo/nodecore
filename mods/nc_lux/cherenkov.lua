-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, vector
    = core, math, nc, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local particle = modname .. "_base.png^[mask:" .. modname .. "_dot_mask.png^[opacity:32"

local function check(pos, player)
	local p = player:get_pos()
	p = {
		x = p.x + nc.boxmuller() * 2,
		y = p.y + nc.boxmuller() * 2,
		z = p.z + nc.boxmuller() * 2,
	}
	local light = nc.get_node_light(p)
	if (not light) or (light >= math_random(4, 8)) then return end
	local rel = vector.subtract(p, pos)
	local dsqr = vector.dot(rel, rel)
	if math_random() * 128 < dsqr then return end
	local pname = player:get_player_name()
	core.after(math_random(), function()
			core.add_particle({
					pos = p,
					velocity = vector.multiply(vector.normalize(rel), 4),
					texture = particle,
					exptime = 0.25,
					playername = pname,
					glow = 8
				})
		end)
	return check(pos, player)
end

core.register_abm({
		label = "lux cherenkov",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_emit"},
		action = function(pos)
			for _, player in pairs(core.get_connected_players()) do
				check(pos, player)
			end
		end
	})
