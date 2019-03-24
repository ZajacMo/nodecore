-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest
    = ItemStack, ipairs, minetest
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function sameitem(a, b)
	if a:is_empty() or b:is_empty() then return true end
	if a:get_count() ~= b:get_count() then
		if a:get_count() ~= 1 then a = ItemStack(a:to_string()) end
		a:set_count(1)
		if b:get_count() ~= 1 then b = ItemStack(b:to_string()) end
		b:set_count(1)
	end
	return a:to_string() == b:to_string()
end

local function handlepickups(player)
	local inv = player:get_inventory()
	local pname = player:get_player_name()
	local cached = cache[pname]
	if cached then
		local snap = {}
		for i = 1, #cached do snap[i] = cached[i] end

		local excess, ec

		local widx = player:get_wield_index()
		local wield = snap[widx]

		for i = 1, inv:get_size("main") do
			local cur = inv:get_stack("main", i)
			local old = ItemStack(snap[i])
			if sameitem(cur, old) then
				local def = minetest.registered_items[cur:get_name()]
				if not (def and def.virtual_item) then
					local cc = cur:get_count()
					local oc = old:get_count()
					if cc > oc then
						if excess == nil and sameitem(cur, wield) then
							excess = cur
							ec = cc - oc + wield:get_count()
						elseif excess then
							if sameitem(excess, cur) then
								ec = ec + cc - oc
							else
								excess = false
							end
						end
					end
				end
			end
		end

		if excess and ec and ec > 0 then
			local def = minetest.registered_items[excess:get_name()]
			if def then
				local left
				if ec > def.stack_max then
					left = ec - def.stack_max
					ec = def.stack_max
				end
				excess:set_count(ec)
				snap[widx] = excess
				inv:set_list("main", snap)
				if left then
					excess:set_count(left)
					inv:add_item("main", excess)
				end
			end
		end
	end
	cache[pname] = inv:get_list("main")
end

minetest.register_globalstep(function()
		for _, p in ipairs(minetest.get_connected_players()) do
			handlepickups(p)
		end
	end)
