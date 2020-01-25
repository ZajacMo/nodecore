-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local footsteps = {}

minetest.unregister_chatcommand("kill")

minetest.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		inv:set_size("main", 8)
		inv:set_size("craft", 0)
		inv:set_size("craftpreview", 0)
		inv:set_size("craftresult", 0)

		player:set_physics_override({speed = 1.4})

		player:set_properties({
				pointable = false,
				makes_footstep_sound = true,

				-- Allow slight zoom for screenshots
				zoom_fov = 60
			})
		footsteps[player:get_player_name()] = true
	end)

minetest.register_allow_player_inventory_action(function(_, action)
		return action == "move" and 0 or 1000000
	end)

local focuscache = {}
local function focustime(player)
	local pname = player:get_player_name()
	local focusing = player:get_player_control_bits() == 64
	local meta = player:get_meta()
	local zoom = 60
	if focusing then
		local fc = focuscache[pname]
		if not fc then
			fc = meta:get_float("focustime")
			focuscache[pname] = fc
		end
		zoom = 15 + 45 / ((nodecore.gametime - fc) / 2 + 1)
	else
		meta:set_float("focustime", nodecore.gametime)
		focuscache[pname] = nodecore.gametime
	end
	local props = player:get_properties()
	if props.zoom_fov > (zoom * 1.02) or props.zoom_fov < zoom then
		player:set_properties({zoom_fov = zoom})
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

local function setfootsteps(player)
	local value = nodecore.player_visible(player)
	and (not player:get_player_control().sneak)
	local pname = player:get_player_name()
	if footsteps[pname] ~= value then
		player:set_properties({
				makes_footstep_sound = value
			})
		footsteps[pname] = value
	end
end

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			focustime(player)
			privdropinv(player)
			setfootsteps(player)
		end
	end)
