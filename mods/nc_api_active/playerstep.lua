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
	if not old then return cur end
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
local function step_player(player, dtime)
	local pname = player:get_player_name()
	local data = cache[pname] or {}
	data.physics = player:get_physics_override()
	local orig_phys = clone(data.physics)
	data.properties = player:get_properties()
	local orig_props = clone(data.properties)
	data.sky = getsky(player)
	local orig_sky = clone(data.sky)
	data.daynight = player:get_day_night_ratio()
	local orig_daynight = clone(data.daynight)
	data.animation = {player:get_animation()}
	local orig_anim = clone(data.animation)
	data.hud_flags = player:hud_get_flags()
	local orig_hud = clone(data.hud_flags)
	data.control = player:get_player_control()
	for _, def in pairs(steps) do
		def.action(player, data, dtime)
	end
	local phys = setdelta(data.physics, orig_phys)
	if phys then player:set_physics_override(phys) end
	local props = setdelta(data.properties, orig_props)
	if props then player:set_properties(props) end
	if mismatch(data.animation, orig_anim) then
		player:set_animation(unpack(data.animation))
	end
	if mismatch(data.sky, orig_sky) then
		setsky(player, data.sky)
	end
	if mismatch(data.daynight, orig_daynight) then
		player:override_day_night_ratio(data.daynight)
	end
	local hud = setdelta(data.hud_flags, orig_hud)
	if hud then player:hud_set_flags(hud) end
	cache[pname] = data
end

nodecore.register_globalstep("player steps", function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			step_player(player, dtime)
		end
	end)
minetest.register_on_joinplayer(function(player)
		step_player(player, 0)
	end)
minetest.register_on_leaveplayer(function(player)
		cache[player:get_player_name()] = nil
	end)
