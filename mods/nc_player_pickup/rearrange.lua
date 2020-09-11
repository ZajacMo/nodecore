-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, string
    = ItemStack, minetest, nodecore, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function shortdesc(stack)
	stack = ItemStack(stack)
	stack:get_meta():from_table({})
	return stack:to_string()
end

local function handlepickups(player)
	local inv = player:get_inventory()
	local pname = player:get_player_name()
	local cached = cache[pname]
	if cached then
		local dbg_pre = {}
		local dbg_cur = {}

		local snap = {}
		for i = 1, #cached do
			snap[i] = ItemStack(cached[i])
			dbg_pre[i] = shortdesc(snap[i])
		end

		local excess = {}
		local dirty

		local widx = player:get_wield_index()
		for i in nodecore.inv_walk(player, widx, inv) do
			local cur = inv:get_stack("main", i)
			dbg_cur[i] = shortdesc(cur)
			local old = snap[i] or ItemStack("")
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
			inv:set_list("main", snap)
			local dbg_end = {}
			for i = 1, #snap do dbg_end = shortdesc(snap[i]) end
			local ser = minetest.serialize
			nodecore.log("warning", string_format("inventory rearranged for"
					.. " %s cached %s in %s out %s", pname,
					ser(dbg_pre), ser(dbg_cur), ser(dbg_end)))
		end
	end
	cache[pname] = inv:get_list("main")
end

nodecore.register_playerstep({label = "pickup rearrange", action = handlepickups})
