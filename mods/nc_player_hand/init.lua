-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

minetest.register_item(":", {
		type = "none",
		wield_image = "nc_player_hand.png",
		wield_scale = {x = 4, y = 8, z = 3},
		tool_capabilities = nodecore.toolcaps({
				uses = 0,
				crumbly = 1,
				snappy = 1,
				thumpy = 1
			})
	})

local function wieldsound(player, idx, gain)
	local n = player:get_inventory():get_stack("main", idx):get_name()
	local def = minetest.registered_items[n]
	if def and def.sounds then
		local t = {}
		for k, v in pairs(def.sounds.dig) do t[k] = v end
		t.pos = player:get_pos()
		t.gain = gain
		return function() minetest.sound_play(t.name, t) end
	end
	return function() end
end

local wields = {}
local pending = {}
minetest.register_globalstep(function(dtime)
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()

			local pend = pending[pname]
			if pend then
				pend.t = pend.t - dtime
				if pend.t <= 0 then
					pend.f()
					pending[pname] = nil
					pend = nil
				end
			end

			local idx = player:get_wield_index()
			local old = wields[pname]
			if idx ~= old then
				wields[pname] = idx
				if old and not pend then
					wieldsound(player, old, 0.07)()
				end
				pending[pname] = {
					t = 0.15,
					f = wieldsound(player, idx, 0.15)
				}
			end
		end
	end)
