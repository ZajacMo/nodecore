-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, setmetatable, type, unpack
    = minetest, nodecore, pairs, setmetatable, type, unpack
-- LUALOCALS > ---------------------------------------------------------

local function mkdef(...)
	local def = {}
	local ext = {}
	for _, v in pairs({...}) do
		if type(v) == "function" then
			def.func = v
		elseif type(v) == "string" then
			def.label = v
		elseif type(v) == "table" then
			for tk, tv in pairs(v) do
				def[tk] = tv
			end
		else
			ext[#ext + 1] = v
		end
	end
	setmetatable(def, {__call = function(_, ...) return def.func(...) end})
	return def, unpack(ext)
end

for k in pairs({
		register_globalstep = true,
		register_playerevent = true,
		register_on_placenode = true,
		register_on_dignode = true,
		register_on_punchnode = true,
		register_on_generated = true,
		register_on_newplayer = true,
		register_on_dieplayer = true,
		register_on_respawnplayer = true,
		register_on_prejoinplayer = true,
		register_on_joinplayer = true,
		register_on_leaveplayer = true,
		register_on_cheat = true,
		register_on_chat_message = true,
		register_on_player_receive_fields = true,
		register_on_craft = true,
		register_craft_predict = true,
		register_on_protection_violation = true,
		register_on_item_eat = true,
		register_on_punchplayer = true,
		register_on_player_hpchange = true,
		register_on_shutdown = true
	}) do
	local base = minetest[k]
	nodecore[k] = function(...) return base(mkdef(...)) end
end
