-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, vector
    = error, math, minetest, nodecore, pairs, vector
local math_exp, math_floor, math_random, math_sqrt
    = math.exp, math.floor, math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local maxdist = 8

local node_radiant = {}
local node_opaque = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			local d = v and v.groups and v.groups.damage_radiant
			node_radiant[k] = d and d ~= 0 and d or nil

			local grp_t = minetest.get_item_group(k, "radiant_transparent") ~= 0
			local grp_o = minetest.get_item_group(k, "radiant_opaque") ~= 0
			if (grp_t and grp_o) then
				error("node cannot be BOTH radiant_opaque and radiant_transparent")
			end
			node_opaque[k] = grp_o or (not (grp_t
					or nodecore.air_pass(k) or v.sunlight_propagates)) or nil
		end
	end)

local function getdps(pos)
	if nodecore.quenched(pos) then return 0 end

	local rel = {
		x = math_random() * 2 - 1,
		y = math_random() * 2 - 1,
		z = math_random() * 2 - 1
	}
	local len = vector.length(rel)
	if len == 0 or len > 1 then return end
	rel = vector.multiply(rel, maxdist / len)

	for pt in minetest.raycast(pos, vector.add(pos, rel), false, true) do
		local p = pt.under
		local n = minetest.get_node(p).name
		local dps = node_radiant[n]
		if dps and dps > 0 then
			local r = vector.subtract(pos, p)
			local dsqr = vector.dot(r, r) / 2 + 1
			return dps / dsqr
		end
		if node_opaque[n] then return 0 end
	end
	return 0
end

local heat = {}

nodecore.register_playerstep({
		label = "radiant heat damage",
		action = function(player, data, dtime)
			if nodecore.stasis or not nodecore.player_visible(player) then return end

			local pos = player:get_pos()
			pos.y = pos.y + 1
			local dps = getdps(pos)
			if not dps then return end

			local w = math_exp(-dtime)
			heat[data.pname] = (heat[data.pname] or 0) * w + dps * (1 - w)
		end
	})

nodecore.interval(1, function()
		if nodecore.stasis then return end
		for _, p in pairs(minetest.get_connected_players()) do
			if nodecore.player_visible(p) then
				local pname = p:get_player_name()
				local ow = heat[pname]
				local img = ""
				if ow and ow > 0.1 then
					nodecore.addphealth(p, -ow, "radiant")
					ow = math_sqrt(ow - 0.1) * 255
					if ow > 255 then ow = 255 end
					img = "nc_player_health_radiant.png^[opacity:" .. math_floor(ow)
				end
				nodecore.hud_set(p, {
						label = "radiant",
						hud_elem_type = "image",
						position = {x = 0.5, y = 0.5},
						text = img,
						direction = 0,
						scale = {x = -100, y = -100},
						offset = {x = 0, y = 0},
						quick = true
					})
			else
				nodecore.hud_set(p, {label = "radiant", ttl = 0})
			end
		end
	end)
