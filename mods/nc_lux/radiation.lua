-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, setmetatable, vector
    = math, minetest, nodecore, pairs, setmetatable, vector
local math_cos, math_floor, math_log, math_pi, math_pow, math_random,
      math_sin, math_sqrt
    = math.cos, math.floor, math.log, math.pi, math.pow, math.random,
      math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function metastat(metakey)
	local statcache = {}
	return function(player)
		local pname = player:get_player_name()
		local meta = player:get_meta()
		local found = statcache[pname]
		if not found then
			found = meta:get_float(metakey)
			statcache[pname] = found
		end
		return found, function(v)
			if v == found then return end
			found = v
			statcache[pname] = v
			meta:set_float(metakey, v)
		end
	end
end
local radlevel = metastat("rad")
local radrate = metastat("radrate")

local irradiated = modname .. ":irradiated"
nodecore.register_virtual_item(irradiated, {
		description = "",
		inventory_image = "[combine:1x1",
		hotbar_type = "burn",
	})

nodecore.register_healthfx({
		item = irradiated,
		getqty = function(player) return radlevel(player) end,
		setqty = function(player, qty)
			local _, set = radlevel(player)
			return set(qty)
		end
	})

local rad_lut = {}
do
	local rad_default = {absorb = 1/64, scatter = 1/32}
	local rad_init
	setmetatable(rad_lut, {
			__index = function(_, k)
				if rad_init then rad_lut[k] = rad_default end
				return rad_default
			end
		}
	)
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_items) do
				local g = v.groups or {}
				local rad = {
					stack = g.visinv,

					emit = g.lux_emit,

					absorb = (g.lux_absorb and g.lux_absorb / 64)
					or (g.metallic and 1)
					or ((v.liquidtype ~= "none" or g.water or g.moist) and 7/8)
					or (g.cracky and 1 - 1 / (g.cracky + 2))
					or (g.flammeble and (not g.fire_fuel) and rad_default.absorb)
					or (v.walkable and 1/4)
					or rad_default.absorb,

					scatter = (g.lux_scatter and g.lux_scatter / 64)
					or (v.liquidtype ~= "none" and 1)
					or (v.walkable and 1/8)
					or rad_default.scatter
				}
				if rad.absorb < rad_default.absorb then
					rad.absorb = rad_default.absorb
				end
				rad_lut[k] = rad
			end
			rad_init = true
		end)
end

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

local function nodescan(player)
	local emit = 0
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local dir
	while true do
		local nn = minetest.get_node(pos).name
		if nn == "ignore" then break end
		local rad = rad_lut[nn]
		if rad.emit then emit = emit + rad.emit end
		if math_random() < rad.absorb then break end
		if math_random() < rad.scatter then dir = randdir() end
		if rad.stack then
			local stack = nodecore.stack_get(pos)
			rad = (not stack:is_empty()) and rad_lut[stack:get_name()]
			if rad then
				if rad.emit then emit = emit + rad.emit end
				if math_random() < rad.absorb then break end
				if math_random() < rad.scatter then dir = randdir() end
			end
		end
		dir = dir or randdir()
		pos = vector.add(pos, vector.multiply(dir, math_random()))
	end
	return emit
end

local function itemscan(player)
	local list = player:get_inventory():get_list("main")
	for k, v in pairs(list) do list[k] = rad_lut[v:get_name()] end
	for i = #list, 1, -1 do
		local j = math_random(1, i)
		list[i], list[j] = list[j], list[i]
	end
	local emit = 0
	for _, rad in pairs(list) do
		if rad.emit then emit = emit + rad.emit end
		if math_random() < rad.absorb then break end
		if math_random() < rad.scatter then break end
	end
	return emit / 8
end

local base = 1.25
local logbase = math_log(base)
nodecore.register_playerstep({
		label = "lux rad scan",
		action = function(player, data, dtime)
			local rad, setrad = radlevel(player)
			local rate, setrate = radrate(player)

			data.unradtime = (data.unradtime or 0) + dtime
			if data.unradtime > 1 then
				local pos = player:get_pos()
				local stand = minetest.registered_items[minetest.get_node({
						x = pos.x + math_random() - 0.5,
						y = pos.y + math_random() * 2 - 0.5,
						z = pos.z + math_random() - 0.5,
					}).name] or {}
				local use = math_floor(data.unradtime)
				if (stand.groups or {}).water then
					rad = rad * math_pow(15/16, use)
				end
				data.unradtime = data.unradtime - use
			end

			if nodecore.player_can_take_damage(player) then
				data.radtime = (data.radtime or 0) + dtime
				if data.radtime > 1 then data.radtime = 1 end
				while data.radtime > 1/16 do
					data.radtime = data.radtime - 1/16
					local inrate = (nodescan(player) + itemscan(player)) / 256
					rate = (rate or 0) * 0.99 + inrate * 0.01
					if inrate > 0 and math_random() < inrate then
						rad = 1 - (1 - rad) * 31/32
					end
				end
			end
			setrate(rate)

			data.radhudtime = (data.radhudtime or 0) + dtime * 2
			if data.radhudtime >= 1 then
				data.radhudtime = data.radhudtime - math_floor(data.radhudtime)
				local o = math_floor(math_pow(base,
						math_floor(math_log(math_sqrt(rate)
								* 2000) / logbase)))
				if o > 255 then o = 255 end
				local img = ""
				if o > 0 then img = modname .. "_radhud.png"
					if o < 255 then img = img .. "^[opacity:" .. o end
				end
				nodecore.hud_set(player, {
						label = "radiation",
						hud_elem_type = "image",
						position = {x = 0.5, y = 0.5},
						text = img,
						direction = 0,
						scale = {x = -100, y = -100},
						offset = {x = 0, y = 0},
						quick = true
					})
			end

			return setrad(rad)
		end
	})
