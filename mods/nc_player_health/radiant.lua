-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_exp, math_floor, math_random, math_sqrt
    = math.exp, math.floor, math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local maxdist = 8

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
		local n = minetest.get_node(p)
		local def = minetest.registered_items[n.name]
		local dps = def and def.groups and def.groups.damage_radiant
		if dps and dps > 0 then
			local r = vector.subtract(pos, p)
			local dsqr = vector.dot(r, r) / 2 + 1
			return dps / dsqr
		end
		if not (nodecore.air_pass(n) or def and def.sunlight_propagates)
		then return 0 end
	end
	return 0
end

local heat = {}

local function check(player, dtime)
	local pos = player:get_pos()
	pos.y = pos.y + 1
	local dps = getdps(pos)
	if not dps then return end

	local w = math_exp(-dtime)
	local pname = player:get_player_name()
	heat[pname] = (heat[pname] or 0) * w + dps * (1 - w)
end

minetest.register_globalstep(function(dtime)
		if nodecore.stasis then return end
		for _, p in pairs(minetest.get_connected_players()) do
			if nodecore.player_visible(p) then check(p, dtime) end
		end
	end)

local function applyheat()
	minetest.after(1, applyheat)
	if nodecore.stasis then return end
	for _, p in pairs(minetest.get_connected_players()) do
		if nodecore.player_visible(p) then
			local pname = p:get_player_name()
			local ow = heat[pname]
			local img = ""
			if ow and ow > 0.1 then
				nodecore.addphealth(p, -ow, "radiant")
				ow = math_sqrt(ow) * 255
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
		end
	end
end
applyheat()
