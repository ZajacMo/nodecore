-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

local function setup(p)
	local n = p:get_player_name()

	local r = minetest.get_player_privs(n)
	r.fly = true
	r.fast = true
	r.give = true
	r.interact = true
	r.nc_reative = true
	minetest.set_player_privs(n, r)

	p:set_pos({x = -112.6, y = 5, z = -92.6})
	p:set_look_horizontal(163.8 * math_pi / 180)
	p:set_look_vertical(9 * math_pi / 180)

	p:hud_set_flags({crosshair = false})
end
nodecore.register_on_joinplayer(setup)
nodecore.register_on_respawnplayer(setup)
