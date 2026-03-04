-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, ipairs, math, nc, pairs, type, unpack, vector
    = ItemStack, core, ipairs, math, nc, pairs, type, unpack, vector
local math_exp, math_random, math_sin, math_sqrt
    = math.exp, math.random, math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

function nc.sound_play(name, spec, ephem, ...)
	if spec and type(spec) == "table" then
		spec.pitch = (spec.pitch or 1) * math_exp(
			(math_random() - 0.5) * (spec.pitchvary or 0.05))
	end
	if ephem == nil then ephem = not spec.not_ephemeral end
	return core.sound_play(name, spec, ephem, ...)
end

function nc.sound_play_except(name, def, pname)
	if not pname then
		return nc.sound_play(name, def)
	end
	if type(pname) ~= "string" then
		pname = pname:get_player_name()
	end
	for _, p in ipairs(core.get_connected_players()) do
		local pn = p:get_player_name()
		if pn ~= pname and ((not def.pos)
			or (vector.distance(p:get_pos(), def.pos) <= 32)) then
			def.to_player = pn
			nc.sound_play(name, def)
		end
	end
end

function nc.windiness(y)
	if y < 0 then return 0 end
	if y > 512 then y = 512 end
	return math_sqrt(y) * (1 + 0.5 * math_sin(nc.gametime / 5))
end

function nc.stack_sounds(pos, kind, stack, except)
	stack = stack or nc.stack_get(pos)
	stack = ItemStack(stack)
	if stack:is_empty() then return end
	local def = core.registered_items[stack:get_name()] or {}
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	if except then return nc.sound_play_except(t.name, t, except) end
	return nc.sound_play(t.name, t)
end
function nc.stack_sounds_delay(...)
	local t = {...}
	core.after(0, function()
			nc.stack_sounds(unpack(t))
		end)
end

local gains_base = {
	footstep = 0.2,
	dig = 0.5,
	dug = 1,
	place = 1,
	place_failed = 0.2,
	fall = 0.1
}
function nc.sounds(name, gains, pitch)
	local t = {}
	for k, v in pairs(gains_base) do
		t[k] = {
			name = name,
			gain = (gains and gains[k] or 1) * v,
			pitch = pitch
		}
	end
	return t
end

function nc.node_sound(pos, kind, opts)
	local node = opts and opts.node or core.get_node(pos)
	local def = core.registered_items[node.name] or {}
	if def.groups and def.groups.visinv then
		nc.stack_sounds(pos, kind)
	end
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	return nc.sound_play_except(t.name, t, opts and opts.except)
end

local noisy = 0
core.register_globalstep(function(dtime)
		noisy = noisy - 25 * dtime
		if noisy < 0 then noisy = 0 end
	end)
local function mkloud(fname)
	return function(pos, node, opts)
		core[fname](pos, node)
		if noisy > math_random(5, 25) then return end
		noisy = noisy + 1
		opts = opts or {}
		opts.node = node
		return nc.node_sound(pos, "place", opts)
	end
end
nc.set_loud = mkloud("set_node")
nc.swap_loud = mkloud("swap_node")
