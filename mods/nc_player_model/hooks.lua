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

	if not eq(props, cached.props) then
		nodecore.ent_prop_set(player, props)
		cached.props = props
	end

	local anim = nodecore.player_anim(player)
	if not eq(anim, cached.anim) then
		player:set_animation(anim, anim.speed)
		cached.anim = anim
	end
end

minetest.register_on_joinplayer(function(player)
		cache[player:get_player_name()] = nil
		updatevisuals(player, true)
	end)

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			if nodecore.player_visible(player) then
				updatevisuals(player)
			end
		end
	end)
