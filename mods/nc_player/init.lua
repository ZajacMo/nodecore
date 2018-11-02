minetest.register_on_joinplayer(function(player)
	player:set_properties({
		visual = "upright_sprite",
		visual_size = { x = 1, y = 2 },
		textures = { "nc_player_front.png", "nc_player_back.png" },
	})
end)