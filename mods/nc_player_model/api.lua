-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, table, tonumber, type,
      unpack
    = math, minetest, nodecore, pairs, string, table, tonumber, type,
      unpack
local math_ceil, math_floor, math_pi, math_sin, string_format,
      string_sub, table_concat
    = math.ceil, math.floor, math.pi, math.sin, string.format,
      string.sub, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local colorscache = {}
local function getcolor(hex)
	local theta = tonumber(hex, 16) / 32768 * math_pi
	local r = math_sin(theta + math_pi * 0/3) * 63 + 160
	local g = math_sin(theta + math_pi * 2/3) * 63 + 160
	local b = math_sin(theta + math_pi * 4/3) * 63 + 160
	return string_format("#%02x%02x%02x", math_ceil(r), math_ceil(g), math_ceil(b))
end
-- Returns unpacked, to prevent accidental cache poisoning
local function player_model_colors(name)
	local found = colorscache[name]
	if found then return unpack(found) end
	local hash = minetest.sha1(name)
	found = {
		getcolor(string_sub(hash, 1, 4)),
		getcolor(string_sub(hash, 5, 8)),
		getcolor(string_sub(hash, 9, 12)),
		getcolor(string_sub(hash, 13, 16))
	}
	colorscache[name] = found
	return unpack(found)
end
nodecore.player_model_colors = player_model_colors

local colorizedcache = {}
local function getcolors(name, layers)
	if name == "singleplayer" then return end

	local found = colorizedcache[name]
	if found then
		layers[#layers + 1] = found
		return
	end

	local colors = {player_model_colors(name)}
	for i = 1, #colors do
		colors[i] = string_format("(%s_color%d.png^[multiply:%s)",
			modname, i, colors[i])
	end
	found = table_concat(colors, "^")

	colorizedcache[name] = found
	layers[#layers + 1] = found
end

nodecore.player_skin = nodecore.player_skin or function(player, options)
	if type(options) ~= "table" then options = {} end

	local name = options.playername or player:get_player_name()
	local layers = {modname .. "_base.png"}

	getcolors(name, layers)

	local privs = options.privs or minetest.get_player_privs(
		options.privname or name)
	if options.noarms or not privs.interact then
		layers[#layers + 1] = modname .. "_no_interact.png"
		layers[#layers + 1] = "[makealpha:254,0,253"
	end
	if options.nomouth or not privs.shout then
		layers[#layers + 1] = modname .. "_no_shout.png"
	end

	return table_concat(layers, "^"), layers
end

nodecore.player_anim_data = nodecore.player_anim_data or {
	stand = {x = 0, y = 0},
	sit = {x = 1, y = 1},
	lay = {x = 2, y = 2},
	walk = {x = 3, y = 27},
	walk_mine = {x = 28, y = 52},
	mine = {x = 53, y = 77},
	swim_mine = {x = 78, y = 108, speed = 0.6, headpitch = 45},
	swim_up = {x = 109, y = 133, speed = 0.6, headpitch = 45},
	swim_down = {x = 134, y = 158, speed = 0.6, headpitch = 45},
	wave = {x = 159, y = 171, speed = 0.8}
}
for k, v in pairs(nodecore.player_anim_data) do
	v.name = k
	v.speed = 30 * (v.speed or 1)
end

local function walkspeed(player, anim)
	if not anim.speed then return anim end
	local phys = player:get_physics_override()
	local speed = math_floor(phys.speed * 10) / 10
	if speed == 1 then return anim end
	local t = {}
	for k, v in pairs(anim) do
		t[k] = (k == "speed") and (speed * v) or v
	end
	return t
end

local wave_cooldown = 1.2

nodecore.player_anim = nodecore.player_anim or function(player, data)
	local hp = player:get_hp()
	if hp <= 0 then
		return nodecore.player_anim_data.lay
	end

	local ctl = player:get_player_control()
	local walk = (ctl.up or ctl.down) and not (ctl.up and ctl.down)
	or (ctl.right or ctl.left) and not (ctl.right and ctl.left)
	local wielddef = player:get_wielded_item():get_definition()
	local mine = ctl.LMB and not (wielddef and wielddef.wield_no_anim_mine)
	or ctl.RMB and not (wielddef and wielddef.wield_no_anim_place)
	if data then
		if mine then data.animcontrol_mine_exp = nodecore.gametime + 0.25 end
		mine = mine or data.animcontrol_mine_exp and data.animcontrol_mine_exp >= nodecore.gametime
		or data.item_drop_time and data.item_drop_time > nodecore.gametime - 0.25
	end
	local aux = ctl.aux1 and not ctl.zoom
	if data then
		if aux then data.animcontrol_aux_exp = nodecore.gametime + 1 end
		aux = aux or data.animcontrol_aux_exp and data.animcontrol_aux_exp >= nodecore.gametime
	end

	if not nodecore.player_swimming(player) then
		if data and (walk or mine) then
			data.anim_wave_time = nodecore.gametime + wave_cooldown
		end
		if walk and mine then return walkspeed(player, nodecore.player_anim_data.walk_mine) end
		if walk then return walkspeed(player, nodecore.player_anim_data.walk) end
		if mine then return nodecore.player_anim_data.mine end
		if aux and not (data and data.anim_wave_time
			and data.anim_wave_time > nodecore.gametime) then
			return nodecore.player_anim_data.wave
		end
		return nodecore.player_anim_data.stand
	end
	if data then data.anim_wave_time = nodecore.gametime + wave_cooldown end

	if mine then return walkspeed(player, nodecore.player_anim_data.swim_mine) end
	if not (walk or ctl.jump or ctl.sneak or (ctl.left or ctl.right)
		and not (ctl.left and ctl.right)) then
		local t = {}
		for k, v in pairs(nodecore.player_anim_data.swim_up) do
			t[k] = (k == "speed") and (0.1 * v) or v
		end
		return t
	end
	local v = player:get_velocity()
	if v and v.y >= -0.5 then return walkspeed(player, nodecore.player_anim_data.swim_up) end
	return walkspeed(player, nodecore.player_anim_data.swim_down)
end

nodecore.player_visuals_base = nodecore.player_visuals_base or function(player)
	local mesh = player:get_meta():get_string("custom_mesh") or ""
	return {
		visual = "mesh",
		visual_size = {x = 0.9, y = 0.9, z = 0.9},
		mesh = mesh and mesh ~= "" and mesh or modname .. ".b3d"
	}
end
