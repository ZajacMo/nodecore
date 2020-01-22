-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, type
    = ItemStack, ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function addgroups(sum, pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if not def.groups then return end
	for k, v in pairs(def.groups) do
		sum[k] = (sum[k] or 0) + v
	end
end

local function craftcheck(recipe, pos, node, data, xx, xz, zx, zz)
	local function rel(x, y, z)
		return {
			x = pos.x + xx * x + zx * z,
			y = pos.y + y,
			z = pos.z + xz * x + zz * z
		}
	end
	data.rel = rel
	data.wield = ItemStack(data.wield or data.crafter and data.crafter:get_wielded_item())
	if recipe.check and not recipe.check(pos, data) then return end
	if recipe.wield and (not data.wield or not nodecore.match(
			{stack = data.wield}, recipe.wield)) then return end
	if recipe.normal then
		if data.pointed.type ~= "node" or
		recipe.normal.y ~= data.pointed.above.y - data.pointed.under.y then return end
		local rx = recipe.normal.x * xx + recipe.normal.z * zx
		if rx ~= data.pointed.above.x - data.pointed.under.x then return end
		local rz = recipe.normal.x * xz + recipe.normal.z * zz
		if rz ~= data.pointed.above.z - data.pointed.under.z then return end
	end
	for _, v in pairs(recipe.nodes) do
		if v ~= recipe.root and v.match then
			local p = rel(v.x, v.y, v.z)
			if not nodecore.match(p, v.match) then return end
		end
	end
	if recipe.touchgroups then
		local sum = {}
		addgroups(sum, rel(1, 0, 0))
		addgroups(sum, rel(-1, 0, 0))
		addgroups(sum, rel(0, 1, 0))
		addgroups(sum, rel(0, -1, 0))
		addgroups(sum, rel(0, 0, 1))
		addgroups(sum, rel(0, 0, -1))
		for k, v in pairs(recipe.touchgroups) do
			local w = sum[k] or 0
			if v > 0 and w < v then return end
			if v <= 0 and w > -v then return end
		end
	end
	local mindur = recipe.duration or 0
	if type(mindur) == "function" then mindur = mindur(recipe, pos, node, data) end
	if recipe.toolgroups then
		if not data.wield then return end
		local dg = data.wield:get_tool_capabilities().groupcaps
		local t
		for gn, lv in pairs(recipe.toolgroups) do
			local gt = dg[gn]
			gt = gt and gt.times
			gt = gt and gt[lv]
			if gt and (gt <= 4) and (not t or t > gt) then t = gt end
		end
		if not t then return end
		mindur = mindur + t
	end
	mindur = mindur / recipe.rate_adjust
	if mindur > 0 then
		if not data.duration then return end
		local dur = data.duration
		if type(dur) == "function" then dur = dur(pos, data) end
		if not dur or dur < mindur then
			if data.inprogress then data.inprogress(pos, data) end
			return 1
		end
	end
	if data.before then data.before(pos, data) end
	if recipe.before then recipe.before(pos, data) end
	for _, v in ipairs(recipe.nodes) do
		if v.replace then
			local p = rel(v.x, v.y, v.z)
			local r = v.replace
			while type(r) == "function" do
				r = r(p, v)
			end
			if r and type(r) == "string" then
				r = {name = r}
			end
			if v.match.excess then
				local s = nodecore.stack_get(p)
				local x = s:get_count() - (v.match.count or 1)
				if x > 0 then
					s:set_count(x)
					nodecore.item_eject(p, s)
				end
				nodecore.stack_set(p, ItemStack(""))
			end
			if r then
				local n = minetest.get_node(p)
				r.param2 = n.param2
				nodecore.set_loud(p, r)
				nodecore.fallcheck(p)
			end
		end
	end
	if recipe.items then
		for _, v in pairs(recipe.items) do
			nodecore.item_eject(rel(v.x or 0, v.y or 0, v.z or 0),
				v.name, v.scatter, v.count, v.velocity)
		end
	end
	if recipe.consumewield then
		nodecore.consume_wield(data.crafter, recipe.consumewield)
	elseif recipe.toolgroups and recipe.toolwear and data.crafter then
		nodecore.wear_wield(data.crafter, recipe.toolgroups, recipe.toolwear)
	end
	if recipe.after then recipe.after(pos, data) end
	if data.after then data.after(pos, data) end
	if nodecore.player_stat_add then
		nodecore.player_stat_add(1, data.crafter, "craft", recipe.label)
	end
	if recipe.witness then
		local lut = {}
		for _, v in pairs(recipe.nodes) do
			lut[minetest.hash_node_position(v)] = true
		end
		nodecore.witness(pos, {recipe.action, recipe.label},
			type(recipe.witness) == "number" and recipe.witness or nil,
			function(p) return lut[minetest.hash_node_position(p)] end
		)
	end
	minetest.log((data.crafter and data.crafter:get_player_name() or "unknown")
		.. " completed recipe \"" .. recipe.label .. "\" at " ..
		minetest.pos_to_string(pos) .. " upon " .. node.name)
	return true
end

local function tryall(rc, pos, node, data)
	local function go(xx, xz, zx, zz)
		return craftcheck(rc, pos, node, data, xx, xz, zx, zz)
	end
	local r = go(1, 0, 0, 1)
	if r then return r end
	if not rc.norotate then
		r = go(0, -1, 1, 0)
		or go(-1, 0, 0, -1)
		or go(0, 1, -1, 0)
		if r then return r end
		if not rc.nomirror then
			r = go(-1, 0, 0, 1)
			or go(0, 1, 1, 0)
			or go(1, 0, 0, -1)
			or go(0, -1, -1, 0)
		end
	end
	return r
end

function nodecore.craft_check(pos, node, data)
	data = data or {}
	node.x = pos.x
	node.y = pos.y
	node.z = pos.z
	data.pos = pos
	data.node = node
	for _, rc in ipairs(nodecore.craft_recipes) do
		if data.action == rc.action
		and nodecore.match(node, rc.root.match) then
			data.recipe = rc
			local r = tryall(rc, pos, node, data)
			if r then return r == true end
		end
	end
end
