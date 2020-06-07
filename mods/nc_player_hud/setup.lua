-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

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

local w = 640
local h = 360
local breath_txr = "[combine:" .. w .. "x" .. h
for y = 0, h - 1, 80 do
	for x = 0, w - 1, 80 do
		breath_txr = breath_txr .. ":" .. x .. "," .. y .. "=nc_player_hud_breath_texture.png"
	end
end
local breath_mask = "^[mask:nc_player_hud_breath_mask.png\\^[resize\\:" .. w .. "x" .. h

local function breath_hud(player)
	local br = player:get_breath()
	local brmax = player:get_properties().breath_max
	brmax = brmax ~= 0 and brmax or 10
	local img = ""
	local o = 255 * (1 - br / (brmax + 1))
	if o > 0 then
		img = breath_txr .. "^[colorize:#000000:" .. math_floor(255 - o)
		.. breath_mask .. "^[opacity:" .. math_floor(o)
	end
	nodecore.hud_set(player, {
			label = "breath",
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			text = img,
			direction = 0,
			scale = {x = -100, y = -100},
			offset = {x = 0, y = 0},
			quick = true
		})
end

minetest.register_on_joinplayer(function(player)
		sethudflags(player)
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("nc_player_hud_bar.png")
		player:hud_set_hotbar_selected_image("nc_player_hud_sel.png")
		breath_hud(player)
	end)

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			breath_hud(player)
		end
	end)
