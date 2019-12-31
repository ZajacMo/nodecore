-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, type
    = error, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local huds = {}

local myprops = {
	label = true,
	ttl = true,
	quick = true
}

local function updatehud(player, entry, phuds, dtime)
	if entry.ttl then
		if entry.ttl <= 0 then
			if entry.id then player:hud_remove(entry.id) end
			phuds[entry.label] = nil
			return
		end
		entry.ttl = entry.ttl - dtime
	end
	if entry.id then
		for k, v in pairs(entry.new) do
			if (not myprops[k]) and (v ~= entry.old[k]) then
				player:hud_change(entry.id, k, v)
				entry.old[k] = v
			end
		end
	else
		entry.id = player:hud_add(entry.new)
		entry.old = {}
		for k, v in pairs(entry.new) do entry.old[k] = v end
	end
end

function nodecore.hud_set(player, def)
	if not (def and def.label) then return error("missing HUD label") end

	local pname
	if type(player) == "string" then
		pname = player
		player = minetest.get_player_by_name(pname)
	else
		pname = player:get_player_name()
	end
	if not player then return error("missing player") end

	local phuds = huds[pname]
	if not phuds then
		phuds = {}
		huds[pname] = phuds
	end
	local entry = phuds[def.label]
	if not entry then
		entry = {label = def.label}
		phuds[def.label] = entry
	end
	entry.new = def
	entry.ttl = def.ttl or entry.ttl
	if def.quick then return updatehud(player, entry, phuds, 0) end
end

minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local phuds = huds[pname]
			if phuds then
				for _, entry in pairs(phuds) do
					updatehud(player, entry, phuds, dtime)
				end
			end
		end
	end)

minetest.register_on_leaveplayer(function(player)
		huds[player:get_player_name()] = nil
	end)
