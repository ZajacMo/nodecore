-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table, type, unpack, vector
    = math, minetest, nodecore, pairs, table, type, unpack, vector
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

local default_range = 4
local function lazy_raycast(player)
	local saved = false
	return function()
		if saved ~= false then return saved end

		local pos = player:get_pos()
		pos.y = pos.y + player:get_properties().eye_height
		local look = player:get_look_dir()
		local wield = minetest.registered_items[player
		:get_wielded_item():get_name()]
		local range = wield and wield.range or default_range
		local target = vector.add(pos, vector.multiply(look, range))

		for pt in minetest.raycast(pos, target, true, false) do
			if pt.type == "object" or pt.ref ~= player
			or pt.ref:get_attach() ~= player then
				saved = pt
				return pt
			end
		end

		saved = nil
	end
end

local player_last_active = {}
minetest.register_on_chat_message(function(pname)
		player_last_active[pname] = nodecore.gametime
	end)
function nodecore.player_idle(pname)
	if type(pname) ~= "string" then pname = pname:get_player_name() end
	local active = player_last_active[pname] or nodecore.gametime
	return nodecore.gametime - active
end

local cache = {}
local function step_player(player, dtime)
	local pname = player:get_player_name()
	local data = cache[pname] or {pname = pname}
	data.raycast = lazy_raycast(player)
	data.physics = player:get_physics_override()
	local orig_phys = clone(data.physics)
	data.properties = player:get_properties()
	local orig_props = clone(data.properties)
	data.sky = data.sky or player:get_sky(true)
	local orig_sky = clone(data.sky)
	data.daynight = player:get_day_night_ratio()
	local orig_daynight = clone(data.daynight)
	data.animation = {player:get_animation()}
	local orig_anim = clone(data.animation)
	data.hud_flags = player:hud_get_flags()
	local orig_hud = clone(data.hud_flags)
	local newcontrol = player:get_player_control()
	local state = {
		pos = player:get_pos(),
		look = player:get_look_dir(),
		widx = player:get_wield_index()
	}
	if mismatch(data.control, newcontrol)
	or mismatch(data.state, state) then
		player_last_active[pname] = nodecore.gametime
	end
	data.state = state
	data.control = newcontrol
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
	if mismatch(data.sky, orig_sky) then player:set_sky(data.sky) end
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
		local pname = player:get_player_name()
		cache[pname] = nil
		player_last_active[pname] = nil
	end)
