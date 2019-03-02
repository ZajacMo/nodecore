-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, table
    = math, minetest, nodecore, pairs, string, table
local math_floor, table_concat
    = math.floor, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local anim = {
	stand     = {x = 0,  y = 0},
	sit       = {x = 1,  y = 1},
	walk      = {x = 2,  y = 42},
	mine      = {x = 43, y = 57},
	lay       = {x = 58, y = 58},
	walk_mine = {x = 59, y = 103},
}
local animspeed = 57 * 1.25

local function setcached(func)
	local cache = {}
	return function(player, value)
		local pname = player:get_player_name()
		if cache[pname] == value then return end
		cache[pname] = value
		return func(player, value)
	end
end
local setanim = setcached(function(player, x)
		player:set_animation(anim[x] or anim.stand, animspeed)
	end)
local setskin = setcached(function(player, x)
		player:set_properties({textures = {x}})
	end)

local function updatevisuals(player)
	local hp = nodecore.getphealth(player)
	if hp <= 0 then
		setanim(player, "lay")
	else
		local ctl = player:get_player_control()
		local walk = ctl.up or ctl.down or ctl.right or ctl.left
		local mine = ctl.LMB or ctl.RMB
		if walk and mine then
			setanim(player, "walk_mine")
		elseif walk then
			setanim(player, "walk")
		elseif mine then
			setanim(player, "mine")
		else
			setanim(player)
		end
	end

	local layers = {"base.png"}
	local dmg = (1 - hp / 20) * 4
	local dmgi = math_floor(dmg)
	local dmgf = dmg - dmgi
	for i = 1, dmgi do
		layers[#layers + 1] = "damage" .. i .. ".png"
	end
	if dmgf > 0 then
		layers[#layers + 1] = "damage" .. (dmgi + 1)
		.. ".png^[opacity:" .. math_floor(256 * dmgf)
	end
	local privs = minetest.get_player_privs(player:get_player_name())
	if not privs.interact then layers[#layers + 1] = "no_interact.png" end
	if not privs.shout then layers[#layers + 1] = "no_shout.png" end
	for k, v in pairs(layers) do
		layers[k] = "(" .. modname .. "_" .. v .. ")"
	end
	setskin(player, table_concat(layers, "^") .. "^[makealpha:254,0,253")
end

minetest.register_on_joinplayer(function(player)
		local isold = minetest.get_version().string:sub(1, 2) == "0."
		player:set_properties({
				visual = "mesh",
				visual_size = {x = 1, y = 1, z = 1},
				mesh = modname .. (isold and "_old" or "") .. ".b3d"
			})
		player:set_local_animation(
			anim.stand,
			anim.walk,
			anim.mine,
			anim.walk_mine,
			animspeed)
		setskin(player, "dummy")
		setanim(player, "dummy")
		updatevisuals(player)
	end)

minetest.register_globalstep(function(dt)
		for _, player in pairs(minetest.get_connected_players()) do
			updatevisuals(player)
		end
	end)
