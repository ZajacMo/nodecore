-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table, type, unpack
    = math, minetest, nodecore, pairs, table, type, unpack
local math_floor, table_insert
    = math.floor, table.insert
-- LUALOCALS > ---------------------------------------------------------

local steps = {}
nodecore.registered_playersteps = steps

local counters = {}
function nodecore.register_playerstep(def)
	local label = def.label
	if not label then
		label = minetest.get_current_modname()
		local i = (counters[label] or 0) + 1
		counters[label] = i
		label = label .. ":" .. i
	end

	local prio = def.priority or 0
	def.priority = prio
	local min = 1
	local max = #steps + 1
	while max > min do
		local try = math_floor((min + max) / 2)
		local oldp = steps[try].priority
		if (prio < oldp) or (prio == oldp and label > steps[try].label) then
			min = try + 1
		else
			max = try
		end
	end
	table_insert(steps, min, def)
end

local function clone(x)
	if type(x) == "table" then
		local t = {}
		for k, v in pairs(x) do t[k] = clone(v) end
		return t
	end
	return x
end

local mismatch = nodecore.prop_mismatch

local function setdelta(cur, old)
	if not cur then return end
	local set
	for k, v in pairs(cur) do
		if mismatch(v, old[k]) then
			set = set or {}
			set[k] = v
		end
	end
	return set
end

local setsky = function() end
local getsky = function() end
local function checksky()
	local player = minetest.get_connected_players()[1]
	if not player then return minetest.after(0, checksky) end
	if player.get_sky_color then
		setsky = player.set_sky
		getsky = function(p)
			local b, t, x, c = p:get_sky()
			local s = p:get_sky_color()
			return {
				base_color = b,
				type = t,
				textures = x,
				clouds = c,
				sky_color = s
			}
		end
	else
		setsky = function(p, params) return p:set_sky(params.base_color,
			params.type, params.textures, params.clouds) end
		getsky = function(p)
			local b, t, x, c = p:get_sky()
			return {
				base_color = b,
				type = t,
				textures = x,
				clouds = c
			}
		end
	end
end
minetest.after(0, checksky)

local cache = {}
nodecore.register_globalstep("player steps", function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			local orig = cache[pname] or {}
			orig.physics = player:get_physics_override()
			orig.properties = player:get_properties()
			orig.sky = getsky(player)
			orig.daynight = player:get_day_night_ratio()
			orig.animation = {player:get_animation()}
			local data = clone(cache)
			for _, def in pairs(steps) do
				def.action(player, data, dtime)
			end
			local phys = setdelta(data.physics, orig.physics)
			if phys then player:set_physics_override(phys) end
			local props = setdelta(data.properties, orig.properties)
			if props then player:set_properties(props) end
			local anim = setdelta(data.animation, orig.animation)
			if anim then player:set_animation(unpack(anim)) end
			local sky = setdelta(data.sky, orig.sky)
			if sky then setsky(player, sky) end
			if mismatch(data.daynight, orig.daynight) then
				player:override_day_night_ratio(data.daynight)
			end
			cache[pname] = orig
		end
	end)
