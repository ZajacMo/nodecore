-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_ceil, math_floor
    = math.ceil, math.floor
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function setsky(player)
	local pname = player:get_player_name()
	local stats = cache[pname]
	if not stats then
		stats = {}
		cache[pname] = stats
	end

	local depth = math_floor(player:get_pos().y + 0.5)

	local rawdll = nodecore.get_depth_light(depth, 1)
	local dark = 255 - math_ceil(255 * rawdll)
	if dark ~= stats.dark then
		stats.dark = dark
		local txr = {}
		for i = 1, 6 do
			txr[#txr + 1] = "nc_player_sky_box" .. i
			.. ".png^[colorize:#000000:" .. dark
		end
		player:set_sky("#9a9a9a", "skybox", txr, false)
	end

	local ratio = nodecore.get_depth_light(depth)
	if ratio ~= stats.ratio then
		stats.ratio = ratio
		player:override_day_night_ratio(ratio)
	end
end

minetest.register_on_joinplayer(setsky)

minetest.register_on_leaveplayer(function(player)
		cache[player:get_player_name()] = nil
	end)

local function update()
	for _, player in pairs(minetest.get_connected_players()) do
		setsky(player)
	end
	minetest.after(0.25, update)
end
update()
