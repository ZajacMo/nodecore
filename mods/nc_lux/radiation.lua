-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_cos, math_pi, math_random, math_sin, math_sqrt
    = math.cos, math.pi, math.random, math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local irradiated = modname .. ":irradiated"
nodecore.register_virtual_item(irradiated, {
		description = "",
		inventory_image = "[combine:1x1",
		hotbar_type = "burn",
	})

nodecore.register_healthfx({
		item = irradiated,
		getqty = function(player)
			return player:get_meta():get_float("rad")
		end
	})

---------------------------------------------------------------

local rad_default = {absorb = 2/100, scatter = 2/100}
local rad_lut = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			local g = v.groups or {}
			local rad = {
				stack = g.visinv,
				emit = g.lux_emit,
				absorb = g.lux_absorb
				or (v.liquidtype ~= "none" and 7/8)
				or (g.cracky and 1 - 1 / (g.cracky + 2))
				or (v.walkable and 1/4)
				or rad_default.absorb,
				scatter = g.lux_scatter
				or (v.liquidtype ~= "none" and 1)
				or (v.walkable and 1/8)
				or rad_default.scatter
			}
			if rad.absorb < 1/100 then rad.absorb = 1/100 end
			rad_lut[k] = rad
		end
	end)

local function randdir()
	-- https://math.stackexchange.com/a/44691
	local z = math_random() * 2 - 1
	local k = math_sqrt(1 - z * z)
	local theta = math_random() * math_pi * 2
	return {
		x = k * math_cos(theta),
		y = k * math_sin(theta),
		z = z
	}
end

local function radscan(player)
	local emit = 0
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local dir
	for _ = 1, 32 do
		local nn = minetest.get_node(pos).name
		if nn == "ignore" then break end
		local rad = rad_lut[nn] or rad_default
		if rad.emit then emit = emit + rad.emit end
		if math_random() < rad.absorb then break end
		if math_random() < rad.scatter then dir = randdir() end
		dir = dir or randdir()
		pos = vector.add(pos, vector.multiply(dir, math_random() + 0.5))
	end
	if emit > 0 then minetest.log(nodecore.gametime .. " " .. emit) end
end

local cost = 0
nodecore.interval(5, function()
		minetest.chat_send_all("cost " .. (cost / 5000000))
		cost = 0
	end)
nodecore.register_playerstep({
		label = "lux rad scan",
		action = function(player, data, dtime)
			local start = minetest.get_us_time()
			data.radtime = (data.radtime or 0) + dtime
			if data.radtime > 1 then data.radtime = 1 end
			while data.radtime > 1/16 do
				data.radtime = data.radtime - 1/16
				radscan(player, data)
			end
			cost = cost + minetest.get_us_time() - start
		end
	})

---------------------------------------------------------------

-- local luxaccum = {}

-- local function rademit(pos, emit)
-- for _, player in pairs(minetest.get_connected_players()) do
-- local pname = player:get_player_name()
-- local pp = player:get_pos()
-- pp.y = pp.y + 1
-- local dx = pp.x - pos.x
-- dx = dx * dx
-- local dy = pp.y - pos.y
-- dy = dy * dy
-- local dz = pp.z - pos.z
-- dz = dz * dz
-- local dsqr = (dx + dy + dz)
-- if dsqr > (32 * 32) then return end
-- if dsqr < 1 then
-- dsqr = 1
-- else
-- for pt in minetest.raycast(pos, pp, false, true) do
-- local pn = minetest.get_node(pt.under)
-- local def = minetest.registered_items[pn.name] or {groups = {}}
-- if def.groups.water then
-- dsqr = dsqr * 8
-- else if pn.name ~= "air" and not def.groups.lux_emit then
-- dsqr = dsqr * 2
-- end
-- if dsqr > (32 * 32) then return end
-- end
-- end
-- luxaccum[pname] = (luxaccum[pname] or 0) + (math_log(emit) + 1) / dsqr
-- end
-- end

-- nodecore.register_limited_abm({
-- label = "lux irradiate",
-- interval = 1,
-- chance = 2,
-- nodenames = {"group:lux_emit"},
-- action = function(pos, node)
-- local def = minetest.registered_items[node.name]
-- local emit = def and def.groups and def.groups.lux_emit or 1
-- if emit then return rademit(pos, emit) end
-- end
-- })

-- nodecore.register_aism({
-- label = "lux stack irradiate",
-- interval = 1,
-- chance = 2,
-- itemnames = {"group:lux_emit"},
-- action = function(stack, data)
-- local def = minetest.registered_items[stack:get_name()]
-- local emit = def and def.groups and def.groups.lux_emit
-- if emit then return rademit(data.pos, emit) end
-- end
-- })

-- local avgs = {}
-- nodecore.interval(1, function()
-- for _, player in pairs(minetest.get_connected_players()) do
-- local meta = player:get_meta()
-- local rad = meta:get_float("rad") or 0

-- local pname = player:get_player_name()
-- local accum = luxaccum[pname] or 0
-- luxaccum[pname] = 0

-- local prop = math_exp(-accum / 1000)
-- rad = rad * prop + (1 - prop)

-- local redux = 0.1
-- local pos = player:get_pos()
-- local node = minetest.get_node(pos)
-- local def = minetest.registered_items[node.name]
-- if def and def.groups and def.groups.water then
-- redux = redux + 50
-- end
-- pos.y = pos.y + 1
-- node = minetest.get_node(pos)
-- def = minetest.registered_items[node.name]
-- if def and def.groups and def.groups.water then
-- redux = redux + 500
-- end
-- prop = math_exp(-redux / 10000)
-- rad = rad * prop

-- meta:set_float("rad", rad)

-- local avg = (avgs[pname] or 0) * 0.8 + accum * 0.2
-- avgs[pname] = avg
-- local img = ""
-- if avg > 0.75 then
-- local ow = math_sqrt(avg - 0.75) * 64
-- if ow > 255 then ow = 255 end
-- img = "nc_lux_radhud.png^[opacity:" .. math_floor(ow)
-- end
-- nodecore.hud_set(player, {
-- label = "luxrad",
-- hud_elem_type = "image",
-- position = {x = 0.5, y = 0.5},
-- text = img,
-- direction = 0,
-- scale = {x = -100, y = -100},
-- offset = {x = 0, y = 0},
-- quick = true
-- })
-- end
-- end)
