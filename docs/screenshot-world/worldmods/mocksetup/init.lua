-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

local function setup(p)
	local n = p:get_player_name()

	local r = minetest.get_player_privs(n)
	r.fly = true
	r.fast = true
	r.noclip = true
	r.debug = true
	r.basic_debug = true
	r.give = true
	r.pulverize = true
	r.interact = true
	r.keepinv = true
	r.ncdqd = true
	r.teleport = true
	minetest.set_player_privs(n, r)

	p:set_pos({x = -112.4, y = 5, z = -91.8})
	p:set_look_horizontal(163.8 * math_pi / 180)
	p:set_look_vertical(9 * math_pi / 180)

	p:hud_set_flags({crosshair = false})
end
nodecore.register_on_joinplayer(setup)
nodecore.register_on_respawnplayer(setup)

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			nodecore.hud_set(player, {label = "cheats", ttl = 0})
		end
	end)
