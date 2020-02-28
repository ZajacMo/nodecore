-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local particle = modname .. "_base.png^[mask:" .. modname .. "_dot_mask.png^[opacity:32"

local function check(pos, player)
	local p = player:get_pos();
	p = {
		x = p.x + nodecore.boxmuller() * 2,
		y = p.y + nodecore.boxmuller() * 2,
		z = p.z + nodecore.boxmuller() * 2,
	}
	local light = nodecore.get_node_light(p)
	if (not light) or (light >= math_random(4, 8)) then return end
	local rel = vector.subtract(p, pos)
	local dsqr = vector.dot(rel, rel)
	if math_random() * 128 < dsqr then return end
	local pname = player:get_player_name()
	minetest.after(math_random(), function()
			minetest.add_particle({
					pos = p,
					vel = vector.multiply(vector.normalize(rel), 4),
					texture = particle,
					exptime = 0.25,
					playername = pname,
					glow = 8
				})
		end)
	return check(pos, player)
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
