-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, vector
    = minetest, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local function dofx(player, pname, pos, lookdir, pl, partdef)
	local pn = pl:get_player_name()
	if pn == pname then return end

	local pp = pl:get_pos()
	pp.y = pp.y + pl:get_properties().eye_height
	if vector.distance(pos, pp) > 32 then return end

	partdef.playername = pn
	minetest.add_particlespawner(partdef)

	local gain = vector.dot(lookdir, vector.normalize(vector.subtract(pp, pos)))
	gain = (gain + 2) / 3
	minetest.sound_play("nc_player_chat", {
			object = player,
			to_player = pn,
			gain = gain
		})
end

minetest.register_on_chat_message(function(pname)
		if not minetest.check_player_privs(pname, "shout") then return end

		local player = minetest.get_player_by_name(pname)
		if not player then return end

		local pos = player:get_pos()
		pos.y = pos.y + player:get_properties().eye_height

		local lookdir = player:get_look_dir()
		lookdir.y = 0
		local partdir = vector.multiply(lookdir, 3)
		partdir.y = -2

		local partdef = {
			amount = 10,
			time = 0.25,
			minpos = pos,
			maxpos = pos,
			minvel = vector.add(partdir, {x = -2, y = -2, z = -2}),
			maxvel = vector.add(partdir, {x = 2, y = 2, z = 2}),
			minacc = {x = 0, y = 8, z = 0},
			maxacc = {x = 0, y = 8, z = 0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 2,
			maxsize = 3,
			texture = "nc_player_chat.png"
		}

		for _, pl in pairs(minetest.get_connected_players()) do
			dofx(player, pname, pos, lookdir, pl, partdef)
		end
	end)
