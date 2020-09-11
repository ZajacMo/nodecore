-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, type, vector
    = math, minetest, nodecore, pairs, string, type, vector
local math_pi, string_format, string_gsub
    = math.pi, string.format, string.gsub
-- LUALOCALS > ---------------------------------------------------------

local function playercheck(player, pos, maxdist, check)
	local ppos = player:get_pos()
	ppos.y = ppos.y + player:get_properties().eye_height

	if vector.distance(pos, ppos) > maxdist then return end

	local look = player:get_look_dir()
	local targ = vector.normalize(vector.subtract(pos, ppos))
	if vector.angle(look, targ) > math_pi / 4 then return end

	local rp = vector.round(pos)
	for pt in minetest.raycast(pos, ppos, false, true) do
		if pt.type ~= "node" then return end
		local node = minetest.get_node(pt.under)
		local def = minetest.registered_nodes[node.name]
		local chk = check and check(pt.under, node, def, pt)
		if chk == false then return end
		if (not chk) and (not vector.equals(rp, pt.under)) then
			if not def then return end
			if not def.witness_transparent then
				if def.witness_opaque or def.paramtype ~= "light" then
					return
				end
			end
		end
	end
	return true
end

function nodecore.witness(pos, label, maxdist, check)
	maxdist = maxdist or 16
	nodecore.log("action", string_format("witness %s at %s range %d",
			string_gsub(minetest.serialize(label), "^return ", ""),
			minetest.pos_to_string(pos), maxdist))
	for _, player in pairs(minetest.get_connected_players()) do
		if playercheck(player, pos, maxdist, check) then
			for _, l in pairs(type(label) == "table" and label or {label}) do
				if l then
					nodecore.player_discover(player, "witness:" .. l)
				end
			end
		end
	end
end
