-- LUALOCALS < ---------------------------------------------------------
local math, minetest, os, pairs, table
    = math, minetest, os, pairs, table
local math_floor, os_date, table_concat
    = math.floor, os.date, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local anim = {
	stand     = {x = 0,   y = 0},
	sit       = {x = 1,   y = 1},
	walk      = {x = 2,   y = 42},
	mine      = {x = 43,  y = 57,  speed = 0.85},
	lay       = {x = 58,  y = 58},
	walk_mine = {x = 59,  y = 103},
	swim_up   = {x = 105, y = 162, speed = 0.4},
	swim_down = {x = 163, y = 223, speed = 0.4}
}

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
		local a = anim[x] or anim.stand
		player:set_animation({x = a.x, y = a.y},
			72 * (a.speed or 1))
	end)
local setskin = setcached(function(player, x)
		player:set_properties({textures = {x}})
	end)

local skintimes = {}
local dayskins = {
	day_2_14 = true,
	day_3_17 = true,
	day_4_1 = true,
	day_10_31 = true
}

local liquids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.liquidtype and v.liquidtype ~= "none" then
				liquids[k] = true
			end
		end
	end)
local function swimming(player)
	local found = 0
	local pos = player:get_pos()
	local r = 0.6
	for dz = -r, r, r do
		for dx = -r, r, r do
			local p = {
				x = pos.x + dx,
				y = pos.y,
				z = pos.z + dz
			}
			local node = minetest.get_node(p)
			if (node.name == "air" or liquids[node.name]) then
				p.y = p.y - 0.35
				node = minetest.get_node(p)
			end
			if not liquids[node.name] then return end
		end
	end
	return true
end

local function updatevisuals(player)
	local hp = player:get_hp()
	if hp <= 0 then
		setanim(player, "lay")
	else
		local ctl = player:get_player_control()
		local walk = ctl.up or ctl.down or ctl.right or ctl.left
		local mine = ctl.LMB or ctl.RMB

		if not swimming(player) then
			if walk and mine then
				setanim(player, "walk_mine")
			elseif walk then
				setanim(player, "walk")
			elseif mine then
				setanim(player, "mine")
			else
				setanim(player, "stand")
			end
		else
			local v = player:get_player_velocity()

			if mine then
				setanim(player, "walk_mine")
			elseif v and v.y >= -0.5 then
				setanim(player, "swim_up")
			else
				setanim(player, "swim_down")
			end
		end
	end

	local pname = player:get_player_name()
	local now = minetest.get_us_time() / 1000000
	local last = skintimes[pname] or 0
	if now < last + 2 then return end
	skintimes[pname] = now

	local layers = {"base.png"}
	local date = os_date("!*t")
	local bare = "day_" .. date.month .. "_" .. date.day
	if dayskins[bare] then layers[#layers + 1] = bare .. ".png" end
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
		player:set_properties({
				visual = "mesh",
				visual_size = {x = 0.9, y = 0.9, z = 0.9},
				mesh = modname .. ".b3d"
			})
		setskin(player, "dummy")
		setanim(player, "dummy")
		updatevisuals(player)
	end)

minetest.register_globalstep(function(dt)
		for _, player in pairs(minetest.get_connected_players()) do
			updatevisuals(player)
		end
	end)
