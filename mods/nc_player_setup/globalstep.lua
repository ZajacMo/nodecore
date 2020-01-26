-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pi, math_sin
    = math.pi, math.sin
-- LUALOCALS > ---------------------------------------------------------

local zoom_base = 60 * nodecore.rate_adjustment("zoom", "base")
local zoom_ratio = 1 - 1 / (4 * nodecore.rate_adjustment("zoom", "ratio"))
local zoom_time = 2 * nodecore.rate_adjustment("zoom", "time")
local function focustime(player, cached, set)
	local focusing = player:get_player_control_bits() == 64
	local zoom = zoom_base
	if focusing and cached.focus then
		zoom = zoom_base - zoom_base * zoom_ratio * (1 - 1 /
			((nodecore.gametime - cached.focus) / zoom_time + 1))
	else
		cached.focus = nodecore.gametime
	end
	local props = player:get_properties()
	if props.zoom_fov > (zoom * 1.02) or props.zoom_fov < zoom then
		set.props = set.props or {}
		set.props.zoom_fov = zoom
	end
end

local function privdropinv(player)
	if nodecore.interact(player) then return end
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local inv = player:get_inventory()
	for i, stack in pairs(inv:get_list("main")) do
		if not stack:is_empty() then
			if nodecore.item_is_virtual(stack) then
				nodecore.item_eject(pos, stack, 0.001)
				inv:set_stack("main", i, "")
			end
		end
	end
end

local function setfootsteps(player, cached, set)
	local value = nodecore.player_visible(player)
	and (not player:get_player_control().sneak)
	if cached.footsteps ~= value then
		set.props = set.props or {}
		set.props.makes_footstep_sound = value
		cached.footsteps = value
	end
end

local function fallspeed(player, cached, set)
	local g = nodecore.grav_air_physics_player(player:get_player_velocity())
	if g ~= cached.fallspeed then
		set.physics = set.physics or {}
		set.physics.gravity = g
		player:set_physics_override({gravity = g})
		cached.fallspeed = g
	end
end

local function solid(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if not def then return true end
	return def.liquidtype == "none" and def.walkable
end

local autorun_walkspeed = 1.25 * nodecore.rate_adjustment("autorun", "walkspeed")
local autorun_walktime = 2 * nodecore.rate_adjustment("waautorunlk", "walktime")
local autorun_acceltime = 4 * nodecore.rate_adjustment("autorun", "acceltime")
local autorun_ratio = 2 * nodecore.rate_adjustment("autorun", "ratio")
local function walkspeed(player, cached, set)
	local ctl = player:get_player_control()
	local walking = ctl.up and not ctl.down
	if walking and ctl.sneak then
		local pos = player:get_pos()
		if not solid(pos) then
			pos.y = pos.y - 1
			walking = not solid(pos)
		end
	end
	local speed = autorun_walkspeed
	local max = autorun_walkspeed * autorun_ratio
	if walking and cached.walktime then
		local t = nodecore.gametime - cached.walktime - autorun_walktime
		if t > math_pi * autorun_acceltime then
			speed = max
		elseif t > 0 then
			local hr = (autorun_ratio - 1) / 2
			speed = autorun_walkspeed * (1 + hr + hr * math_sin(t
					/ autorun_acceltime - math_pi / 2))
		end
	else
		cached.walktime = nodecore.gametime
	end
	local phys = player:get_physics_override()
	if phys.speed > speed or phys.speed < (speed - 0.05)
	or (speed == max and phys.speed ~= max) then
		set.physics = set.physics or {}
		set.physics.speed = speed
	end
end

local cache = {}
minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local cached = cache[pname]
			if not cached then
				cached = {}
				cache[pname] = cached
			end
			local set = {}

			focustime(player, cached, set)
			privdropinv(player)
			setfootsteps(player, cached, set)
			fallspeed(player, cached, set)
			walkspeed(player, cached, set)

			if set.props then player:set_properties(set.props) end
			if set.physics then player:set_physics_override(set.physics) end
		end
	end)
minetest.register_on_leaveplayer(function(player)
		cache[player:get_player_name()] = nil
	end)
