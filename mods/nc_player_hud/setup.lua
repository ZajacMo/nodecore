-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hotbar_slots = 8

local function breathimg(br)
	local o = 255 * (1 - br / 11)
	if o == 0 then return "" end
	return modname .. "_breath.png^[opacity:"
	.. math_floor(o)
end

local function sethudflags(player, pname)
	local interact = nodecore.interact(pname or player)
	player:hud_set_flags({
			wielditem = interact or false,
			hotbar = interact or false,
			healthbar = false,
			breathbar = false,
			minimap = false,
			minimap_radar = false
		})
end

local function grantrevoke(pname)
	minetest.after(0, function()
			local player = minetest.get_player_by_name(pname)
			if player then return sethudflags(player, pname) end
		end)
end

minetest.register_on_priv_grant(grantrevoke)
minetest.register_on_priv_revoke(grantrevoke)

local hotbars = {}

local bar_scale = 32
local function sethotbar(player)
	local bar = "[combine:" .. (hotbar_slots * bar_scale) .. "x" .. bar_scale
	local inv = player:get_inventory()
	for i = 1, hotbar_slots do
		local stack = inv:get_stack("main", i)
		local def = stack and (not stack:is_empty()) and stack:get_definition()
		local suff = (i == player:get_wield_index()) and "_sel" or "_bar"
		if def and def.hotbar_type then
			suff = suff .. "_" .. def.hotbar_type
		end
		bar = bar .. ":" .. (i * bar_scale - bar_scale) .. ",0="
		.. modname .. suff .. ".png\\^[resize\\:" .. bar_scale .. "x" .. bar_scale
	end

	local pname = player:get_player_name()
	local old = hotbars[pname]
	if not old then
		old = {}
		hotbars[pname] = old
	end
	if old.bar ~= bar then
		player:hud_set_hotbar_image(bar)
		old.bar = bar
	end
end

minetest.register_on_leaveplayer(function(player)
		hotbars[player:get_player_name()] = nil
	end)

minetest.register_on_joinplayer(function(player)
		sethudflags(player)
		sethotbar(player)
		player:hud_set_hotbar_selected_image("[combine:1x1")

		if not minetest.settings:get_bool("enable_damage") then
			player:set_breath(11)
		end
		local img = breathimg(player:get_breath())
		nodecore.hud_set(player, {
				label = "breath",
				hud_elem_type = "image",
				position = {x = 0.5, y = 0.5},
				text = img,
				direction = 0,
				scale = {x = -100, y = -100},
				offset = {x = 0, y = 0}
			})
	end)

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			nodecore.hud_set(player, {
					label = "breath",
					text = breathimg(player:get_breath())
				})
			sethotbar(player)
		end
	end)
