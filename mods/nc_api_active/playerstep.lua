-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table, type
    = math, minetest, nodecore, pairs, table, type
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

local cache = {}
nodecore.register_globalstep("player steps", function(dtime)
		for _, player in pairs(minetest.registered_players) do
			local pname = player:get_player_name()
			local orig = cache[pname]
			if not orig then
				orig = {
					physics = player:get_physics_override(),
					properties = player:get_properties()
				}
				cache[pname] = orig
			end
			local data = clone(cache)
			for _, def in pairs(steps) do
				def.action(player, data, dtime)
			end
		end
	end)
