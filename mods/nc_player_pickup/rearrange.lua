-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest
    = ItemStack, ipairs, minetest
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function invidx(player, inv, widx)
	widx = widx or player:get_wield_index()
	local size = (inv or player:get_inventory()):get_size("main")
	local idx
	return function()
		if not idx then
			idx = 0
			return widx
		end
		idx = idx + 1
		if idx == widx then idx = idx + 1 end
		if idx <= size then return idx end
	end
end


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
		for i in invidx(player, inv. widx) do
			local cur = inv:get_stack("main", i)
			local old = snap[i]
			if old:is_empty() or cur:peek_item(1):to_string()
			== old:peek_item(1):to_string() then
				local def = minetest.registered_items[cur:get_name()]
				if not (def and def.virtual_item) then
					local cc = cur:get_count()
					local oc = old:get_count()
					if cc > oc then
						cur:set_count(cc - oc)
						for i = 1, #excess do
							cur = excess[i]:add_item(cur)
						end
						if not cur:is_empty() then
							excess[#excess + 1] = cur
						end
						dirty = dirty or i ~= widx
					else
						snap[i] = cur
					end
				end
			end
		end

		if dirty then
			for i = 1, #excess do
				local v = excess[i]
				for j in invidx(player, inv, widx) do
					if not snap[j]:is_empty() then
						v = snap[j]:add_item(v)
					end
				end
				for j in invidx(player, inv, widx) do
					v = snap[j]:add_item(v)
				end
				if not v:is_empty() then
					minetest.log("failed to reinsert item "
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
			minetest.log("inventory rearranged for " .. pname)
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
