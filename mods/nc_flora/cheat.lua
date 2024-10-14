-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, tonumber, type, vector
    = core, nc, pairs, tonumber, type, vector
-- LUALOCALS > ---------------------------------------------------------

local alldecor = {}
core.after(0, function()
		for _, dec in pairs(core.registered_decorations) do
			if dec.deco_type == "simple" and dec.place_on
			and dec.decoration and dec.noise_params then
				alldecor[#alldecor + 1] = dec
			end
		end
	end)

local function generate(pick, pos)
	local found = nc.pickrand(
		core.find_nodes_in_area_under_air({
				x = pos.x,
				y = pos.y + 50,
				z = pos.z
			},
			{
				x = pos.x,
				y = pos.y - 50,
				z = pos.z
			}, pick.place_on))
	if not found then return end

	found.y = found.y + 1
	if not nc.air_equivalent(found) then return end

	if found and pick.spawn_by and #nc.find_nodes_around(
		found, pick.spawn_by) < 1 then return end

	return nc.set_loud(found, {
			name = type(pick.decoration) == "table"
			and nc.pickrand(pick.decoration)
			or pick.decoration,
			param2 = pick.param2
		})
end

local function decorate(pos, qty, dist)
	local seen = {}
	for _ = 1, qty do
		local p = vector.round({
				x = pos.x + nc.boxmuller() * dist,
				y = pos.y,
				z = pos.z + nc.boxmuller() * dist,
			})
		local hash = core.hash_node_position(p)
		if not seen[hash] then
			seen[hash] = true
			local pick = nc.pickrand(alldecor, function(dec)
					return dec.noise_params.scale
					+ dec.noise_params.offset
				end)
			generate(pick, p)
		end
	end
end

core.register_chatcommand("redecorate", {
		description = "spawn mapgen decorations in area",
		privs = {give = true},
		params = "[qty] [dist]",
		func = function(name, param)
			local player = core.get_player_by_name(name)
			if not player then return false, "must be online" end
			local pos = player:get_pos()
			if not pos then return false, "must be online" end
			local split = param:split(" ")
			return decorate(pos, tonumber(split[1]) or 1000,
				tonumber(split[2]) or 16)
		end
	})
