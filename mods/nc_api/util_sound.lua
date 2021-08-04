-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, type, unpack,
      vector
    = ItemStack, ipairs, math, minetest, nodecore, pairs, type, unpack,
      vector
local math_exp, math_random, math_sin, math_sqrt
    = math.exp, math.random, math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local oldplay = minetest.sound_play
function nodecore.sound_play(name, spec, ephem, ...)
	if spec and type(spec) == "table" then
		spec.pitch = (spec.pitch or 1) * math_exp(
			(math_random() - 0.5) * (spec.pitchvary or 0.05))
	end
	if ephem == nil then ephem = not spec.not_ephemeral end
	return oldplay(name, spec, ephem, ...)
end

function nodecore.sound_play_except(name, def, pname)
	if not pname then
		return nodecore.sound_play(name, def)
	end
	if type(pname) ~= "string" then
		pname = pname:get_player_name()
	end
	for _, p in ipairs(minetest.get_connected_players()) do
		local pn = p:get_player_name()
		if pn ~= pname and ((not def.pos)
			or (vector.distance(p:get_pos(), def.pos) <= 32)) then
			def.to_player = pn
			nodecore.sound_play(name, def)
		end
	end
end

function nodecore.windiness(y)
	if y < 0 then return 0 end
	if y > 512 then y = 512 end
	return math_sqrt(y) * (1 + 0.5 * math_sin(nodecore.gametime / 5))
end

function nodecore.stack_sounds(pos, kind, stack, except)
	stack = stack or nodecore.stack_get(pos)
	stack = ItemStack(stack)
	if stack:is_empty() then return end
	local def = minetest.registered_items[stack:get_name()] or {}
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	if except then return nodecore.sound_play_except(t.name, t, except) end
	return nodecore.sound_play(t.name, t)
end
function nodecore.stack_sounds_delay(...)
	local t = {...}
	minetest.after(0, function()
			nodecore.stack_sounds(unpack(t))
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
function nodecore.sounds(name, gains, pitch)
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

function nodecore.node_sound(pos, kind, opts)
	local node = opts and opts.node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def.groups and def.groups.visinv then
		nodecore.stack_sounds(pos, kind)
	end
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	return nodecore.sound_play_except(t.name, t, opts and opts.except)
end

local function mkloud(fname)
	return function(pos, node, opts)
		minetest[fname](pos, node)
		opts = opts or {}
		opts.node = node
		return nodecore.node_sound(pos, "place", opts)
	end
end
nodecore.set_loud = mkloud("set_node")
nodecore.swap_loud = mkloud("swap_node")
