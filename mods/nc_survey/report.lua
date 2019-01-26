-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local function report()
	local t = store:to_table().fields
	t.players = players
	t.player_knowledge = nodecore.player_knowledge()
	for k, v in pairs(t.player_knowledge) do
		t.player_knowledge[k] = minetest.deserialize(v)
	end
	minetest.log(minetest.write_json(t))
end
