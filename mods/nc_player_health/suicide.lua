-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table
    = minetest, nodecore, pairs, table
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

local suiciding = {}

local function pstate(player)
	local pos = player:getpos()
	local dir = player:get_look_dir()
	return table_concat({
			pos.x, pos.y, pos.z,
			dir.x, dir.y, dir.z
			}, "|")
end

local function suicidecheck()
	minetest.after(0.5, suicidecheck)
	for pname, st in pairs(suiciding) do
		local player = minetest.get_player_by_name(pname)
		if player then
			local hp = player:get_hp()
			if (hp > 0) and (player:get_player_control_bits() == 0)
			and pstate(player) == st then
				nodecore.addphealth(player, -1)
			else
				suiciding[pname] = nil
			end
		end
	end
end
suicidecheck()

minetest.register_chatcommand("suicide", {
		description = "Commit suicide (e.g. to respawn when stuck)",
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if player then suiciding[pname] = pstate(player) end
		end,
	})
