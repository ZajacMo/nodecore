-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore
    = ItemStack, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function handlepickups(player)
	local inv = player:get_inventory()
	local pname = player:get_player_name()
	local cached = cache[pname]
	if cached then
		local snap = {}
		for i = 1, #cached do snap[i] = ItemStack(cached[i]) end

		local excess = {}
		local dirty

		local widx = player:get_wield_index()
		for i in nodecore.inv_walk(player, widx, inv) do
			local cur = inv:get_stack("main", i)
			local old = snap[i]
			if old:is_empty() or cur:peek_item(1):to_string()
			== old:peek_item(1):to_string() then
				if not nodecore.item_is_virtual(cur) then
					local cc = cur:get_count()
					local oc = old:get_count()
					if cc > oc then
						cur:set_count(cc - oc)
						for j = 1, #excess do
							cur = nodecore.stack_merge(excess[j], cur)
						end
						if not cur:is_empty() then
							excess[#excess + 1] = cur
						end
						dirty = dirty or i ~= widx
					else
						snap[i] = cur
					end
				end
			else
				snap[i] = cur
			end
		end

		if dirty then
			for i = 1, #excess do
				local v = excess[i]
				for j in nodecore.inv_walk(player, widx, inv) do
					v = nodecore.stack_merge(snap[j], v)
				end
				if not v:is_empty() then
					nodecore.log("error", "failed to reinsert item "
						.. v:get_name() .. " " .. v:get_count()
						.. " for " .. pname)
					dirty = nil
				end
			end
		end

		if dirty then
			dirty = nil
			for i = 1, #cached do
				dirty = dirty or inv:get_stack("main", i)
				:to_string() ~= snap[i]:to_string()
			end
		end

		if dirty then
			nodecore.log("info", "inventory rearranged for " .. pname)
			inv:set_list("main", snap)
		end
	end
	cache[pname] = inv:get_list("main")
end

minetest.register_globalstep(function()
		for _, p in ipairs(minetest.get_connected_players()) do
			handlepickups(p)
		end
	end)
