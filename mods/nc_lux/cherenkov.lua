-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function check(pos, player)
	local p = player:get_pos();
	p = {
		x = p.x + math_random() * 8 - 4,
		y = p.y + math_random() * 8 - 4,
		z = p.z + math_random() * 8 - 4,
	}
	local rel = vector.subtract(p, pos)
	local dsqr = rel.x * rel.x + rel.y * rel.y + rel.z * rel.z
	if math_random() * 512 < dsqr then return end
	minetest.add_particlespawner({
			amount = math_floor(math_random() * 5) + 1,
			time = 0.1,
			minpos = p,
			maxpos = p,
			minvel = vector.multiply(vector.normalize(rel), 4),
			maxvel = vector.multiply(vector.normalize(rel), 8),
			texture = modname .. "_base.png^[mask:" .. modname .. "_mask.png^[opacity:32",
			minexptime = 0.05,
			maxexptime = 0.25,
			playername = player:get_player_name(),
			glow = 1
		})
end

nodecore.register_limited_abm({
		label = "Lux Reaction",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_emit"},
		action = function(pos)
			for _, player in pairs(minetest.get_connected_players()) do
				check(pos, player)
			end
		end
	})
