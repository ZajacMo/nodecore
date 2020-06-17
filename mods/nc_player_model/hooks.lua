-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function eq(t, u)
	if type(t) ~= "table" then return t == u end
	if type(u) ~= "table" then return end
	for k, v in pairs(t) do
		if not eq(v, u[k]) then return end
	end
	return true
end

local function updatevisuals(player, joining)
	local pname = player:get_player_name()
	local cached = cache[pname]
	if not cached then
		cached = {}
		cache[pname] = cached
	end

	local props = nodecore.player_visuals_base(player, joining)
	local anim, eye = nodecore.player_anim(player)

	-- Skin can be set preemptively by visuals_base; if so, then will
	-- not be modified here.
	if not props.textures then
		-- Recheck skin only every couple seconds to avoid
		-- interfering with animations if skin includes continuous
		-- effects.
		local now = minetest.get_us_time() / 1000000
		if (not cached.skintime) or (now >= cached.skintime + 2) then
			cached.skintime = now
			local t = nodecore.player_skin(player)
			props.textures = {t}
		end
	end
	if cached.eye ~= eye then
		props.eye_height = eye
		cached.eye = eye
	end

	if not eq(anim, cached.anim) then
		player:set_animation(anim, anim.speed)
		cached.anim = anim
	end
	return player:set_properties(props)
end

nodecore.register_on_joinplayer("join setup player model", function(player)
		cache[player:get_player_name()] = nil
		updatevisuals(player, true)
	end)

nodecore.register_globalstep_perplayer("player model updates", function(player)
		if nodecore.player_visible(player) then
			updatevisuals(player)
		end
	end)
