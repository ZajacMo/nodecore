-- LUALOCALS < ---------------------------------------------------------
local minetest, next, nodecore, pairs
    = minetest, next, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

minetest.register_chatcommand("tabula", {
		desciption = "Reset NodeCore discoveries",
		params = "rasa",
		func = function(name, param)
			if param ~= "rasa" then
				return false, "If you're sure you want to erase all discovery"
				.. " progress, use the command \"/tabula rasa\""
			end
			local db, player, pname, save = nodecore.get_player_discovered(name)
			if not db then
				return false, "Must be online and have interact privs"
				.. " to use this command"
			end
			while next(db) do db[next(db)] = nil end
			for _, cb in pairs(nodecore.registered_on_discovers) do
				cb(player, nil, pname, db)
			end
			save()
			return true, "All discoveries reset"
		end
	})
