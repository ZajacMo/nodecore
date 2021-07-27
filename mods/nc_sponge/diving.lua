-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_playerstep({
		label = "sponge diving breath",
		action = function(player, data)
			local breath = player:get_breath()

			if breath > 0 then
				local old = data.spongebreath or data.properties.breath_max
				data.spongebreath = breath
				if breath >= old then return end
			end

			local inv = player:get_inventory()
			for i = 1, inv:get_size("main") do
				if inv:get_stack("main", i):get_name() == modname .. ":sponge" then
					local nb = breath + 2
					if nb > data.properties.breath_max then
						nb = data.properties.breath_max
					end
					data.spongebreath = nb
					return player:set_breath(nb)
				end
			end
		end
	})
