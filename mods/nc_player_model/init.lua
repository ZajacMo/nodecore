-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table
    = minetest, nodecore, pairs, table
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local anim = {
	stand = {x = 0, y = 0},
	sit = {x = 1, y = 1},
	walk = {x = 2, y = 42},
	mine = {x = 43, y = 57, speed = 0.85},
	lay = {x = 58, y = 58},
	walk_mine = {x = 59, y = 103},
	swim_up = {x = 105, y = 162, speed = 0.4},
	swim_down = {x = 163, y = 223, speed = 0.4},
	swim_mine = {x = 224, y = 281, speed = 0.5}
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

local liquids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.liquidtype and v.liquidtype ~= "none" then
				liquids[k] = true
			end
		end
	end)
local function swimming(player)
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

nodecore.player_skin = nodecore.player_skin or function(player)
	local skin = player:get_meta():get_string("custom_skin") or ""
	if skin ~= "" then return skin end

	local layers = {modname .. "_base.png"}

	local privs = minetest.get_player_privs(player:get_player_name())
	if not privs.interact then
		layers[#layers + 1] = modname .. "_no_interact.png"
		layers[#layers + 1] = "[makealpha:254,0,253"
	end
	if not privs.shout then
		layers[#layers + 1] = modname .. "_no_shout.png"
	end

	return table_concat(layers, "^"), layers
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
				setanim(player, "swim_mine")
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
	if now >= last + 2 then
		skintimes[pname] = now
		setskin(player, nodecore.player_skin(player))
	end
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

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			if nodecore.player_visible(player) then
				updatevisuals(player)
			end
		end
	end)
