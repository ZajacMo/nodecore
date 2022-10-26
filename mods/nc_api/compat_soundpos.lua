-- LUALOCALS < ---------------------------------------------------------
local minetest, string
    = minetest, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local oldplay = minetest.sound_play
function minetest.sound_play(spec, params, ...)
	if not (params and (params.pos or params.to_player or params.object)) then
		minetest.log("warning", string_format("global sound %q params %s",
				spec, minetest.serialize(params)))
	end
	return oldplay(spec, params, ...)
end
